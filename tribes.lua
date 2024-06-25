mobkit_sapien.tribes = {}

local tribes = {}

local enemies = {}

local storage = minetest.get_mod_storage()

-- error(storage:get("tribes"))

function mobkit_sapien.tribes.clear()
	storage:set_string("tribes", "")
	tribes = {}
	enemies = {}
end

function mobkit_sapien.tribes.add_enemy(id, ref)
	if not id then return end
	if not enemies[id] then enemies[id] = {} end
	if mobkit.is_alive(ref) then
		table.insert(enemies[id], ref)
	end
end
function mobkit_sapien.tribes.del_enemy(id, i)
	if enemies[id] and enemies[id][i] then
		table.remove(enemies[id], i)
	end
end

function mobkit_sapien.tribes.get_enemies(id)
	if id and enemies[id] then
		return enemies[id]
	end
end

function mobkit_sapien.tribes.clear_dead_enemies(id)
	if not (id and enemies[id]) then 
		return false 
	end
	local list = table.clone(enemies[id])
	local i = 0
	for i,v in ipairs(list) do
		if mobkit.is_alive(ref) then
			mobkit_sapien.tribes.del_enemy(id, i)
		end
	end
	return true
end

function mobkit_sapien.tribes.join(id)
	if not id or not tribes[id] then return end
	local t = minetest.deserialize(tribes[id])
	if t.pop then
		t.pop = t.pop + 1
	else
		t.pop = 1
	end
	local level = 0
	while level * level < t.pop do
		level = level + 1
	end
	t.level = level
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))
end

function mobkit_sapien.tribes.leave(id) 
	if not id or not tribes[id] then return end
	local t = minetest.deserialize(tribes[id])
	if t.pop then
		t.pop = t.pop - 1
	else
		t.pop = 0
	end
	local level = 0
	while level * level < t.pop do
		level = level + 1
	end
	t.level = level
	tribes[id] = minetest.serialize(t)
	if t.pop <= 0 then mobkit_sapien.tribes.delete(id) end
	storage:set_string("tribes", minetest.serialize(tribes))
end

function mobkit_sapien.tribes.employ(id, name)
	if not id or not tribes[id] or not mobkit_sapien.registered_jobs[name] then return end
	local t = minetest.deserialize(tribes[id])
	if t.jobs then
		if t.jobs[name] then
			t.jobs[name] = t.jobs[name] + 1
		else
			t.jobs[name] = 1
		end
	else
		t.jobs = {}
		t.jobs[name] = 1
	end
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))
	return true
end
function mobkit_sapien.tribes.unemploy(id, name)
	if not id or not tribes[id] or not mobkit_sapien.registered_jobs[name] then return end
	local t = minetest.deserialize(tribes[id])
	if t.jobs then
		if t.jobs[name] then
			t.jobs[name] = t.jobs[name] - 1
		else
			t.jobs[name] = 0
		end
	else
		t.jobs = {}
		t.jobs[name] = 0
	end
	t.level = level
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))
	return true
end

function mobkit_sapien.tribes.set(id, data)
	tribes[id] = minetest.serialize(data)
	storage:set_string("tribes", minetest.serialize(tribes))
end

function mobkit_sapien.tribes.new(name, origin)
	if not tribes then tribes = {} end
	table.insert(tribes, minetest.serialize({name = name, origin = vector.round(origin), level = 1}))
	mobkit_sapien.tribes.join(#tribes)
	storage:set_string("tribes", minetest.serialize(tribes))
	return #tribes
end

function mobkit_sapien.tribes.delete(id)
	tribes[id] = nil
	storage:set_string("tribes", minetest.serialize(tribes))
	enemies[id] = nil
end

function mobkit_sapien.tribes.get(id)
	tribes = minetest.deserialize(storage:get("tribes"))
	if not tribes then return end
	return minetest.deserialize(tribes[id])
end

function mobkit_sapien.tribes.getname(id)
	tribes = minetest.deserialize(storage:get("tribes"))
	if not tribes then return end
	local name = minetest.deserialize(tribes[id]).name
	return name
end

function mobkit_sapien.tribes.at(pos)
	pos = vector.round(pos)
	local x, z = pos.x, pos.z
	tribes = minetest.deserialize(storage:get("tribes"))
	if not tribes then return end
	for id,data in ipairs(tribes) do
		if data then
			local a = minetest.deserialize(data)
			local pos2, max = a.origin, a.level
			max = max and max * 8 + 8
			if pos2 and max and math.abs(x - pos2.x) <= max and math.abs(z - pos2.z) <= max then return id end
		end
	end
end

minetest.register_chatcommand("clear_tribes", {
    params = "",

    description = "Delete all tribes",

    privs = {privs=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		mobkit_sapien.tribes.clear()
		minetest.chat_send_all("tribes cleared")
	end,
})

minetest.register_chatcommand("tribes", {
    params = "",

    description = "Show tribes",

    privs = {privs=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		minetest.chat_send_all(storage:get("tribes"))
	end,
})