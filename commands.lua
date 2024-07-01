
minetest.register_chatcommand("tribe_list", {
    params = "",

    description = "Lists the tribes in this world",

    privs = {privs=true},  -- Require the "privs" privilege to run

    func = function(name, param)
        local msg = ""
		for id,str in mobkit_sapien.tribes.iterator() do
            local data = minetest.deserialize(str)
            msg = msg
                .."\nname: "..data.name
                .."\nlevel: "..data.level
                .."\npopulation: "..data.pop
        end
        minetest.chat_send_all(msg)
	end,
})

minetest.register_chatcommand("clear_tribes", {
    params = "",

    description = "Delete all tribes",

    privs = {privs=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		mobkit_sapien.tribes.clear()
		minetest.chat_send_all("tribes cleared")
	end,
})