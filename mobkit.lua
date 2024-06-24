

minetest.register_entity("mobkit_sapien:sapien", {
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = true,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.2, 0.3},
	visual = "mesh",
	mesh = "sapien.b3d",
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
	timeout = 600,
	attack={range=0.5,damage_groups={fleshy=7}},
	sounds = {
		attack = "sapien_attack",
		hunt = "sapien_hunt",
		hurt = "sapien_hurt",
		idle = "sapien_idle"
	},
	animation = {
		walk={range={x=10,y=29},speed=30,loop=true},
		stand={range={x=1,y=5},speed=1,loop=true},
	},

	brainfunc = mobkit_sapien.brain,
	
	on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) and mobkit.is_alive(puncher) then
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