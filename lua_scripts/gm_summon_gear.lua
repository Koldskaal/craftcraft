require("SMH")
local command = "gimme"
local setclass = "setclass"

local items = { 205016, 205017, 205018, 205019, 205020,
	205021, 205022, 205023,
	205024, 205014, 350054 }
local stacks = { 2516 }

local function summon_stuff(event, player)
	player:EquipItem(player:AddItem(23162), 19)
	player:EquipItem(player:AddItem(23162), 20)
	player:EquipItem(player:AddItem(23162), 21)
	player:EquipItem(player:AddItem(23162), 22)

	for i, v in pairs(items) do player:AddItem(v) end
	for i, v in pairs(stacks) do player:AddItem(v, 200) end
end

local function PlrMenu(event, player, message)
	if player:GetGMRank() <= 2 then return end
	local words = {}
	for word in message:gmatch("%w+") do table.insert(words, word) end


	if (words[1] == setclass) then
		if player:GetGMRank() > 2 then
			player:SetSecondaryClass(tonumber(words[2]))
			player:SendServerResponse("DualClass", 1, player:GetSecondaryClass())
			-- print(words[2])
			return false
		end
	end

	if (words[1] == command) then
		if player:GetGMRank() > 2 then
			summon_stuff(event, player)
			return false
		end
	end

	if (words[1] == "ench") then
		if player:GetGMRank() > 2 then
			local item = player:GetItemByPos(255, 4) -- Chest
			local enchant = 155
			if words[2] then
				enchant = tonumber(words[2])
			end

			for i = 0, 6, 1 do
				item:ClearEnchantment(i)
				-- local success = item:SetEnchantment(3868, i)
			end
			for i = 2, 5, 1 do
				-- item:ClearEnchantment(i)
				local success = item:SetEnchantment(enchant + i, i)
			end
			-- local success = item:SetEnchantment(180009, 6)
			-- print(success) -- 170000 2, 3, 4 are viable slots
			-- print(item:GetName())
			return false
		end
	end

	if (words[1] == "enchp") then
		if player:GetGMRank() > 2 then
			local item = player:GetItemByPos(255, 17) -- Main hand
			-- player:SendBroadcastMessage(item:GetEnchantmentId(4))
			player:SendAddonMessage("HALLO", "ASD", 7, player)
			return false
		end
	end

	if (words[1] == "durr") then
		player:DurabilityRepairAll(false)
		player:DurabilityPointsLossAll(tonumber(words[2]))
	end


	return false
end

RegisterPlayerEvent(42, PlrMenu)
