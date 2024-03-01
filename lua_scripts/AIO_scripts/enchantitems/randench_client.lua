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

ENCH_CACHE = ENCH_CACHE or {}

AIO.AddSavedVar("ENCH_CACHE")
