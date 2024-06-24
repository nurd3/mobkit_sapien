function mobkit_sapien.brain(self, prty)

	if mobkit.timer(self,1) then mobkit_plus.node_dps_dmg(self) end
	mobkit.vitals(self)

	if self.hp <= 0 or self.dead then	-- if is dead
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
					if obj then
						mobkit.hq_hunt(self, 15, obj)
					end
				end
			end
		end
		
		if prty < 10 then
			if tod > 4 or tod < 1 and mobkit_sapien.bednode then
				self.act = "sleep"
				mobkit_sapien.hq_sleep(self, 10)
			elseif tod <= 3 then
				mobkit_sapien.hq_work(self, 10)
			elseif not mobkit.recall(self, "bed") and mobkit_sapien.bednode then 
				self.act = "find bed"
				mobkit_sapien.hq_find_bed(self, 10)
			end
		end

		-- if doing nothing
		if mobkit.is_queue_empty_high(self) then	-- if doing nothing]
			self.act = nil
			mobkit.hq_roam(self, 0)					-- fool around
		end
	end

end