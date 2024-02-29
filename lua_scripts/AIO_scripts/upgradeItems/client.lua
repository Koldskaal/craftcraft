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

local function lshift(x, by)
    return x * 2 ^ by
end

function StringHash(str)
    local h = 5381;

    for c in str:gmatch "." do
        h = ((lshift(h, 2) + h) + string.byte(c)) % 4294967295
    end
    -- print(string.format("%.f", h))
    return h
end

local function CacheAllMats()
    for key, value in pairs(MAT_BRACKETS) do
        if key ~= "crc" then
            table.sort(value.materials)
            for _, mat in pairs(value.materials) do
                GameTooltip:SetOwner(UIParent, "ANCHOR_RIGHT");
                GameTooltip:SetHyperlink("item:" ..
                    mat .. ":0:0:0:0:0:0:0")
            end
        end
    end

    GameTooltip:Hide()
end

local function SetBracketMaterials(player, brackets, crc)
    MAT_BRACKETS = brackets
    MAT_BRACKETS["crc"] = crc
    print("Received mat brackets")
    CacheAllMats()
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
CacheAllMats()


AIO.Msg():Add("RequestBracketMaterials", MAT_BRACKETS["crc"],
    MAT_COSTS["crc"]):Send()


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

local BASE_MAT_COUNT = 20;

ITEM_INVTYPE_IDS = {
    ["INVTYPE_NON_EQUIP"] = 0,
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = 11,
    ["INVTYPE_TRINKET"] = 12,
    ["INVTYPE_WEAPON"] = 13,
    ["INVTYPE_SHIELD"] = 14,
    ["INVTYPE_RANGED"] = 15,
    ["INVTYPE_CLOAK"] = 16,
    ["INVTYPE_2HWEAPON"] = 17,
    ["INVTYPE_BAG"] = 18,
    ["INVTYPE_TABARD"] = 19,
    ["INVTYPE_ROBE"] = 20,
    ["INVTYPE_WEAPONMAINHAND"] = 21,
    ["INVTYPE_WEAPONOFFHAND"] = 22,
    ["INVTYPE_HOLDABLE"] = 23,
    ["INVTYPE_THROWN"] = 24,
    ["INVTYPE_AMMO"] = 25,
    ["INVTYPE_RANGEDRIGHT"] = 26,
    ["INVTYPE_QUIVER"] = 27,
    ["INVTYPE_RELIC"] = 28,
}


function GenerateMaterialRequirements(name, itemLvl, quality, inventoryType,
                                      targetilvl)
    local new_mats = {}
    local current_ilvl = itemLvl
    local seed = StringHash(name);

    for i = 1, #MAT_BRACKETS, 1 do
        local max_ilvl = MAT_BRACKETS[i]["max_level"] + 6
        local ilvl_diff = MAT_BRACKETS[i]["max_level"] -
            MAT_BRACKETS[i]["min_level"]

        if (current_ilvl >= targetilvl) then return new_mats end
        if current_ilvl < max_ilvl then
            local mats = MAT_BRACKETS[i]["materials"]
            -- table.sort(mats)
            local index = seed % #mats + 1;
            local mat_cost = MAT_COSTS[mats[index]]
            if (not mat_cost) then mat_cost = 1 end
            local ratio = math.min(10, max_ilvl - itemLvl) / ilvl_diff
            local count = math.floor(ratio * BASE_MAT_COUNT *
                -- quality_mult_mat[quality + 1] * -- temporary removed
                mat_inventory_mult[inventoryType + 1] / mat_cost + 0.5)
            table.insert(new_mats,
                { material = mats[index], count = count })

            current_ilvl = max_ilvl
        end
    end

    return new_mats
end

function CastItemUpgrade(bagId, slotId, desiredItemLevel, desiredQuality)
    AIO.Msg():Add("CastItemUpgrade", bagId, slotId, desiredItemLevel,
        desiredQuality):Send()
end

function NextItemUpgrade(itemlvl, quality)
    local resItemLvl = itemlvl
    if itemlvl < 25 then
        resItemLvl = 25
    elseif itemlvl < 35 then
        resItemLvl = 35
    elseif itemlvl < 45 then
        resItemLvl = 45
    elseif itemlvl < 55 then
        resItemLvl = 55
    elseif itemlvl < 65 then
        resItemLvl = 65
        if quality < 3 then
            quality = quality + 1
        end
    end

    if quality > 4 then quality = 4 end

    return resItemLvl, quality;
end

AIO.RegisterEvent("SetBracketMaterials", SetBracketMaterials)
AIO.RegisterEvent("SetBracketMaterialsCosts", SetBracketMaterialCosts)
AIO.RegisterEvent("CastItemUpgrade", CastItemUpgrade)
