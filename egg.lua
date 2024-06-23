local S = mobkit_sapien.get_translator

minetest.register_node("mobkit_sapien:egg", {
	description = S"Sapien Egg",
	drawtype = "normal",
	tiles = {"egg.png"},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, falling_node = 1, oddly_breakable_by_hand = 3},
	paramtype = "none",
	paramtype2 = "none",
	
	on_construct = function(pos)
		minetest.get_node_timer(pos):set(1, 0)
	end,
	on_timer = function(pos, elapsed)
		if math.random(elapsed) > 5 then
			minetest.set_node(pos, {name="air"})
			minetest.add_entity(pos, "mobkit_sapien:sapien")
		else
			minetest.get_node_timer(pos):set(2, elapsed)
		end
	end,
	
})