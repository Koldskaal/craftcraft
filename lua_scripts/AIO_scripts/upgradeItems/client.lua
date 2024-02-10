local AIO = AIO or require("AIO")


if AIO.AddAddon() then
    return
end

local function sortedKeys(query, sortFunction)
    local keys, len = {}, 0
    for k, _ in pairs(query) do
        len = len + 1
        keys[len] = k
    end
    table.sort(keys, sortFunction)
    return keys
end


local function SetBracketMaterials(player, brackets, crc)
    MAT_BRACKETS = brackets
    MAT_BRACKETS["crc"] = crc
    print("Received mat brackets")
end

local function SetBracketMaterialCosts(player, mat_costs, crc)
    MAT_COSTS = mat_costs
    MAT_COSTS["crc"] = crc

    print("Received mat costs")
    print(crc)
end

MAT_BRACKETS = MAT_BRACKETS or {}
MAT_COSTS = MAT_COSTS or {}
AIO.AddSavedVar("MAT_BRACKETS")
AIO.AddSavedVar("MAT_COSTS")



AIO.Msg():Add("RequestBracketMaterials", MAT_BRACKETS["crc"],
    MAT_COSTS["crc"]):Send()

local function StringHash(text)
    local counter = 1
    local len = string.len(text)
    for i = 1, len, 3 do
        counter = math.fmod(counter * 8161, 4294967279) + -- 2^32 - 17: Prime!
            (string.byte(text, i) * 16776193) +
            ((string.byte(text, i + 1) or (len - i + 256)) * 8372226) +
            ((string.byte(text, i + 2) or (len - i + 256)) * 3932164)
    end
    return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

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

local function generateBudgetMats(
    itemLevel,
    mult,
    inventoryType
)
    print(mat_inventory_mult[inventoryType + 1], mult, itemLevel)
    return (
        math.max(
            (itemLevel * mult + 2) * mat_inventory_mult[inventoryType + 1],
            0
        ) ^ 2
    );
end



local function GenerateMaterialRequirements(seed, itemLvl, quality, inventoryType)
    -- - ilvl 10 -> ilvl 65
    -- - Mats:
    -- - tier 1
    -- - tier 2
    -- - tier 3
    -- - tier 4
    -- - tier 5
    local budget = generateBudgetMats(itemLvl, quality_mult_mat[quality + 1],
        inventoryType)
    local budgetPerMat = budget / #MAT_BRACKETS;
    local new_mats = {}
    print(budgetPerMat, budget)

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

function CastItemUpgrade(bagId, slotId, desiredQuality,
                         desiredItemLevel)
    -- local itemID = GetContainerItemID(bagId, slotId)
    local mats = GenerateMaterialRequirements(100000, 65, 1, 1)

    for key, value in pairs(mats) do
        print(value["material"], value
            ["count"])
        -- print("Materials: " .. value["material"] .. " | Cost: " .. value
        -- ["count"])
    end


    AIO.Msg():Add("CastItemUpgrade", bagId, slotId, desiredQuality,
        desiredItemLevel):Send()
end

--GenerateMaterialRequirements(StringHash("string"), 65, 2, 1)
-- print()
-- print(#MAT_COSTS)
-- for index, value in pairs(MAT_COSTS) do
--     print(index, value)
-- end -- DOESNT WORK YET

AIO.RegisterEvent("SetBracketMaterials", SetBracketMaterials)
AIO.RegisterEvent("SetBracketMaterialsCosts", SetBracketMaterialCosts)
AIO.RegisterEvent("CastItemUpgrade", CastItemUpgrade)
