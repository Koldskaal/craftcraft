function bitwiseAND(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then -- Check if both are odd
            result = result + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
    end
    return result
end

function lshift(x, by)
    return x * 2 ^ by
end

function rshift(x, by)
    return math.floor(x / 2 ^ by)
end

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

ITEM_IDS_INVTYPE = {
    [0] = "INVTYPE_NON_EQUIP",
    [1] = "INVTYPE_HEAD",
    [2] = "INVTYPE_NECK",
    [3] = "INVTYPE_SHOULDER",
    [4] = "INVTYPE_BODY",
    [5] = "INVTYPE_CHEST",
    [6] = "INVTYPE_WAIST",
    [7] = "INVTYPE_LEGS",
    [8] = "INVTYPE_FEET",
    [9] = "INVTYPE_WRIST",
    [10] = "INVTYPE_HAND",
    [11] = "INVTYPE_FINGER",
    [12] = "INVTYPE_TRINKET",
    [13] = "INVTYPE_WEAPON",
    [14] = "INVTYPE_SHIELD",
    [15] = "INVTYPE_RANGED",
    [16] = "INVTYPE_CLOAK",
    [17] = "INVTYPE_2HWEAPON",
    [18] = "INVTYPE_BAG",
    [19] = "INVTYPE_TABARD",
    [20] = "INVTYPE_ROBE",
    [21] = "INVTYPE_WEAPONMAINHAND",
    [22] = "INVTYPE_WEAPONOFFHAND",
    [23] = "INVTYPE_HOLDABLE",
    [24] = "INVTYPE_THROWN",
    [25] = "INVTYPE_AMMO",
    [26] = "INVTYPE_RANGEDRIGHT",
    [27] = "INVTYPE_QUIVER",
    [28] = "INVTYPE_RELIC",
}

function printTable(t)
    local printTable_cache = {}

    local function sub_printTable(t, indent)
        if (printTable_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            printTable_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent ..
                            "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_printTable(val,
                            indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent ..
                            string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_printTable(t, "  ")
        print("}")
    else
        sub_printTable(t, "  ")
    end
end

function getItem(player, bagId, slotId)
    if (bagId == 0) then
        bagId = 255
        slotId = slotId + 23
    end
    if (bagId ~= 255) then
        bagId = bagId + 18
    end
    if (bagId == -1) then return nil end

    return player:GetItemByPos(bagId, slotId - 1);
end

-- requires a weight in the item
function weightedRandom(items)
    local totalWeight = 0
    for i, item in ipairs(items) do
        totalWeight = totalWeight + item.weight
    end

    local rand = math.random() * totalWeight
    for i, item in ipairs(items) do
        rand = rand - item.weight
        if rand <= 0 then
            return item.value
        end
    end
end

function randomArray(items)
    return items[math.random(#items)]
end

function getRateBracket(itemlvl)
    if itemlvl < 25 then
        return 1
    elseif itemlvl < 35 then
        return 2
    elseif itemlvl < 45 then
        return 3
    elseif itemlvl < 55 then
        return 4
    elseif itemlvl < 65 then
        return 5
    end

    return 6
end
