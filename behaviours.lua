local function is_in_group(name, group)
	local def = 
		minetest.registered_nodes[name] or 
		minetest.registered_items[name] or
		minetest.registered_tools[name]
	return def.groups[group] ~= nil
end

local function get_inv(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv
end

local function printpath(path)
	if not path then
		return core.chat_send_all"nil"
	end
	for i,v in ipairs(path) do
		core.chat_send_all(tostring(i).." "..vector.to_string(v))
	end
end

local function pathfind(self, tpos, max_dist)
	max_dist = max_dist or 128
	
	local max_drop = max_dist
	
	if not self.disable_fall_damage then
		max_drop = 1 + (0.1 * self.hp)
	end
	
	
	local path = core.find_path(
		vector.round(mobkit.get_stand_pos(self)), 
		tpos, 
		max_dist,
		self.jump_height,
		max_drop,
		"A*_noprefetch"
	)
	
	return path
end

function mobkit_sapien.set_job(self, name)
	if mobkit.recall(self, "job") then mobkit_sapien.unemploy(self) end
	mobkit.remember(self, "job", name)
	mobkit_sapien.tribes.employ(mobkit.recall(self, "tribe"), name)
end
function mobkit_sapien.unemploy(self)
	mobkit_sapien.tribes.unemploy(mobkit.recall(self, "tribe"), name)
	mobkit.forget(self, "job")
end

function mobkit_sapien.hq_find_tribe(self, prty)
	local tries = 0
	local pos = mobkit.get_stand_pos(self)
	local dest = mobkit_sapien.random_destination(self, 32)
	local job = mobkit.recall(self, "job")
	
	local func = function(self)
		local stuck = not mobkit.goto_next_waypoint(self, dest)
		if tries >= 10 or stuck then
			local id = mobkit_sapien.tribes.new(mobkit.recall(self, "name").."land", mobkit.get_stand_pos(self))
			mobkit.remember(self, "tribe", id)
			mobkit_sapien.tribes.join(id)
			if job then
				mobkit_sapien.tribes.employ(id, job)
			end
			return true
		end
		if mobkit.timer(self, 1) then
			local spos = mobkit.get_stand_pos(self)
			local id
			if spos then id = mobkit_sapien.tribes.at(spos) end
			if id then
				mobkit.remember(self, "tribe", id)
				mobkit_sapien.tribes.join(id)
				if job then
					mobkit_sapien.tribes.employ(id, job)
				end
				return true
			else
				tries = tries + 1
			end
		end
	end
	
	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_find_workplace(self, prty)
	self.act = "find workplace"
	local radius = 1
	local yaw = 0
	local stucks = 0
	local dest = mobkit_sapien.random_destination(self, 32)
	if not mobkit.recall(self, "job") then
		mobkit_sapien.set_job(self, mobkit_sapien.jobs.random())
	end
	local ignore = mobkit.recall(self, "ignore")
	ignore = ignore and vector.from_string(ignore)
	
	local func = function(self)
		if mobkit.recall(self, "workplace") then return true end
		local pos = self.object:get_pos()
		local vec = minetest.yaw_to_dir(yaw)
		local pos2 = mobkit.pos_shift(pos,vector.multiply(vec,radius))
		if get_inv(pos2):get_size("main") > 0 and (not ignore or not vector.equals(ignore, pos2)) then
			mobkit.remember(self, "workplace", vector.to_string(pos2))
			mobkit.forget(self, "ignore")
			return true
		end
		yaw=yaw+math.pi*0.25
		if yaw>2*math.pi then
			yaw = 0
			radius=radius+1
			if radius > 4 then
				radius = 1
				mobkit.goto_next_waypoint(self, dest)
				stucks = stucks + 1
				if stucks > 5 then
					dest = mobkit_sapien.random_destination(self, 32)
				end
			end
		end
	end

	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_find_bed(self, prty)
	local radius = 1
	local yaw = 0
	local stucks = 0
	local dest = mobkit_sapien.random_destination(self, 32)
	local ignore = mobkit.recall(self, "ignore")
	ignore = ignore and vector.from_string(ignore)
	
	local func = function(self)
		if mobkit.recall(self, "bed") then return true end
		local pos = self.object:get_pos()
		local vec = minetest.yaw_to_dir(yaw)
		local pos2 = mobkit.pos_shift(pos,vector.multiply(vec,radius))
		if is_in_group(minetest.get_node(pos2).name, "bed") and (not ignore or not vector.equals(ignore, pos2)) then
			mobkit.remember(self, "bed", vector.to_string(pos2))
			mobkit.forget(self, "ignore")
			return true
		end
		yaw=yaw+math.pi*0.25
		if yaw>2*math.pi then
			yaw = 0
			radius=radius+1
			if radius > 4 then
				radius = 1
				local stuck = not mobkit.goto_next_waypoint(self, dest)
				if stuck then
					stucks = stucks + 1
					if stucks > 2 then
						dest = mobkit_sapien.random_destination(self, 32)
					end
				end
				local dist = vector.distance(mobkit.get_stand_pos(self), dest)
				if dist < 1 then
					dest = mobkit_sapien.random_destination(self, 32)
				end
			end
		end
	end

	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_work(self, prty)
	local workplace = mobkit.recall(self, "workplace")
	local stucks = 0
	
	if not workplace then
		mobkit_sapien.hq_find_workplace(self, prty+1)
		return
	end
	
	local workpos = vector.from_string(workplace)
	
	local func = function(self)
		if mobkit.timer(self, 1) then
			local job = mobkit.recall(self, "job")
			if not job or not mobkit_sapien.registered_jobs[job] then
				mobkit_sapien.set_job(self, mobkit_sapien.jobs.random())
				job = mobkit.recall(self, "job")
			end
			local pos = mobkit.get_stand_pos(self)
			local dist = vector.distance(pos, workpos)
			if dist > 1024 then
				mobkit.forget(self, "tribe")
				return true
			elseif dist > 512 then
				mobkit.forget(self, "job")
				mobkit.forget(self, "workplace")
				return true
			elseif dist > 2 then
				local stuck = mobkit.goto_next_waypoint(self, workpos)
				if stuck then
					stucks = stucks + 1
					if stucks >= 5 then
						mobkit.forget(self, "workplace")
						mobkit.remember(self, "ignore", vector.to_string(workpos))
						return true
					end
				end
			else
				mobkit.animate(self, "stand")
				if mobkit.timer(self, 20) then
					core.after(0.1, function()
						mobkit.animate(self, "mine")
						core.after(0.1, function()
							mobkit.animate(self, "stand")
						end)
					end)
					local inv = get_inv(workpos)
					if inv:get_size("main") <= 0 then
						mobkit.forget(self, "job")
						mobkit.forget(self, "workplace")
						return true
					end
					local jobdef = mobkit_sapien.registered_jobs[job]
					
					if math.random(2) > 1 then
						local item = mobkit_sapien.jobs.gen_item(job)
						if inv:room_for_item("main", item) then
							inv:add_item("main", item)
						end
					end
				end
			end
			
			local tod = minetest.get_timeofday() * 5
			if tod > 3 then return true end
		end
	end

	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_sleep(self, prty)
	local bed = mobkit.recall(self, "bed")
	local stucks = 0

	if bed then
		bed = vector.from_string(bed)
	else
		bed = vector.round(mobkit.get_stand_pos(self))
	end

	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local dist = vector.distance(pos, bed)
		if dist > 1024 then
			mobkit.forget(self, "tribe")
			return true
		elseif dist > 512 then
			mobkit.forget(self, "bed")
			return true
		elseif dist > 2 then
			local stuck = not mobkit.goto_next_waypoint(self, bed)
			if stuck then
				stucks = stucks + 1
				if stucks >= 5 then
					mobkit.forget(self, "bed")
					mobkit.remember(self, "ignore", vector.to_string(bed))
					mobkit.animate(self, "sit")
					bed = vector.round(mobkit.get_stand_pos(self))
				end
			end
		else
			if not is_in_group(minetest.get_node(bed).name, "bed") and mobkit.recall(self, "bed") then
				mobkit.forget(self, "bed")
			end
			mobkit.animate(self, "sit")
		end
		local tod = minetest.get_timeofday() * 5
		if tod >= 1 and tod <= 4 then return true end
	end
	
	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_follow(self,prty,tgtobj)

	local melee_range = self.melee and self.melee.range or 3
	
	local index = 2
	local path = pathfind(self, tgtobj:get_pos(), self.view_range)

	local func = function(self)
		if not mobkit.is_alive(tgtobj) then return true end
		if mobkit.is_queue_empty_low(self) then
			local pos = mobkit.get_stand_pos(self)
			local opos = tgtobj:get_pos()
			local dist = vector.distance(pos,opos)
			if path and index > #path then
				path = pathfind(self, tgtobj:get_pos(), self.view_range)
				index = 2
			end
			
			if path then
				if dist > melee_range and path[index] then
					mobkit_sapien.lq_goto(self, path[index])
					index = index + 1
				end
			else return true end
		end
	end
	mobkit.queue_high(self,func,prty)
end

function mobkit_sapien.hq_attack(self,prty,tgtobj)
	local melee_range = self.melee and self.melee.range or 3

	local func = function(self)
		if not mobkit.is_alive(tgtobj) then return true end
		if mobkit.is_queue_empty_low(self) then
			local pos = mobkit.get_stand_pos(self)
			local tpos = mobkit.get_stand_pos(tgtobj)
			local dist = vector.distance(pos,tpos)
			if dist > melee_range
			or self.recharge
			and self._recharge_end
			and self._recharge_end > self.time_total
			then
				return true
			else
				mobkit.lq_turn2pos(self,tpos)
				local height = tgtobj:is_player() and 0.35 or tgtobj:get_luaentity().height*0.6
				if tpos.y+height>pos.y then 
					mobkit_sapien.lq_jumpattack(self,tpos.y+height-pos.y,tgtobj)
					self._recharge_end = self.recharge
						and (self.time_total + self.recharge)
				else
					mobkit_sapien.lq_goto(self, mobkit.pos_shift(tpos, 
						{x = math.random()-0.5,z = math.random()-0.5}))
				end

			end
		end
	end
	mobkit.queue_high(self,func,prty)
end

-- 
function mobkit_sapien.hq_hunt(self,prty,tgtobj)
	
	local melee_range = self.melee and self.melee.range or 3
	local range = self.ranged and self.ranged.range or self.view_range
	local firerate = self.ranged and self.ranged.rate or 1
	
	local path = pathfind(self, tgtobj:get_pos(), self.view_range)
	local index = 2
	local last_hp = self.hp

	local func = function(self)
		if not mobkit.is_alive(tgtobj)
		or not mobkit.is_alive(self)
		then return true
		elseif mobkit.is_queue_empty_low(self)
		then
			local pos = mobkit.get_stand_pos(self)
			local opos = mobkit.get_stand_pos(tgtobj)
			local dist = vector.distance(pos,opos)
			local can_see = mobkit_sapien.can_see(self, opos, tgtobj)
			if can_see then
				path = pathfind(self, opos, self.view_range)
				index = 2
			end
			
			if not can_see and (not path or index > #path) then
				return true
			end
			
			if path then
				if self.ranged then
					if dist > self.ranged.range and path[index] then
						mobkit_sapien.lq_goto(self, path[index])
						index = index + 1
					elseif mobkit.timer(self, firerate) then
						self.ranged.func(self, tgtobj, table.unpack(self.ranged.args))
					end
				end
				if self.melee then
					if dist > melee_range and not self.ranged and path[index] then
						mobkit_sapien.lq_goto(self, path[index])
						index = index + 1
					else
						mobkit_sapien.hq_attack(self,prty+1,tgtobj)
					end
				end
			else return true end
		end
	end
	mobkit.queue_high(self,func,prty)
end

function mobkit_sapien.hq_runfrom(self,prty,tgtobj)
	local init = true
	local timer = 6
	local wait = self.time_total
	local pos = mobkit.get_stand_pos(self)
	local opos = mobkit.get_stand_pos(tgtobj)
	local tpos = opos +
		vector.direction(pos, opos) * self.view_range * 0.5

	local path = pathfind(self, tpos, self.view_range)
	local index = 2
	local last_index = 1

	local func = function(self)
	
		if not mobkit.is_alive(tgtobj) then return true end
		if init then
			timer = timer-self.dtime
			if timer <=0 or vector.distance(self.object:get_pos(),tgtobj:get_pos()) < 8 then
				mobkit.make_sound(self,'scared')
				init=false
			end
			return
		end
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
			pos = mobkit.get_stand_pos(self)
			opos = mobkit.get_stand_pos(tgtobj)

			if mobkit.timer(self, 1) then
				local can_see = mobkit_sapien.can_see(self, opos, tgtobj)
				if not (path and index < #path and index ~= last_index)
				then
					if can_see 
					then
						wait = self.time_total
						local tries_left = 64
						repeat
							local dir = vector.direction(opos, pos)
							local tdir = vector.rotate(vector.new(math.random() - math.random(), 0, math.random() - math.random()) * 0.1, dir)
							
							tdir.y = 0
							tdir = vector.normalize(tdir)

							for i = (self.view_range or 16), 1, -1 do
								tpos = vector.round(pos + tdir * i)
								tpos.y = tpos.y + math.random(-1,1)
								path = pathfind(self, tpos, self.view_range)
								if path then break end
							end
							tries_left = tries_left - 1
						until(path or tries_left == 0)
						index = 2
						last_index = 1
					else
						if wait + 5 < self.time_total
						then return true
						end
					end
				end
			end
			last_index = index

			if path and index < #path then
				mobkit_sapien.lq_goto(self, path[index])
				index = index + 1
			else
				self.object:set_velocity({x=0,y=0,z=0})
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end

function mobkit_sapien.lq_jumpattack(self,height,target)
	local init = true	
	local tgtbox = target:get_properties().collisionbox
	local func=function(self)
		if not mobkit.is_alive(target)
		or not mobkit.is_alive(self) then return true end
		if self.isonground then
			if init then	-- collision bug workaround
				local vel = self.object:get_velocity()
				local dir = core.yaw_to_dir(self.object:get_yaw())
				dir=vector.multiply(dir,6)
				dir.y = -mobkit.gravity*math.sqrt(height*2/-mobkit.gravity)
				self.object:set_velocity(dir)
				mobkit.make_sound(self,'charge')
				init=false
			else
				mobkit.lq_idle(self,0.3)
				return true
			end
		else
			local tgtpos = target:get_pos()
			local pos = self.object:get_pos()
			-- calculate attack spot
			local yaw = self.object:get_yaw()
			local dir = core.yaw_to_dir(yaw)
			local apos = mobkit.pos_translate2d(pos,yaw,self.attack.range)

			if mobkit.is_alive(self) and mobkit.is_pos_in_box(apos,tgtpos,tgtbox) then	--bite
				target:punch(self.object,self.time_total - (self._time_of_last_punch or 0),self.attack)
				self._time_of_last_punch = self.time_total
					-- bounce off
				local vy = self.object:get_velocity().y
				self.object:set_velocity({x=dir.x*-3,y=vy,z=dir.z*-3})	
					-- play attack sound if defined
				mobkit.make_sound(self,'attack')
				return true
			end
		end
	end
	mobkit.queue_low(self,func)
end

function mobkit_sapien.lq_dumbwalk(self, dest, speed_factor)
	local timer = 3			-- failsafe
	speed_factor = speed_factor or 1
	local func = function(self)
		mobkit.animate(self,'walk')
		timer = timer - self.dtime
		if timer < 0 then return true end
		
		local pos = mobkit.get_stand_pos(self)
		local y = self.object:get_velocity().y

		if mobkit.isnear2d(pos,dest,0.25) then
			local new_pos = self.object:get_pos()
			new_pos.x, new_pos.z = math.round(dest.x), math.round(dest.z)
			self.object:set_pos(new_pos)
			if not self.isonground or math.abs(dest.y-pos.y) > 0.1 then
				self.object:set_velocity({x=0,y=y,z=0})
			end
			return true 
		end

		if self.isonground then
			local dir = vector.normalize(vector.direction(
					{x=pos.x,y=0,z=pos.z},
					{x=dest.x,y=0,z=dest.z}
				))
			dir = vector.multiply(dir, self.max_speed * speed_factor)
			self.object:set_yaw(core.dir_to_yaw(dir))
			dir.y = y
			self.object:set_velocity(dir)
		end
	end
	mobkit.queue_low(self,func)
end

function mobkit_sapien.lq_goto(self, tpos)

	local height = tpos.y - mobkit.get_stand_pos(self).y
	
	if height <= 0.5 then
		self.object:set_yaw(core.dir_to_yaw(vector.direction(self.object:get_pos(),tpos)))
		mobkit_sapien.lq_dumbwalk(self, tpos)
	else
		self.object:set_yaw(core.dir_to_yaw(vector.direction(self.object:get_pos(),tpos)))
		mobkit_sapien.lq_dumbjump(self, height)
	end
	
	return true
end