
minetest.register_chatcommand("tribe_list", {
    params = "",

    description = "Lists the tribes in this world",

    privs = {privs=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		
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