<<<<<<< HEAD
require("SMH")
local command = "gimme"
local setclass = "setclass"

local items = {12106,2401, 6187,  18610, 4560, 4560, 5235, 4111, 20522}
=======
command = "gimme"

items = {12106,2401, 6187,  18610, 4560, 4560, 5235, 4111, 20522}
>>>>>>> combo points retained and wand flick

local function summon_stuff(event, player)
    for i,v in pairs(items) do player:AddItem(v) end
end

local function PlrMenu(event, player, message)
<<<<<<< HEAD
	local words = {}
	for word in message:gmatch("%w+") do table.insert(words, word) end


	if (words[1] == setclass) then
		if player:GetGMRank() > 2 then
            player:SetSecondaryClass(tonumber(words[2]))
			player:SendServerResponse("DualClass", 1, player:GetSecondaryClass())
			print(words[2])
			return false
		end
	end
	
	if (words[1] == command) then
		if player:GetGMRank() > 2 then
            summon_stuff(event, player)
			return false
		end
	end

	return false
	
=======

	
	if (message:lower() == command) then
		if player:GetGMRank() > 2 then
            summon_stuff(event, player)
		return false
	end
	end
>>>>>>> combo points retained and wand flick
end

RegisterPlayerEvent(42, PlrMenu)