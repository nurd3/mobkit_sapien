function mobkit_sapien.brain(self, prty)

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
			if math.random(2) > 1 then minetest.add_item(pos, ItemStack(mobkit_sapien.jobs.gen_item(job))) end
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
							mobkit.make_sound(self, "gasp")
							mobkit.hq_runfrom(self, 15, obj)
						end
					end
				end
			end
		end
		
		if prty < 10 then
			if tod > 4 or tod < 1 and mobkit_sapien.bednode then
				self.act = "sleep"
				mobkit_sapien.hq_sleep(self, 10)
			else				
				if math.random(10) == 1 then
					mobkit.make_sound(self, "idle")
				end
				if tod <= 3 then
					mobkit_sapien.hq_work(self, 10)
				end
			end
		end
		if prty < 9 and not mobkit.recall(self, "bed") and mobkit_sapien.bednode then 
			self.act = "find bed"
			mobkit_sapien.hq_find_bed(self, 9)
		end

		-- if doing nothing
		if mobkit.is_queue_empty_high(self) then	-- if doing nothing]
			self.act = nil
			mobkit.hq_roam(self, 0)					-- fool around
		end
	end

end

minetest.register_entity("mobkit_sapien:sapien", {
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = false,
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
	max_speed = 4,
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
					core.after(0.1, function()
						mobkit.animate(self, "mine")
						core.after(0.1, function()
							mobkit.animate(self, "stand")
						end)
					end)
					local oldjob, newjob = job, itemdef.mobkit_sapien_assign_job
					if newjob == oldjob then
						mobkit.make_sound(self, "idle")
						local pos = clicker:get_pos()
						pos.y = pos.y + 1
						minetest.add_item(pos, ItemStack(stack:get_name().." 1"))
					else
						mobkit.make_sound(self, "gasp")
					end
					stack:set_count(stack:get_count() - 1)
					clicker:set_wielded_item(stack)
					mobkit_sapien.set_job(self, newjob)
					return
				end
				if itemname == "currency:minegeld_5" or itemname == "default:gold_ingot" then
					core.after(0.1, function()
						mobkit.animate(self, "mine")
						core.after(0.1, function()
							mobkit.animate(self, "stand")
						end)
					end)
					local item
					if math.random(2) == 1 then
						item = mobkit_sapien.jobs.gen_item(job, 2)
					end
					if item then
						mobkit.make_sound(self, "gasp")
						local inv = clicker:get_inventory()
						if inv:room_for_item("main", item) then
							inv:add_item("main", item)
						else
							local pos = clicker:get_pos()
							pos.y = pos.y + 1
							minetest.add_item(pos, ItemStack(item))
						end
					else
						mobkit.make_sound(self, "idle")
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
