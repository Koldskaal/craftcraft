local AIO = AIO or require("AIO")

if AIO.AddAddon() then

    function UpdateComboTarget(player)
        -- Saved for if I have to convert guid to creature at some point
        -- local lower = tonumber(guid:sub(13), 16);
        -- local entry = tonumber(guid:sub(7, 12), 16);
        -- local target = player:GetMap():GetWorldObject(GetUnitGUID(lower, entry));
        local target = player:GetMap():GetWorldObject(player:GetSelection():GetGUID());
        player:AddComboPoints(target, 0);
    end
else
    -- just incase we are overwriting someone's function ..
    assert(not UpdateComboTarget, "UpdateComboTarget: UpdateComboTarget is already defined");
    
    local comboPoints = 0;
    local f = CreateFrame("Frame");

    f:RegisterEvent("PLAYER_TARGET_CHANGED");
    f:RegisterEvent("UNIT_COMBO_POINTS");

    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "PLAYER_TARGET_CHANGED") then
            if comboPoints > 0 then UpdateComboTarget(); end
        elseif (event == "UNIT_COMBO_POINTS") then
            comboPoints = GetComboPoints(PlayerFrame.unit, "target");
        end
    end)
    
    function UpdateComboTarget()
        AIO.Msg():Add("UpdateComboTarget"):Send();
    end
end

AIO.RegisterEvent("UpdateComboTarget", UpdateComboTarget);