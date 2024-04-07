local AIO = AIO or require("AIO");

if AIO.AddAddon() then
    return
end
local handler = AIO.AddHandlers("random_enchant", {})


function handler.SetEnchantInfo(player, info)
    for i = 1, 3, 1 do
        if info[i] then
            ENCH_CACHE[info[i].enchant_id] = info[i]
        end
    end
end

function RequestEnchantInfo(bagId, slotId)
    AIO.Handle("random_enchant", "EnchantsRequest", bagId, slotId);
end

function RollRandomEnchant(bagId, slotId, slot)
    AIO.Handle("random_enchant", "RollEnchant", bagId, slotId, slot);
end

function SelfRepair(bagId, slotId)
    local link = nil
    local durability, maxDurability = nil, nil;
    if bagId == 255 then
        link = GetInventoryItemLink("player", slotId);
        durability, maxDurability = GetInventoryItemDurability(slotId);
    else
        link = GetContainerItemLink(bagId, slotId);
        durability, maxDurability = GetContainerItemDurability(bagId, slotId);
    end
    if not link then return end
    if durability == maxDurability then return end

    local ilvl, _ = select(4, GetItemInfo(link));
    local cost = maxDurability * ilvl * 2;

    if (cost > GetMoney()) then return end

    AIO.Handle("random_enchant", "SelfRepair", bagId, slotId);
    -- later will check if we have the resources to repair before playing sound
    PlaySound(7994)
end

ENCH_CACHE = ENCH_CACHE or {}

AIO.AddSavedVar("ENCH_CACHE")
