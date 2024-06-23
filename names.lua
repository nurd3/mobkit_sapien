local consonants, vowels = "mnptkbdgfshwlrj", "aeiou"
function mobkit_sapien.gen_name()
	local length = math.random(2, 3)
	local ret = ""
	local coda = nil
	
	while length > 0 do
		local c, v = math.random(#consonants), math.random(#vowels)
		ret = ret..consonants:sub(c,c)
		if math.random(5) > 3 then
			ret = ret..consonants:sub(c,c)
		end
		ret = ret..vowels:sub(v,v)
		if math.random(5) > 3 then
			ret = ret..consonants:sub(c,c)
		end
		length = length - 1
	end
	
	return ret
end