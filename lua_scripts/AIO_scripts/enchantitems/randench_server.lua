local AIO = AIO or require("AIO");

if not AIO.AddAddon() then
    return
end

require("util");

local rarity_droprates = {
    [1] = { [1] = 0.75, [2] = .25, [3] = 0, [4] = 0, [5] = 0 },          --1-24
    [2] = { [1] = 0.55, [2] = .30, [3] = 0.15, [4] = 0, [5] = 0 },       --25-34
    [3] = { [1] = 0.30, [2] = .40, [3] = 0.25, [4] = 0.05, [5] = 0 },    --35-44
    [4] = { [1] = 0.19, [2] = .30, [3] = 0.35, [4] = 0.10, [5] = 0.01 }, --45-54
    [5] = { [1] = 0.10, [2] = .20, [3] = 0.25, [4] = 0.35, [5] = 0.10 }, --55-64
    [6] = { [1] = 0.05, [2] = .10, [3] = 0.20, [4] = 0.40, [5] = 0.25 }, --65+
}
local rarity_count = 5

local handler = AIO.AddHandlers("random_enchant", {});
local enchants_pool = {}
for i = 1, 26, 1 do
    enchants_pool[i] = {}
    for j = 1, rarity_count, 1 do
        enchants_pool[i][j] = {}
    end
end

local enchant_info = {}

local Q = WorldDBQuery("SELECT * from craftcraft_random_enchants")
if Q then
    repeat
        local entry, name, iconPath, mask, rarity = Q:GetUInt32(0),
            Q:GetString(1), Q:GetString(2), Q:GetUInt32(3), Q:GetUInt8(4);

        if mask == 0 then mask = 0xffffffffff end
        for i = 1, 26, 1 do
            if bitwiseAND(mask, lshift(1, i)) > 0 then
                if (rarity < rarity_count) then
                    table.insert(enchants_pool[i][rarity + 1], entry)
                else
                    print("ERROR: entry", entry,
                        " has rarity above limit of 3. Skipping");
                end
            end
        end

        enchant_info[entry] = {
            enchant_id = entry,
            name = name,
            icon = iconPath,
            rarity = rarity
        }
    until not Q:NextRow()
end


function handler.EnchantsRequest(player, bagId, slotId)
    local item = getItem(player, bagId, slotId);
    if not item then return end;

    local info = {}
    for i = 2, 4, 1 do
        local ench = item:GetEnchantmentId(i);

        if ench then -- no check if enchant_info has the info
            table.insert(info, enchant_info[ench]);
        else
            table.insert(info, nil);
        end
    end
    -- printTable(info)
    -- Send the information
    AIO.Handle(player, "random_enchant", "SetEnchantInfo", info);
end

local function getRandomEnchant(inventoryType, ilvl)
    local rarities = {}
    local bracket = getRateBracket(ilvl)
    for i = 1, rarity_count, 1 do
        if enchants_pool[inventoryType][i] then
            table.insert(rarities,
                { weight = rarity_droprates[bracket][i], value = i });
        end
    end

    return randomArray(enchants_pool[inventoryType][weightedRandom(rarities)])
end

function handler.RollEnchant(player, bagId, slotId, slot)
    local item = getItem(player, bagId, slotId);
    if not item then return end;

    if item:GetQuality() <= slot then
        return
    end

    if item:IsBroken() then
        return
    end


    local curr_enchant = item:GetEnchantmentId(slot + 1);
    local enchant_id = curr_enchant;
    local tries = 0;
    while curr_enchant == enchant_id do
        enchant_id = getRandomEnchant(item:GetInventoryType(),
            item:GetItemLevel());
        tries = tries + 1;
        if tries >= 100 then
            print("too many tries")
            return
        end -- too many tries might just freeze
    end


    item:SetEnchantment(enchant_id, slot + 1)

    -- minus durability
    player:DurabilityPointsLoss(item, 5); -- 5 points for now
    -- send update
    handler.EnchantsRequest(player, bagId, slotId)
end
