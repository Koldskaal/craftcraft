local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

-- Item add
hooksecurefunc("SetItemRef", function(link)
    local linkType, addon, param1 = strsplit(":", link)
    if linkType == "item" and addon == "additem" then
        if (IsModifiedClick()) then
            SendChatMessage(".additem " .. param1 .. " 10");
        else
            SendChatMessage(".additem " .. param1);
        end
    end
    if linkType == "spell" then
        if addon == "learn" then
            SendChatMessage(".learn " .. param1);
        end

        if addon == "unlearn" then
            SendChatMessage(".unlearn " .. param1);
        end
    end
end)
