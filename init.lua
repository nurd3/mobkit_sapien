-- init.lua
-- 		initialization stuff idk what more to say

local path = minetest.get_modpath"mobkit_sapien"

mobkit_sapien = {}

mobkit_sapien.get_translator = minetest.get_translator"mobkit_sapien"

if not table.unpack then
    table.unpack = unpack
end
function table.clone(t) 
	return {table.unpack(t)}
end

dofile(path.."/mobkit_plus.lua")
dofile(path.."/high.lua")
dofile(path.."/brain.lua")
dofile(path.."/mobkit.lua")
dofile(path.."/jobs.lua")
dofile(path.."/tribes.lua")
dofile(path.."/names.lua")
dofile(path.."/egg.lua")
