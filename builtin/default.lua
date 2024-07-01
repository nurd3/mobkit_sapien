------------------
-- BUILTIN JOBS --
------------------

mobkit_sapien.register_job("mobkit_sapien:breeder", {
    description = S"Breeder",
    items = {
        [1] = {},
        [2] = {"mobkit_sapien:egg"},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {"mobkit_sapien:egg_guardian"},
    }
})
mobkit_sapien.register_job("mobkit_sapien:trader", {
    description = S"Trader",
    items = {
        [1] = {"mobkit_sapien:toilet_paper"},
        [2] = {""},
        [3] = {"mobkit_sapien:egg"},
    }
})

-------------------------
-- BUILTIN TRIBETRAITS --
-------------------------
mobkit_sapien.register_tribetrait("mobkit_sapien:xenophobic", {
    chance = 0.1,
    hostile_check = function(self, ent)
        return mobkit.is_alive(ent) and 
            (ent:is_player()
            or mobkit.recall(self, "tribe") ~= mobkit.recall(ent, "tribe"))
    end
})