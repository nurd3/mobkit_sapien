mobkit_plus = {}


-- util drop function
function mobkit_plus.drop(pos, chance, item, amount)

	-- amount handling
	local amt = amount or 1

	-- range handling
	if amount and type(amount) == "table" then
		local a, b = amount[1] or amount.x or 1, amount[2] or amount.y or nil

		-- correct odd ranges
		if not a then
			a = 1
		end
		if not b then
			b = default_stack_max
		end
		if a > b then
			local c = a
			a = b
			b = c
		end

		if a == b then
			amt = a
			minetest.log("warning", "mobkit_plus.drop: 0 distance range")
		elseif 											-- catch erroneous ranges
			a <= 0 or b <= 0 or							-- must be over 0
			a ~= math.floor(a) or b ~= math.floor(b)	-- must be integers
		then
			amt = 1
			minetest.log("error", "mobkit_plus.drop: range must be integers over 0")
		else
			amt = math.random(a, b)
		end
	end

	-- catch erroneous inputs
	if amt <= 0 or amt ~= math.floor(amt) then
		amt = 1
		minetest.log("warning", "mobkit_plus.drop: amount must be an integer over 0")
	end

	-- positioning
	local pos = vector.copy(pos)
	pos.y = pos.y + 2

	if math.random() < chance then
		-- drop the item
		minetest.add_item(
			pos, 
			ItemStack(item.." "..tostring(amt))
		)
	end
	
end

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

-- handle nodes that cause damage
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

-- get a random destination within a cube range of max_offset
function mobkit_plus.random_destination(self, max_offset)
	local ret = vector.copy(mobkit.get_stand_pos(self))
	vector.offset(ret,
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset)
	)
	return ret
end