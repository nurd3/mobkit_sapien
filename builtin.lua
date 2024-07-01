local gamedata = minetest.get_game_info()
local path = mobkit_sapien.get_modpath

-- util function for checking if file exists
function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

-- error handling
if gamedata and gamedata.id then
    local src = path.."/builtin/"..gamedata.id..".lua"
    -- game is supported?
    if file_exists(src) then
        dofile(src)
    else
        minetest.log("warning", "[MOD] mobkit_sapien does not support game: "..gamedata.id)
    end
else    -- theoretically this message shouldn't show up
    minetest.log("warning", "[MOD] mobkit_sapien is confused how you're running this (invalid game data)")
end