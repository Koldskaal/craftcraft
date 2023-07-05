local AIO = AIO or require("AIO")

local HandlePingPong
if AIO.AddAddon() then
    function CastAOE(player, spellid)
        if (player:HasSpell(spellid)) then
            player:CastSpellAoF(player:GetX(), player:GetY(), player:GetZ(), spellid, false)
        end
    end
else
    -- just incase we are overwriting someone's function ..
    assert(not CastAOE, "CastAOE: CastAOE is already defined")
    
    function CastAOE(spellid)
        AIO.Msg():Add("CastAOE", spellid):Send()
    end
end

AIO.RegisterEvent("CastAOE", CastAOE)