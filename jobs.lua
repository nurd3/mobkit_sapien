mobkit_sapien.jobs = {}
mobkit_sapien.registered_jobs = {}

local S = mobkit_sapien.get_translator

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

if farming then
	mobkit_sapien.register_job("mobkit_sapien:farmer", {
		description = S"Farmer",
		items = {
			[1] = {"farming:seed_cotton", "farming:seed_wheat"},
			[2] = {"farming:wheat"},
			[3] = {},
			[4] = {"default:blueberry_bush_sapling"},
			[5] = {"farming:hoe_wood", "farming:flour"},
			[6] = {"farming:hoe_stone"},
		}
	})
end
if farming and mobs then
	mobkit_sapien.register_job("mobkit_sapien:baker", {
		description = S"Baker",
		items = {
			[1] = {"farming:wheat"},
			[2] = {"farming:flour"},
			[3] = {"farming:bread"},
			[4] = {"mobs:meat"},
			[5] = {"default:furnace", "farming:flour"},
			[6] = {"mobs:meatblock"},
		}
	})
end

mobkit_sapien.register_job("mobkit_sapien:miner", {
	description = S"Miner",
	items = {
		[1] = {"default:cobble"},
		[2] = {},
		[3] = {},
		[4] = {"default:coal_lump"},
		[5] = {"default:pick_wood", "default:coal_lump"},
		[6] = {"default:pick_stone", "default:copper_lump"},
		[7] = {"default:iron_lump"},
		[8] = {"default:gold_lump", "mese_crystal"},
		[9] = {"default:diamond"},
	}
})



mobkit_sapien.register_job("mobkit_sapien:blacksmith", {
	description = S"Blacksmith",
	items = {
		[1] = {"default:coal_lump", "default:clay_brick"},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {"default:stone", "default:copper_ingot"},
		[6] = {"default:bronze_ingot"},
		[7] = {"default:gold_ingot"},
	}
})

mobkit_sapien.register_job("mobkit_sapien:lumberjack", {
	description = S"Lumberjack",
	items = {
		[1] = {"default:tree"},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {"default:axe_wood", "default:sapling"},
		[6] = {"default:axe_stone"},
	}
})
if mobs then
	mobkit_sapien.register_job("mobkit_sapien:hunter", {
		description = S"Hunter",
		items = {
			[1] = {"mobs:meat_raw"},
			[2] = {},
			[3] = {"wool:white"},
			[4] = {},
			[5] = {"default:sword_wood", "mobs:meat"},
			[6] = {"default:sword_stone"},
			[7] = {},
			[8] = {"default:sword_bronze"},
		}
	})
end

mobkit_sapien.register_job("mobkit_sapien:trader", {
	description = S"Trader",
	eco = 2,
	items = {
		[1] = {"currency:minegeld"},
		[2] = {},
		[3] = {"wool:white", "default:book"},
		[4] = {},
		[5] = {"default:blueberries", "default:cactus"},
		[6] = {"default:papyrus"},
		[7] = {},
		[8] = {"default:gold_ingot","currency:minegeld_100"},
	}
})


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