mobkit_sapien.jobs = {}
mobkit_sapien.registered_jobs = {}

if farming then
	table.insert(mobkit_sapien.registered_jobs, {
		name = "farmer",
		key_item = "farming:hoe_wood",
		items = {
			[1] = {"farming:seed_cotton", "farming:seed_wheat"},
			[2] = {"farming:wheat"},
			[3] = {},
			[4] = {"default:blueberry_bush_sappling"},
			[5] = {"farming:hoe_wood", "farming:flour"},
			[6] = {"farming:hoe_stone"},
		}
	})
end
if farming and mobs then
	table.insert(mobkit_sapien.registered_jobs, {
		name = "baker",
		key_item = "farming:flour",
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

table.insert(mobkit_sapien.registered_jobs, {
	name = "miner",
	key_item = "default:pick_wood",
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



table.insert(mobkit_sapien.registered_jobs, {
	name = "blacksmith",
	key_item = "default:furnace",
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

table.insert(mobkit_sapien.registered_jobs, {
	name = "lumberjack",
	key_item = "default:axe_wood",
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
	table.insert(mobkit_sapien.registered_jobs, {
		name = "hunter",
		key_item = "default:sword_wood",
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

if minetest.get_modpath"boats" and currency then
	table.insert(mobkit_sapien.registered_jobs, {
		name = "sailor",
		key_item = "boats:boat",
		eco = 1,
		items = {
			[1] = {"currency:minegeld"},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {"boats:boat"},
		}
	})
	table.insert(mobkit_sapien.registered_jobs, {
		name = "pirate",
		key_item = "default:sword_stone",
		eco = 1,
		items = {
			[1] = {"currency:minegeld_5"},
			[2] = {},
			[3] = {"default:sword_wood"},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {"boats:boat"},
		}
	})
end 

if currency then
	table.insert(mobkit_sapien.registered_jobs, {
		name = "trader",
		key_item = "currency:minegeld",
		eco = 2,
		items = {
			[1] = {"currency:minegeld"},
			[2] = {},
			[3] = {"wool:white", "default:book"},
			[4] = {},
			[5] = {"default:blueberries", "default:cactus"},
			[6] = {"default:papyrus"},
			[7] = {},
			[8] = {"default:gold_ingot",},
		}
	})
	table.insert(mobkit_sapien.registered_jobs, {
		name = "elite",
		key_item = "default:dirt",
		eco = 10,
		items = {}
	})

	table.insert(mobkit_sapien.registered_jobs, {
		name = "tax collector",
		key_item = "default:gold_ingot",
		eco = 5,
		items = {
			[1] = {"currency:minegeld_5"}
		}
	})
	
	table.insert(mobkit_sapien.registered_jobs, {
		name = "leader",
		eco = 0,
		prod = -1,
		items = {}
	})
end

function mobkit_sapien.jobs.get_job(key_item) 
	for i,v in ipairs(mobkit_sapien.registered_jobs) do
		if v.key_item == key_item then return i end
	end
end