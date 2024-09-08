local S = mobkit_sapien.get_translator

mobkit_sapien.register_job("mobkit_sapien:voider", {
    description = S"Voidman",
    items = {
        [1] = {"void_essential:stone"},
        [2] = {"void_essential:water_source"},
        [3] = {"void_essential:river_water_source"}
    }
})