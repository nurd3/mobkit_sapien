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
	local dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
	
	local func = function(self)
		local stuck = not mobkit.goto_next_waypoint(self, dest)
		if tries >= 10 or stuck then
			local id = mobkit_sapien.tribes.new(mobkit.recall(self, "name").."land", mobkit.get_stand_pos(self))
			mobkit.remember(self, "tribe", id)
			return true
		end
		if mobkit.timer(self, 1) then
			local spos = mobkit.get_stand_pos(self)
			local id
			if spos then id = mobkit_sapien.tribes.at(spos) end
			if id then
				mobkit.remember(self, "tribe", id)
				mobkit_sapien.tribes.join(id)
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
	local dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
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
					dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
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
	local dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
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
						dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
					end
				end
				local dist = vector.distance(mobkit.get_stand_pos(self), dest)
				if dist < 1 then
					dest = mobkit_plus.random_destination(mobkit.get_stand_pos(self), 32)
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