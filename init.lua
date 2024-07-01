-- init.lua
-- 		initialization stuff idk what more to say

local path = minetest.get_modpath"mobkit_sapien"

mobkit_sapien = {}

mobkit_sapien.get_translator = minetest.get_translator"mobkit_sapien"

if beds then
	mobkit_sapien.bednode = "beds:bed"
end
if bed_rest then
	mobkit_sapien.bednode = "tech:sleeping_spot"
end 

if not table.unpack then
    table.unpack = unpack
end
function table.clone(t) 
	return {table.unpack(t)}
end

-- util functions
dofile(path.."/mobkit_plus.lua")
dofile(path.."/names.lua")

-- behaviours
dofile(path.."/high.lua")

-- libraries
dofile(path.."/jobs.lua")
dofile(path.."/tribes.lua")

-- entities & stuff
dofile(path.."/eggs.lua")
dofile(path.."/guardian.lua")
dofile(path.."/sapien.lua")
