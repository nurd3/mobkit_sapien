local active_block_range = tonumber(minetest.get_mapgen_setting('active_block_range')) or 3

--------------------
-- UTIL FUNCTIONS --
--------------------
local function get_nearest_hostile(self)
	local retv = nil					    -- return value
	local dist = active_block_range*64	    -- maximum distance
	local pos = mobkit.get_stand_pos(self)	-- position

	-- search in nearby objects
	for _,obj in ipairs(self.nearby_objects) do
		local luaent = obj:get_luaentity()
		if mobkit.is_alive(obj) or obj:is_player() and luaent and luaent.name == name then
			local opos = obj:get_pos()
			local odist = math.abs(opos.x-pos.x) + math.abs(opos.z-pos.z)
			if odist < dist then
				if not obj.isinliquid and
				luaent and luaent.type == "monster" then
					dist = odist
					retv = obj
				end
			end
		end
	end
	return retv
end

-----------
-- BRAIN --
-----------
function mobkit_sapien.guardian_brain(self, prty)

	if mobkit.timer(self,1) then mobkit_plus.node_dps_dmg(self) end
	mobkit.vitals(self)

	if self.hp <= 0 or self.dead then	-- if is dead
		mobkit.make_sound(self, "die")
		mobkit.clear_queue_high(self)	-- cease all activity
		mobkit_sapien.tribes.leave(mobkit.recall(self, "tribe"))
		local job = mobkit.recall(self, "job")
		if job and mobkit_sapien.registered_jobs[job] then
			local pos = mobkit.get_stand_pos(self)
			pos.y = pos.y + 2
			if math.random(2) > 1 then minetest.add_item(pos, ItemStack(job.."_license 1")) end
			mobkit_sapien.unemploy(self)
		end
		mobkit.hq_die(self)				-- kick the bucket
		return
	end

	-- decision making happens every second
	if mobkit.timer(self,1) then
		if not mobkit_sapien.tribes.get(mobkit.recall(self, "tribe")) then mobkit.forget(self, "tribe") end
		local prty = mobkit.get_queue_priority(self)
		local tod = minetest.get_timeofday() * 5
		local tribe = mobkit.recall(self, "tribe")
		if not mobkit.recall(self, "name") then 
			mobkit.remember(self, "name", mobkit_sapien.gen_name()) 
		end
		if prty < 20 and self.isinliquid then
			mobkit.hq_liquid_recovery(self, 20)		-- try not to drown
		end
		
		if prty < 15 then
			if not tribe then
				mobkit_sapien.hq_find_tribe(self, 15)
			else
				mobkit_sapien.tribes.clear_dead_enemies(tribe)
				local enemies = mobkit_sapien.tribes.get_enemies(tribe)
				if enemies and #enemies > 0 then
					local obj = enemies[math.random(#enemies)]
					if mobkit.is_alive(obj) then
						if vector.distance(mobkit.get_stand_pos(self), obj:get_pos()) < self.view_range*1.1 then
							mobkit.make_sound(self, "hunt")
							mobkit.hq_hunt(self, 15, obj)
						end
					end
				end
			end
		end
		if math.random(15) == 1 then
			mobkit.make_sound(self, "idle")
		end
		if prty < 10 then
			local dist = mobkit_sapien.tribes.get_dist(self, tribe)
			local hostile = get_nearest_hostile(self)
			if hostile then
				mobkit_sapien.tribes.add_enemy(tribe, hostile)
				mobkit.make_sound(self, "hunt")
				mobkit.hq_hunt(self, 15, hostile)
			end
		end

		-- if doing nothing
		if mobkit.is_queue_empty_high(self) then	-- if doing nothing]
			self.act = nil
			mobkit.hq_roam(self, 0)					-- fool around
		end
	end

end

------------
-- ENTITY --
------------
minetest.register_entity("mobkit_sapien:guardian", {
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = false,
	collisionbox = {-0.4, 0.0, -0.4, 0.4, 1.9, 0.4},
	visual = "mesh",
	mesh = "sapien.b3d",
	textures = {"sapien.png^[hsl:120"},
	visual_size = {x = 1.7, y = 1.25},
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,			-- required
	on_activate = mobkit.actfunc,		-- required
	get_staticdata = mobkit.statfunc,
										-- api props
	springiness=0,
	buoyancy = 0.5,						-- portion of hitbox submerged
	max_speed = 3,
	jump_height = 2.50,
	view_range = 24,
	lung_capacity = 10,
	max_hp = 20,
	attack={range=0.5,damage_groups={fleshy=7}},
	sounds = {
		hunt = "guardian_hunt",
		die = "guardian_die",
		hurt = "guardian_hurt",
		idle = "guardian_idle",
		attack = "guardian_attack",
	},
	animation = {
		-- Standard animations.
		stand     = {range = {x = 0, y = 79}, speed = 15, loop = true},
		lay       = {range = {x = 162, y = 166}, speed = 15, loop = true,
			collisionbox = {-0.6, 0.0, -0.6, 0.6, 0.3, 0.6}},
		walk      = {range = {x = 168, y = 187}, speed = 15, loop = true},
		mine      = {range = {x = 189, y = 198}, speed = 15, loop = true},
		attack 	  = {range = {x = 200, y = 219}, speed = 15, loop = true},
		sit       = {range = {x = 81,  y = 160}, speed = 15, loop = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}}
	},
	
	knockback = true,

	brainfunc = mobkit_sapien.guardian_brain,
	
	on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) and mobkit.is_alive(puncher) then
			mobkit.make_sound(self, "hunt")
			mobkit.hq_hunt(self, 15, obj)
			mobkit_sapien.tribes.add_enemy(mobkit.recall(self, "tribe"), puncher)
		end
		mobkit_plus.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,

})