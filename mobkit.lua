

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
		if job then
			jobdef = mobkit_sapien.registered_jobs[job]
		end
		if clicker:get_wielded_item():get_name() then
			local toolname = clicker:get_wielded_item():get_name()
			local newjob = mobkit_sapien.jobs.get_job(toolname)
			if newjob then
				local newjobdef = mobkit_sapien.registered_jobs[newjob]
				mobkit.forget(self, "job")
				mobkit.remember(self, "job", newjob)
				minetest.chat_send_all(mobkit.recall(self, "name").." now work "..newjobdef.name)
				return 
			end
		end
		local msg
		
		if self.act then
			msg = mobkit.recall(self, "name").." "..self.act
		else
			local bed = mobkit.recall(self, "bed")
			local bedstr = nil
			if bed then
				bed = vector.from_string(bed)
				
				bedstr = "("..bed.x..","..bed.y..","..bed.z..")"
			end
			if jobdef then
				job = jobdef.name
			end
			local tribe = mobkit.recall(self, "tribe")
			if tribe then tribe = mobkit_sapien.tribes.getname(tribe) else tribe = "N/A" end
			msg = 
				"===\nname: "..mobkit.recall(self, "name")..
				"\ntribe: "..tribe..
				"\njob: "..(job or "N/A")..
				"\nbed: "..(bedstr or "N/A")
		end
		if clicker:is_player() then
			minetest.chat_send_player(clicker:get_player_name(), msg)
		else
			minetest.chat_send_all(msg)
		end
	end

})