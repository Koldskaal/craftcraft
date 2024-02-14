local AIO = AIO or require("AIO")


if not AIO.AddAddon() then
    return
end

local crc32 = require("crc32lua").crc32
local Smallfolk = Smallfolk or require("smallfolk")

local mat_inventory_mult = {
    0,    --0	Non equipable
    1,    --1	Head
    0.55, --2	Neck
    0.77, --3	Shoulder
    0,    --4	Shirt
    1,    --5	Chest (see also Robe = 20)
    0.77, --6	Waist
    1,    --7	Legs
    0.77, --8	Feet
    0.55, --9	Wrists
    0.77, --10	Hands
    0.55, --11	Finger
    0.7,  --12	Trinket
    0.8,  --13	One-Hand (not to confuse with Off-Hand = 22)
    0.8,  --14	Shield (class = armor, not weapon even if in weapon slot)
    1,    --15	Ranged (Bows) (see also Ranged right = 26)
    0.55, --16	Back
    1.2,  --17	Two-Hand
    0,    --18	Bag
    0,    --19	Tabard
    1,    --20	Robe (see also Chest = 5)
    0.8,  --21	Main hand
    0.8,  --22	Off Hand weapons (see also One-Hand = 13)
    0.8,  --23	Held in Off-Hand (tome, cane, flowers, torches, orbs etc... See also Off-Hand = 22) (class = armor, not weapon even if in weapon slot)
    0,    --24	Ammo
    0.8,  --25	Thrown
    1,    --26	Ranged right (Wands, Guns) (see also Ranged = 15)
    0,    --27	Quiver
    0.3,  --28	Relic (class = armor, not weapon even if in weapon slot)
}

local quality_mult_mat = {
    0,    --Grey
    0.3,  --White
    0.5,  --Green
    0.75, --Blue
    1,    --Purple
};

local brackets = {
    [1] = {
        bracket = "lvl_bracket1",
        max_level = 19,
        min_level = 10,
        materials = {},
    },
    [2] = {
        bracket = "lvl_bracket2",
        max_level = 29,
        min_level = 20,
        materials = {},
    },
    [3] = {
        bracket = "lvl_bracket3",
        max_level = 39,
        min_level = 30,
        materials = {},
    },
    [4] = {
        bracket = "lvl_bracket4",
        max_level = 49,
        min_level = 40,
        materials = {},
    },
    [5] = {
        bracket = "lvl_bracket5",
        max_level = 59,
        min_level = 50,
        materials = {},
    },
}

local mat_costs = {}

local function generateBudgetMats(
    itemLevel,
    mult,
    inventoryType
)
    return (
        math.max(
            (itemLevel * mult + 2) * mat_inventory_mult[inventoryType + 1],
            0
        ) ^ 2
    );
end

local function GenerateMaterialRequirements(seed, itemLvl, quality, inventoryType)
    local budget = generateBudgetMats(itemLvl, quality_mult_mat[quality + 1],
        inventoryType)
    local budgetPerMat = budget / #MAT_BRACKETS;
    local new_mats = {}

    for i = 1, #MAT_BRACKETS, 1 do
        local mats = MAT_BRACKETS[i]["materials"]
        table.sort(mats)

        local mat_cost = MAT_COSTS[mats[seed % #mats + 1]]
        if (not mat_cost) then mat_cost = 1 end

        local count = math.floor(budgetPerMat ^ (1 / 2) / mat_cost + 0.5)
        table.insert(new_mats,
            { material = mats[seed % #mats + 1], count = count })
    end

    return new_mats
end

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

local function CastItemUpgrade(player, bagId, slotId, desiredItemLevel,
                               desiredQuality)
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

    if desiredItemLevel >= player:GetLevel() + 5 then
        player:SendBroadcastMessage(
            "Your level is too low to upgrade this item this far.")
        return
    end

    if desiredItemLevel < 65 and item:GetQuality() ~= desiredQuality then
        player:SendBroadcastMessage(
            "Invalid quality upgrade.")
        return
    end

    if (desiredQuality > 4) then
        player:SendBroadcastMessage(
            "Invalid quality upgrade.")
        return
    end

    player:CastCustomSpell(nil, 100012, false, desiredItemLevel,
        desiredQuality, nil, item, player:GetGUID())
end

AIO.RegisterEvent("RequestBracketMaterials", SendBracketMaterials)
AIO.RegisterEvent("CastItemUpgrade", CastItemUpgrade)
