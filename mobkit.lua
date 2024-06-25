

minetest.register_entity("mobkit_sapien:sapien", {
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = true,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.2, 0.3},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"sapien.png"},
	visual_size = {x = 1.0, y = 0.75},
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,			-- required
	on_activate = mobkit.actfunc,		-- required
	get_staticdata = mobkit.statfunc,
										-- api props
	springiness=0,
	buoyancy = 0.5,						-- portion of hitbox submerged
	max_speed = 2,
	jump_height = 1.50,
	view_range = 24,
	lung_capacity = 10,
	max_hp = 14,
	attack={range=0.5,damage_groups={fleshy=7}},
	sounds = {
		gasp = "sapien_gasp",
		die = "sapien_die",
		hurt = "sapien_hurt",
		idle = "sapien_idle"
	},
	animation = {
		-- Standard animations.
		stand     = {range = {x = 0, y = 79}, speed = 30, loop = true},
		lay       = {range = {x = 162, y = 166}, speed = 30, loop = true,
			collisionbox = {-0.6, 0.0, -0.6, 0.6, 0.3, 0.6}},
		walk      = {range = {x = 168, y = 187}, speed = 30, loop = true},
		mine      = {range = {x = 189, y = 198}, speed = 30, loop = true},
		walk_mine = {range = {x = 200, y = 219}, speed = 30, loop = true},
		sit       = {range = {x = 81,  y = 160}, speed = 30, loop = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}}
	},
	
	knockback = true,

	brainfunc = mobkit_sapien.brain,
	
	on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) and mobkit.is_alive(puncher) then
			mobkit.hq_runfrom(self, 15, obj)
			mobkit_sapien.tribes.add_enemy(mobkit.recall(self, "tribe"), puncher)
		end
		mobkit_plus.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,
	on_rightclick = function (self, clicker)
		if not mobkit.recall(self, "name") then mobkit.remember(self, "name", mobkit_sapien.gen_name()) end
		local job = mobkit.recall(self, "job")
		local jobdef
		if job then
			jobdef = mobkit_sapien.registered_jobs[job]
		end
		local stack = clicker:get_wielded_item()
		if stack:get_name() then
			local itemname = clicker:get_wielded_item():get_name()
			local itemdef = minetest.registered_craftitems[itemname]
			if itemdef then 
				if itemdef.mobkit_sapien_assign_job then
					local oldjob, newjob = job, itemdef.mobkit_sapien_assign_job
					if newjob == oldjob then
						local pos = clicker:get_pos()
						pos.y = pos.y + 1
						minetest.add_item(pos, ItemStack(stack:get_name().." 1"))
					end
					stack:set_count(stack:get_count() - 1)
					clicker:set_wielded_item(stack)
					mobkit_sapien.set_job(self, newjob)
					return
				end
				if itemname == "currency:minegeld_10" then
					local item = mobkit_sapien.jobs.gen_item(job, 2)
					if item then
						local inv = clicker:get_inventory()
						if inv:room_for_item("main", item) then
							inv:add_item("main", item)
						else
							local pos = clicker:get_pos()
							pos.y = pos.y + 1
							minetest.add_item(pos, ItemStack(item))
						end
					else
						local pos = clicker:get_pos()
						pos.y = pos.y + 1
						minetest.add_item(pos, ItemStack(stack:get_name().." 1"))
					end
					stack:set_count(stack:get_count() - 1)
					clicker:set_wielded_item(stack)
					return
				end
			end
		end
	end

})