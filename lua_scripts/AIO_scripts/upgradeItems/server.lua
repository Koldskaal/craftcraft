local AIO = AIO or require("AIO")


if not AIO.AddAddon() then
    return
end

local crc32 = require("crc32lua").crc32
local Smallfolk = Smallfolk or require("smallfolk")

-- Brackets are split by 10 lvls. 1-20 is split into two as well
local function sortedKeys(query, sortFunction)
    local keys, len = {}, 0
    for k, _ in pairs(query) do
        len = len + 1
        keys[len] = k
    end
    table.sort(keys, sortFunction)
    return keys
end

local brackets = {
    [1] = {
        bracket = "lvl_bracket1",
        max_level = 9,
        min_level = 0,
        materials = {},
    },
    [2] = {
        bracket = "lvl_bracket1",
        max_level = 19,
        min_level = 10,
        materials = {},
    },
    [3] = {
        bracket = "lvl_bracket2",
        max_level = 29,
        min_level = 20,
        materials = {},
    },
    [4] = {
        bracket = "lvl_bracket3",
        max_level = 39,
        min_level = 30,
        materials = {},
    },
    [5] = {
        bracket = "lvl_bracket4",
        max_level = 49,
        min_level = 40,
        materials = {},
    },
    [6] = {
        bracket = "lvl_bracket5",
        max_level = 59,
        min_level = 50,
        materials = {},
    },
}

local mat_costs = {}

for _, value in ipairs(brackets) do
    local Q = WorldDBQuery("SELECT item FROM reference_loot_template " ..
        "JOIN item_template ON item_template.entry = reference_loot_template.item " ..
        "WHERE reference_loot_template.entry IN (SELECT " ..
        value["bracket"] .. " FROM creature_template " ..
        "JOIN creature_template_addon ON creature_template_addon.entry = creature_template.entry " ..
        "JOIN craftcraft_aura_loot_template ON creature_template_addon.auras LIKE CONCAT('%', craftcraft_aura_loot_template.aura_id, '%') " ..
        "WHERE maxlevel >= " ..
        value["min_level"] ..
        " and maxlevel <= " ..
        value["max_level"] ..
        " AND creature_template.rank < 2) AND item > 0 AND class = 7 ORDER BY item")
    if Q then
        repeat
            local entry = Q:GetUInt32(0)
            table.insert(value["materials"], entry)
        until not Q:NextRow()
    end
    --print(#value["materials"])
end

local Q = WorldDBQuery("SELECT entry, cost from craftcraft_material_costs")
if Q then
    repeat
        local entry, cost = Q:GetUInt32(0), Q:GetFloat(1)
        mat_costs[entry] = cost
        -- print(entry, cost)
    until not Q:NextRow()
end

local crc1 = crc32(Smallfolk.dumps(sortedKeys(brackets)))
local mat_costs_crc = crc32(Smallfolk.dumps(sortedKeys(mat_costs)))

local function SendBracketMaterials(player, crc_mats, crc_costs)
    if crc_mats ~= crc1 then --compare cached
        AIO.Msg():Add("SetBracketMaterials", brackets, crc1):Send(player);
    end

    if crc_costs ~= mat_costs_crc then --compare cached
        AIO.Msg():Add("SetBracketMaterialsCosts", mat_costs, mat_costs_crc)
            :Send(player);
    end
end

function CastItemUpgrade(player, bagId, slotId, desiredQuality,
                         desiredItemLevel)
    -- if (not player:HasSpell(100012)) then
    --     -- Could check if learned
    -- end

    if (bagId == 0) then
        bagId = 255
        slotId = slotId + 23
    end
    if (bagId ~= 255) then
        bagId = bagId + 18
    end
    if (bagId == -1) then return end

    local item = player:GetItemByPos(bagId, slotId - 1)
    if item:GetItemLevel() >= player:GetLevel() + 5 then
        player:SendBroadcastMessage(
            "Your level is too low to upgrade this item. (temp message)")
        return
    end

    if (desiredItemLevel > player:GetLevel() + 5) then
        player:SendBroadcastMessage(
            "Your level is too low to fully upgrade, capping at ilvl" ..
            player:GetLevel() + 5)


        player:CastCustomSpell(nil, 100012, false, player:GetLevel() + 5,
            desiredQuality, nil, item, player:GetGUID())
        return
    end

    player:CastCustomSpell(nil, 100012, false, desiredItemLevel,
        desiredQuality, nil, item, player:GetGUID())
end

AIO.RegisterEvent("RequestBracketMaterials", SendBracketMaterials)
AIO.RegisterEvent("CastItemUpgrade", CastItemUpgrade)
