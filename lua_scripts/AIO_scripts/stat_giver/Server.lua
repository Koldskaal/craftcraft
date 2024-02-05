local AIO = AIO or require("AIO")

local MyHandlers = AIO.AddHandlers("upgradeItems", {})
local AttributesPointsLeft = {}
local AttributesPointsSpend = {}
local AttributesAuraIds = { 7464, 7471, 7477, 7468, 7474, 15464, 30920, 13665, 13674, 32556 }
-- Strength, Agility, Stamina, Intellect, Spirit, hit10, lucky10, parry20, block5, dodge20

local function AddPlayerStats(msg, player)
    local guid = player:GetGUIDLow()
    local spend, left = AttributesPointsSpend[guid], AttributesPointsLeft[guid]
    return msg:Add("upgradeItems", "SetStats", left, AIO.unpack(spend))
end
AIO.AddOnInit(AddPlayerStats)

local function UpdatePlayerStats(player)
    AddPlayerStats(AIO.Msg(), player):Send(player)
end

local function AttributesInitPoints(guid)
    AttributesPointsLeft[guid] = 10000
    AttributesPointsSpend[guid] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
end
local function AttributesDeinitPoints(guid)
    AttributesPointsLeft[guid] = nil
    AttributesPointsSpend[guid] = nil
end

local function OnLogin(event, player)
    AttributesInitPoints(player:GetGUIDLow())
end
local function OnLogout(event, player)
    AttributesDeinitPoints(player:GetGUIDLow())
end

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(4, OnLogout)
for k, v in ipairs(GetPlayersInWorld()) do
    OnLogin(3, v)
end

function MyHandlers.AttributesIncrease(player, statId, amount)
    if (player:GetGMRank() < 2) then return end
    if (player:IsInCombat()) then
        player:SendBroadcastMessage(
            "Wait till out of combat.")
    else
        local guid = player:GetGUIDLow()
        local spend, left = AttributesPointsSpend[guid],
            AttributesPointsLeft[guid]
        if not spend or not left then
            return
        end
        if not statId or not spend[statId] then
            return
        end
        if (left <= 0) then
            player:SendBroadcastMessage(
                "No more points left.")
        else
            AttributesPointsLeft[guid] = left - amount
            spend[statId] = spend[statId] + amount
            local aura = player:GetAura(AttributesAuraIds[statId])
            if (aura) then
                aura:SetStackAmount(spend[statId])
            else
                player:AddAura(AttributesAuraIds[statId], player)
            end
            UpdatePlayerStats(player)
        end
    end
end

function MyHandlers.AttributesDecrease(player, statId, amount)
    if (player:IsInCombat()) then
        player:SendBroadcastMessage(
            "Wait till out of combat.")
    else
        local guid = player:GetGUIDLow()
        local spend, left = AttributesPointsSpend[guid],
            AttributesPointsLeft[guid]
        if not spend or not left then
            return
        end
        if not statId or not spend[statId] then
            return
        end
        if (spend[statId] <= 0) then
            spend[statId] = 0
        end

        AttributesPointsLeft[guid] = left + amount
        spend[statId] = spend[statId] - amount
        local aura = player:GetAura(AttributesAuraIds[statId])
        if (aura) then
            aura:SetStackAmount(spend[statId])
        else
            player:AddAura(AttributesAuraIds[statId], player)
        end
        UpdatePlayerStats(player)
    end
end

function MyHandlers.ClearAttributes(player)
    if (player:IsInCombat()) then
        player:SendBroadcastMessage(
            "Wait till out of combat.")
    else
        local guid = player:GetGUIDLow()
        local spend, left = AttributesPointsSpend[guid],
            AttributesPointsLeft[guid]
        if not spend or not left then
            return
        end
        AttributesPointsLeft[guid] = 10000
        for statId, _ in ipairs(AttributesAuraIds) do
            local aura = player:GetAura(AttributesAuraIds[statId])
            if (aura) then
                aura:SetStackAmount(0)
            end
            spend[statId] = 0
        end

        UpdatePlayerStats(player)
    end
end

local function AttributesOnCommand(event, player, command)
    local words = {}
    for word in command:gmatch("%w+") do table.insert(words, word) end

    if (words[1] == "uit") then
        if player:GetGMRank() > 2 then
            local item = player:GetItemByPos(255, 16)
            player:UpgradeItem(item:GetGUIDLow(), words[2], words[3])
        end
    end

    if (command == "dstat") then
        if player:GetGMRank() > 2 then
            AIO.Handle(player, "upgradeItems", "ShowAttributes")
        end
        return false
    end
end
RegisterPlayerEvent(42, AttributesOnCommand)
