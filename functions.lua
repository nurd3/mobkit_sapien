function mobkit_sapien.can_see(self, tpos, obj)

	-- local txt = ""

	-- txt = txt .. "---existence\n"

	if not self
	or not self.object
	or not self.object:is_valid()
	or not tpos
	then
		-- txt = txt .. ">nil"
		return
	end

	-- txt = txt .. "---life\n"
	
	-- txt = txt .. string.format("self_alive: %s\n", mobkit.is_alive(self) and "true" or "false")
	-- txt = txt .. string.format("trgt_alive: %s\n", mobkit.is_alive(obj) and "true" or "false")
	-- txt = txt .. string.format("target_object_provided: %s\n", obj and "true" or "false")

	if not mobkit.is_alive(self)
	or obj and not mobkit.is_alive(obj)
	then
		-- txt = txt .. ">false"
		-- self.object:set_nametag_attributes{text=txt}
		return false
	end

	-- txt = txt .. "---player hidden\n"
	
	-- txt = txt .. string.format("is_player: %s\n", obj and obj:is_player() and "true" or "false")
	-- txt = txt .. string.format("player_hidden: %s\n", obj and ul_mobs.is_player_hidden(obj) and "true" or "false")

	if ul_mobs.is_player_hidden(obj)
	then
		-- txt = txt .. ">false"
		-- self.object:set_nametag_attributes{text=txt}
		return false
	end
	
	local pos = self.object:get_pos()
	
	-- txt = txt .. "---line of sight\n"

	-- txt = txt .. string.format("self_pos: %s\n", vector.to_string(pos))
	-- txt = txt .. string.format("trgt_pos: %s\n", vector.to_string(tpos))

	if not core.line_of_sight(pos, tpos) then
		-- txt = txt .. ">false"
		-- self.object:set_nametag_attributes{text=txt}
		return false
	end
	
	local view_range = self.view_range or 16
	local dist = vector.distance(pos, tpos)
	local dist_frac = (dist / view_range)

	-- txt = txt .. "---within view_range\n"

	-- txt = txt .. string.format("view_range: %i\n", view_range)
	-- txt = txt .. string.format("dist: %i\n", dist)
	-- txt = txt .. string.format("dist_frac: %i%%\n", dist_frac * 100)
	
	if dist > view_range then
		-- txt = txt .. ">false"
		-- self.object:set_nametag_attributes{text=txt}
		return false
	end

	-- txt = txt .. ">true"
	-- self.object:set_nametag_attributes{text=txt}
	return true
end

-- util drop function
function mobkit_sapien.drop(pos, chance, item, amount)

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
			core.log("warning", "mobkit_sapien.drop: 0 distance range")
		elseif 											-- catch erroneous ranges
			a <= 0 or b <= 0 or							-- must be over 0
			a ~= math.floor(a) or b ~= math.floor(b)	-- must be integers
		then
			amt = 1
			core.log("error", "mobkit_sapien.drop: range must be integers over 0")
		else
			amt = math.random(a, b)
		end
	end

	-- catch erroneous inputs
	if amt <= 0 or amt ~= math.floor(amt) then
		amt = 1
		core.log("warning", "mobkit_sapien.drop: amount must be an integer over 0")
	end

	-- positioning
	local pos = vector.copy(pos)
	pos.y = pos.y + 2

	if math.random() < chance then
		-- drop the item
		core.add_item(
			pos, 
			ItemStack(item.." "..tostring(amt))
		)
	end
	
end

function mobkit_sapien.hurt_animation(self)
	mobkit.make_sound(self, "hurt")
	-- stolen from mobs redo
	core.after(0.1, function()
		self.object:set_texture_mod("^[invert:rgb")

		core.after(0.3, function()
			self.object:set_texture_mod("")
		end)
	end)
end

function mobkit_sapien.calculate_dmg(dtime, tool_capabilities)
	if not tool_capabilities or not tool_capabilities.damage_groups.fleshy then return 1 end
	if not tool_capabilities.full_punch_interval then return tool_capabilities.damage_groups.fleshy end
	local mult = math.min(1, dtime / (tool_capabilities.full_punch_interval))
	
	return math.random() < mult 
		and math.floor(tool_capabilities.damage_groups.fleshy * mult + 0.25)
		or 0
end

function mobkit_sapien.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	
	local is_alive = mobkit.is_alive(self)
	
	if not tool_capabilities.is_magic then
		local dmg = mobkit_sapien.calculate_dmg(time_from_last_punch, tool_capabilities)

		if dmg == 0 then
			return
		end
		
		self.hp = self.hp - dmg
	end
	
	mobkit_sapien.hurt_animation(self)
	if not self.disable_knockback and dir then
		local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
		self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
	end
	
	local weapon = puncher and puncher:get_wielded_item()
	
	if weapon and is_alive then

	
		-- add weapon wear
		local punch_attack_uses = tool_capabilities.punch_attack_uses
		
		local wear = 0

		-- check for punch_attack_uses being 0 to negate wear
		if punch_attack_uses and punch_attack_uses ~= 0 then
			wear = 65536 / punch_attack_uses
		end
		
		weapon:add_wear(wear)

		puncher:set_wielded_item(weapon)
	
	end

	return true	
end

-- handle nodes that cause damage
function mobkit_sapien.node_dps_dmg(self)
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
function mobkit_sapien.random_destination(self, max_offset)
	local ret = vector.copy(mobkit.get_stand_pos(self))
	vector.offset(ret,
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset),
		math.random(-max_offset,max_offset)
	)
	return ret
end

function mobkit_sapien.vitals(self)
	-- vitals: fall damage
	if not self.disable_fall_damage then
		local vel = self.object:get_velocity()
		local velocity_delta = math.abs(self.lastvelocity.y - vel.y)
		if velocity_delta > mobkit.safe_velocity then
			self.hp = self.hp - math.floor(self.max_hp * math.min(1, velocity_delta/mobkit.terminal_velocity))
			mobkit_sapien.hurt_animation(self)
		end
	end
	
	-- vitals: oxygen
	if self.lung_capacity then
		local colbox = self.object:get_properties().collisionbox
		local headnode = mobkit.nodeatpos(mobkit.pos_shift(self.object:get_pos(),{y=colbox[5]})) -- node at hitbox top
		if headnode and headnode.drawtype == 'liquid' then 
			self.oxygen = self.oxygen - self.dtime
		else
			self.oxygen = self.lung_capacity
		end
			
		if self.oxygen <= 0 then self.hp=0 end	-- drown
	end
end