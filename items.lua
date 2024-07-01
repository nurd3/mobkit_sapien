local S = mobkit_sapien.get_translator

----------
-- EGGS --
----------
minetest.register_node("mobkit_sapien:egg", {
	description = S"Sapien Egg",
	drawtype = "normal",
	tiles = {"sapien_egg.png"},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 3, falling_node = 1, oddly_breakable_by_hand = 3},
	paramtype = "none",
	paramtype2 = "none",
	
	on_construct = function(pos)
		minetest.get_node_timer(pos):set(1, 0)
	end,
	on_punch = function(pos)
		minetest.set_node(pos, {name="air"})
		minetest.add_item(pos, ItemStack("mobkit_sapien:egg"))
	end,
	on_rightclick = function(pos)
		minetest.set_node(pos, {name="air"})
		minetest.add_entity(pos, "mobkit_sapien:sapien")
	end,
	on_timer = function(pos, elapsed)
		if math.random(elapsed) > 5 then
		else
			minetest.get_node_timer(pos):set(2, elapsed)
		end
	end,
	light_source = 4,
})
minetest.register_node("mobkit_sapien:egg_guardian", {
	description = S"Guardian Egg",
	drawtype = "normal",
	tiles = {"sapien_egg.png^[hsl:120"},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 3, falling_node = 1, oddly_breakable_by_hand = 3},
	paramtype = "none",
	paramtype2 = "none",
	
	on_construct = function(pos)
		minetest.get_node_timer(pos):set(1, 0)
	end,
	on_punch = function(pos)
		minetest.set_node(pos, {name="air"})
		minetest.add_item(pos, ItemStack("mobkit_sapien:egg_guardian"))
	end,
	on_rightclick = function(pos)
		minetest.set_node(pos, {name="air"})
		minetest.add_entity(pos, "mobkit_sapien:guardian")
	end,
	on_timer = function(pos, elapsed)
		if math.random(elapsed) > 5 then
			minetest.set_node(pos, {name="air"})
			minetest.add_entity(pos, "mobkit_sapien:guardian")
		else
			minetest.get_node_timer(pos):set(2, elapsed)
		end
	end,
	light_source = 7,
})

------------------
-- TOILET PAPER --
------------------
minetest.register_craftitem("mobkit_sapien:toilet_paper", {
	description = S"Toilet Paper",
	inventory_image = "sapien_toilet_paper.png",
	groups = {flammable = 1, toilet_paper = 1},
	tradable = true,
})

local mg_nodes = {"mobkit_sapien:egg"}

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

minetest.register_craft({
	output = 'mobkit_sapien:egg_guardian',
	type = "shaped",
	recipe = {
			{'mobkit_sapien:egg','mobkit_sapien:egg','mobkit_sapien:egg'},
			{'mobkit_sapien:egg','mobkit_sapien:egg','mobkit_sapien:egg'},
			{'mobkit_sapien:egg','mobkit_sapien:egg','mobkit_sapien:egg'}
		},
})