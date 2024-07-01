mobkit_sapien.tribes = {}

local tribes = {}

local enemies = {}

local storage = minetest.get_mod_storage()

-----------------
-- TRIBETRAITS --
-----------------
mobkit_sapien.registered_tribetraits = {}
function mobkit_sapien.register_tribetrait(name, def)
	
end

-------------------------
-- BASIC TRIBE HANDING --
-------------------------

-- clear all tribes
function mobkit_sapien.tribes.clear()
	storage:set_string("tribes", nil)
	tribes = {}
	enemies = {}
end

function mobkit_sapien.tribes.get_new_id()
	tribes = minetest.deserialize(storage:get("tribes"))
	local id

	if not tribes then return "0" end

	for k,_ in pairs(tribes) do
		if not id or tonumber(k) < id then
			id = tonumber(k)
		end
	end

	return tostring(id)
end

-- new tribe
function mobkit_sapien.tribes.new(name, origin)

	local id = mobkit_sapien.tribes.get_new_id()

	if not tribes then tribes = {} end

	tribes[id] = minetest.serialize({name = name, origin = vector.round(origin), level = 1, tribetraits = {}})

	-- update tribe data
	storage:set_string("tribes", minetest.serialize(tribes))
	return 
end

-- set tribe data
function mobkit_sapien.tribes.set(id, data)
	if not id or not tribes[id] then return end

	local t = minetest.deserialize(tribes[id])

	for k,v in pairs(data) do
		t[k] = v
	end

	-- update tribe data
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))
end

-- get tribe
function mobkit_sapien.tribes.get(id)
	tribes = minetest.deserialize(storage:get("tribes"))

	if not tribes or not id then return end

	return minetest.deserialize(tribes[id])
end

-- iterator
function mobkit_sapien.tribes.iterator(id)
	tribes = minetest.deserialize(storage:get("tribes"))

	if not tribes or not id then return function () end end

	return pairs(minetest.deserialize(tribes[id]))
end

-- delete tribe
function mobkit_sapien.tribes.delete(id)
	tribes[id] = nil

	-- updata tribe data
	storage:set_string("tribes", minetest.serialize(tribes))
	enemies[id] = nil
end

--------------------
-- UTIL FUNCTIONS --
--------------------

-- get tribe's name
function mobkit_sapien.tribes.getname(id)
	local t = mobkit_sapien.tribes.get(id)

	if not t then return end

	return t.name
end

-- get tribe's origin
function mobkit_sapien.tribes.getpos(id)
	local t = mobkit_sapien.tribes.get(id)

	if not t then return end

	return t.origin
end

-- gets a tribe's size by level
function mobkit_sapien.tribes.calc_tribe_size(level)
	if not level then return end

	return level * 4 + 4
end

-- returns true if position is in borders of tribe
function mobkit_sapien.tribes.within_borders(id, x, z)
	local t = mobkit_sapien.tribes.get(id)

	if not t or not x or not z then return end

	local pos2 = t.origin
	local max = mobkit_sapien.tribes.calc_tribe_size(t.level)

	if pos2 and max 					-- valid tribe data?
	and math.abs(x - pos2.x) <= max		-- rectangle x check
	and math.abs(z - pos2.z) <= max		-- rectangle z check
	then 
		return true
	end
	return false
end

-- returns the id of the tribe which the position is within
function mobkit_sapien.tribes.at(pos)
	if not pos then return end

	pos = vector.round(pos)

	tribes = minetest.deserialize(storage:get("tribes"))

	if not tribes then return end

	for id,_ in pairs(tribes) do
		if mobkit_sapien.tribes.within_borders(id, pos.x, pos.z) then
			return id 
		end
	end
end

-- get distance to tribe
function mobkit_sapien.tribes.get_dist(self, id)
	local pos = mobkit.get_stand_pos(self)
	local tpos = mobkit_sapien.tribes.getpos(id)

	if not pos or not tpos then return end
	
	return vector.distance(pos, tpos)
end

-- calculate level of tribe
function mobkit_sapien.tribes.calc_level(population)
	if not population or population < 0 then return 0 end
	-- update level
	local level = 1
	while level * level <= population do
		level = level + 1
	end

	return level
end

-- increase tribe population and update level
function mobkit_sapien.tribes.join(id)
	if not id or not tribes[id] then return end

	local t = minetest.deserialize(tribes[id])
	
	if t.pop then
		t.pop = t.pop + 1
	else
		t.pop = 1
	end

	-- calculate tribe's level
	t.level = mobkit_sapien.tribes.calc_level(t.pop)
	
	-- update tribe data
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))

	return true
end

-- decrease tribe population and update level
function mobkit_sapien.tribes.leave(id) 
	if not id or not tribes[id] then return end

	local t = minetest.deserialize(tribes[id])

	if t.pop then
		t.pop = t.pop - 1
	else
		t.pop = 0
	end

	-- calculate tribe's level
	t.level = mobkit_sapien.tribes.calc_level(t.pop)

	-- update tribe data
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))

	-- delete empty tribes
	if t.pop <= 0 then mobkit_sapien.tribes.delete(id) end

	return true
end

-- increase count of a profession
function mobkit_sapien.tribes.employ(id, jobname)
	if not id or not tribes[id] or not mobkit_sapien.registered_jobs[jobname] then return end

	local t = minetest.deserialize(tribes[id])

	if t.jobs then
		if t.jobs[jobname] then
			t.jobs[jobname] = t.jobs[jobname] + 1
		else
			t.jobs[jobname] = 1
		end
	else
		t.jobs = {}
		t.jobs[jobname] = 1
	end

	-- update tribe data
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))

	return true
end

-- decrease count of a profession
function mobkit_sapien.tribes.unemploy(id, jobname)
	if not id or not tribes[id] or not mobkit_sapien.registered_jobs[jobname] then return end

	local t = minetest.deserialize(tribes[id])
	
	if t.jobs then
		if t.jobs[jobname] then
			t.jobs[jobname] = t.jobs[jobname] - 1
		else
			t.jobs[jobname] = 0
		end
	else
		t.jobs = {}
		t.jobs[jobname] = 0
	end

	-- update tribe data
	tribes[id] = minetest.serialize(t)
	storage:set_string("tribes", minetest.serialize(tribes))

	return true
end

--------------------
-- ENEMY HANDLING --
--------------------

-- add enemy
function mobkit_sapien.tribes.add_enemy(id, ref)
	if not id then return end
	if not enemies[id] then enemies[id] = {} end
	if mobkit.is_alive(ref) then
		table.insert(enemies[id], ref)
	end
end

-- remove enemy
function mobkit_sapien.tribes.del_enemy(id, i)
	if enemies[id] and enemies[id][i] then
		table.remove(enemies[id], i)
	end
end

-- get enemy list of tribe
function mobkit_sapien.tribes.get_enemies(id)
	if id and enemies[id] then
		return enemies[id]
	end
end

-- clears dead enemies for a single tribe
function mobkit_sapien.tribes.clear_dead_enemies(id)
	if not (id and enemies[id]) then 
		return false 
	end
	local list = table.clone(enemies[id])
	local i = 0
	for i,ref in ipairs(list) do
		if not mobkit.is_alive(ref) then
			mobkit_sapien.tribes.del_enemy(id, i)
		end
	end
	return true
end

-- clear dead enemies for all tribes
function mobkit_sapien.tribes.clear_dead_enemies_all()
	if enemies then
		for id,_ in pairs(enemies) do
			mobkit_sapien.tribes.clear_dead_enemies(id)
		end
	end
end

---------------------
-- UPDATE HANDLING --
---------------------

function mobkit_sapien.tribes.update_0x3x0()
	local old = minetest.deserialize(storage:get("tribes"))
	mobkit_sapien.tribes.clear()

	if not old then return end
	for _,data in ipairs(old) do
		local t = minetest.deserialize(data)

		mobkit_sapien.tribes.new(t.name, t.origin)
	end

	storage:set_string("version", "0.3.0")
end


if not storage:get("version") then		-- pre 0.3.0
	mobkit_sapien.tribes.update_0x3x0()
end

----------
-- MISC --
----------

-- forget players once they die
minetest.register_on_dieplayer(function()
	mobkit_sapien.tribes.clear_dead_enemies_all()
end)
