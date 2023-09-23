require("SMH")
local command = "gimme"
local setclass = "setclass"

local items = { 205016, 205017, 205018, 205019, 205020, 205021, 205022, 205023,
	205024, 23162, 23162, 23162, 23162, 205000, 205008, 205014, 205006 }
local stacks = { 2516 }

local function summon_stuff(event, player)
	for i, v in pairs(items) do player:AddItem(v) end
	for i, v in pairs(stacks) do player:AddItem(v, 200) end
end

local function PlrMenu(event, player, message)
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
end

RegisterPlayerEvent(42, PlrMenu)
