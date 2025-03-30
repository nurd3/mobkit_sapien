local S = mobkit_sapien.get_translator

mobkit_sapien.register_job("mobkit_sapien:hunter", {
	description = S"Monster Hunter",
	items = {
		[1] = {"ul_mobs:eye"},
		[2] = {},
		[3] = {"ul_magic:heal"},
		[4] = {},
		[5] = {"ul_basic:knife", "ul_magic:regeneration"},
		[6] = {"ul_basic:sword", "ul_mobs:big_eye"}
	}
})
mobkit_sapien.register_job("mobkit_sapien:trafficker", {
	description = S"Monster Trafficker",
	items = {
		[1] = {"ul_mobs:eye"},
		[2] = {"ul_mobs:zombie", "ul_mobs:ghost", "ul_mobs:big_eye"},
		[3] = {"ul_mobs:stalker", "ul_mobs:vampire"},
		[4] = {"ul_mobs:skeleton"},
		[5] = {"ul_basic:knife", "ul_mobs:lich", "ul_mobs:shadow"},
		[6] = {"ul_basic:sword", "ul_mobs:lootglob"}
	}
})
mobkit_sapien.register_job("mobkit_sapien:miner", {
	description = S"Miner",
	items = {
		[1] = {"ul_basic:ore"},
		[2] = {"ul_basic:ore_rare", "ul_basic:lantern"},
		[3] = {"ul_basic:ore_super", "ul_basic:pick"},
		[4] = {"ul_magic:shard"},
		[5] = {"ul_magic:crystal", "ul_mobs:mgull"}
	}
})
mobkit_sapien.register_job("mobkit_sapien:builder", {
	description = S"Miner",
	items = {
		[1] = {"ul_basic:building"},
		[2] = {"ul_basic:building", "ul_basic:lamp"},
		[3] = {"ul_basic:door", "ul_basic:window"},
		[4] = {"ul_magic:shard"}
	}
})

ul_market.register_goods {
	industry = "ul_market:industry_breeding",
	items = {
		["mobkit_sapien:egg"] = {supply = 6.0},
		["mobkit_sapien:egg_guardian"] = {supply = 1.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_statlantic",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stpacific",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stmediterranean",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stafrican",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stslavic",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stamerican",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stindian",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}
ul_market.register_goods {
	industry = "ul_market:industry_stasian",
	items = {
		["mobkit_sapien:egg"] = {demand = 24.0},
		["mobkit_sapien:egg_guardian"] = {demand = 6.0},
	}
}