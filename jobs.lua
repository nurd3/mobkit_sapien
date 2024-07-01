
local S = mobkit_sapien.get_translator

-- JOBS LIBRARY --
mobkit_sapien.jobs = {}

function mobkit_sapien.jobs.random()
	local names = {}
	for name,def in pairs(mobkit_sapien.registered_jobs) do
		if not def.unrandom then
			table.insert(names, name)
		end
	end
	if #names > 0 then
		return names[math.random(#names)]
	end
end

function mobkit_sapien.jobs.gen_item(jobname)
	local jobdef = mobkit_sapien.registered_jobs[jobname]
	if not jobdef or not jobdef.items then return end
	for i,v in ipairs(jobdef.items) do 
		if #v > 0 and math.random() > 0.5 then
			local item = v[math.random(#v)]
			return item
		end
	end
end

-- REGISTERED JOBS --
mobkit_sapien.registered_jobs = {}

function mobkit_sapien.register_job(name, def)
	def.name = name
	mobkit_sapien.registered_jobs[name] = def
	minetest.register_craftitem(name.."_license", {
		description = S("@1 License", def.description or name),
		inventory_image = "sapien_license.png",
		groups = {document = 1, flammable = 3},
		mobkit_sapien_assign_job = name
	})
end