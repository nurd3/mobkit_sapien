mobkit_plus = {}

function mobkit_plus.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)

	mobkit.hurt(self,tool_capabilities.damage_groups.fleshy or 1)
	mobkit.make_sound(self, "hurt")
	if self.knockback then
		local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
		self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
	end
	-- stolen from mobs redo
	core.after(0.1, function()
		self.object:settexturemod("^[brighten")

		core.after(0.3, function()
			self.object:settexturemod("")
		end)
	end)
	
end

function mobkit_plus.node_dps_dmg(self)
	local pos = self.object:get_pos()
	local box = self.object:get_properties().collisionbox
	local pos1 = {x = pos.x + box[1], y = pos.y + box[2], z = pos.z + box[3]}
	local pos2 = {x = pos.x + box[4], y = pos.y + box[5], z = pos.z + box[6]}
	local nodes_overlap = mobkit.get_nodes_in_area(pos1, pos2)
	local total_damage = 0

	for node_def, _ in pairs(nodes_overlap) do
		local dps = node_def.damage_per_second
		if dps then
			total_damage = math.max(total_damage, dps)
		end
	end

	if total_damage ~= 0 then
		mobkit.make_sound(self, "hurt")
		mobkit.hurt(self, total_damage)
	end
end

function mobkit_plus.random_destination(self, max_offset) 
	local ret = vector.copy(mobkit.get_stand_pos(self))
	vector.offset(ret,
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset)
	)
	return ret
end