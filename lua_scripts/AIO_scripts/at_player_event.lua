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
<<<<<<< HEAD

    SPELL_FAILED_CUSTOM_ERROR_80 = "Wand flick requires a long spell cast"
=======
>>>>>>> combo points retained and wand flick
    
    function CastAOE(spellid)
        AIO.Msg():Add("CastAOE", spellid):Send()
    end
end

AIO.RegisterEvent("CastAOE", CastAOE)