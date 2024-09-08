local S = mobkit_sapien.get_translator

mobkit_sapien.register_job("mobkit_sapien:hunter", {
    description = S"Monster Hunter",
    items = {
        [1] = {"ul_mobs:eye"},
        [2] = {},
        [3] = {"ul_magic:health"},
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
