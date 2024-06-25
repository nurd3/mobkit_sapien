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

local mg_nodes = {"mobkit_sapien:egg", "default:chest"}

if mobkit_sapien.bednode then
	table.insert(mg_nodes, 0, mobkit_sapien.bednode)
end

minetest.register_decoration({
	name = "mobkit_sapien:egg",
	deco_type = "simple",
	place_on = {"mapgen_dirt_with_grass", "mapgen_cobble", "mapgen_dirt_with_snow"},
	sidelen = 16,
	noise_params = {
		offset = -0.012,
		scale = 0.024,
		spread = {x = 100, y = 100, z = 100},
		seed = 230,
		octaves = 3,
		persist = 0.6
	},
	y_max = 30,
	y_min = -50,
	decoration = mg_nodes,
})