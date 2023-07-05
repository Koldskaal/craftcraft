local PLAYER_EVENT_ON_SPELL_CAST = 5

function enableWandProc(event, player, spell, skipCheck)

end


RegisterPlayerEvent(PLAYER_EVENT_ON_SPELL_CAST, enableWandProc)