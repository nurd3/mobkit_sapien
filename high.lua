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

function mobkit_sapien.hq_find_tribe(self, prty)
	local tries = 0
	local pos = mobkit.get_stand_pos(self)
	pos.x, pos.y, pos.z = 
		pos.x + math.random(-32,32), 
		pos.y + math.random(-32,32), 
		pos.z + math.random(-32,32)
	
	local func = function(self)
		if tries >= 10 then
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
				mobkit.goto_next_waypoint(self, pos)
			end
		end
	end
	
	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.get_job(self)
	mobkit.remember(self, "job", math.random(#mobkit_sapien.registered_jobs))
end

function mobkit_sapien.hq_find_workplace(self, prty)
	self.act = "find workplace"
	local radius = 1
	local yaw = 0
	if not mobkit.recall(self, "job") then
		mobkit_sapien.get_job(self)
	end
	
	local func = function(self)
		if mobkit.recall(self, "workplace") then return true end
		local pos = self.object:get_pos()
		local vec = minetest.yaw_to_dir(yaw)
		local pos2 = mobkit.pos_shift(pos,vector.multiply(vec,radius))
		if get_inv(pos2):get_size("main") > 0 then
			mobkit.remember(self, "workplace", vector.to_string(pos2))
			return true
		end
		yaw=yaw+math.pi*0.25
		if yaw>2*math.pi then
			yaw = 0
			radius=radius+1
			if radius > 64 then
				mobkit.hq_roam(self, 0)
				return true
			end	
		end
	end

	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_work(self, prty)
	local workplace = mobkit.recall(self, "workplace")
	
	if not workplace then
		mobkit_sapien.hq_find_workplace(self, prty+1)
		return
	end
	
	local workpos = vector.from_string(workplace)
	
	local func = function(self)
		if mobkit.timer(self, 1) then
			local job = mobkit.recall(self, "job")
			if not job then
				mobkit_sapien.get_job(self)
				job = mobkit.recall(self, "job")
			end
			self.act = "work "..mobkit_sapien.registered_jobs[job].name
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
				mobkit.goto_next_waypoint(self, workpos)
			elseif mobkit.timer(self, 20) then
				local inv = get_inv(workpos)
				if inv:get_size("main") <= 0 then
					mobkit.forget(self, "job")
					mobkit.forget(self, "workplace")
					return true
				end
				local jobdef = mobkit_sapien.registered_jobs[job]
				if math.random(2) > 1 then
				for i,v in ipairs(jobdef.items) do 
					if #v > 0 and math.random(2) > 1 then
						local item = v[math.random(#v)]
						if inv:room_for_item("main", item) then
							inv:add_item("main", item)
							break
						end
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

function mobkit_sapien.hq_find_bed(self, prty)
	local radius = 1
	local yaw = 0
	
	local func = function(self)
		if mobkit.recall(self, "bed") then return true end
		local pos = self.object:get_pos()
		local vec = minetest.yaw_to_dir(yaw)
		local pos2 = mobkit.pos_shift(pos,vector.multiply(vec,radius))
		if is_in_group(minetest.get_node(pos2).name, "bed") then
			mobkit.remember(self, "bed", vector.to_string(pos2))
			return true
		end
		yaw=yaw+math.pi*0.25
		if yaw>2*math.pi then
			yaw = 0
			radius=radius+1
			if radius > 64 then
				mobkit.remember(self, "bed", vector.to_string(pos))
				return true
			end	
		end
	end

	mobkit.queue_high(self, func, prty)
end

function mobkit_sapien.hq_sleep(self, prty)
	local bed = mobkit.recall(self, "bed")

	if bed then
		bed = vector.from_string(bed)
	else
		bed = mobkit.get_stand_pos(self)
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
			mobkit.goto_next_waypoint(self, pos, bed)
		else
			if not is_in_group(minetest.get_node(bed).name, "bed") then
				mobkit.forget(self, "bed")
			end
		end
		local tod = minetest.get_timeofday() * 5
		if tod >= 1 and tod <= 4 then return true end
	end
	
	mobkit.queue_high(self, func, prty)
end