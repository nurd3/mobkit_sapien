local S = mobkit_sapien.get_translator

mobkit_sapien.register_job("mobkit_sapien:electrician", {
    description = S"Electrician",
    items = {
        [1] = {"electricity:transistor", "electricity:diode", "electricity:led", "electricity:ground", "electricity:lamp_broken"},
        [2] = {"electricity:battery_box", "electricity:switch_off"},
        [3] = {"electricity:lamp_off"},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {"electricity:infinite_electricity"},
    }
})