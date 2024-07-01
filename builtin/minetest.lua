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