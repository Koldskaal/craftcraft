local MenuId = 10000 -- Unique ID to recognice player gossip menu among others
local MenuId2 = 10001
-- NPC Entry ID to match
local NPC_ENTRY_ID = 201001

-- Function to display the gossip menu
local function OnGossipHello(event, player, object)
    local playerSecondaryClass = player:GetSecondaryClass()
    player:GossipClearMenu()
    if playerSecondaryClass == 0 then
        player:GossipSetText("You $r! Only one head? Hmm.. If head big enough, maybe it fit the whole teachings. But your head is small..", 1)
        player:GossipMenuAddItem(0, "Teach me a second class!", 0, 1)
        player:GossipSendMenu(1, object, MenuId)

    else
        player:GossipSetText("You $r! You already got my teachings! Go play by yourself now!", 1)
        player:GossipSendMenu(1, object, MenuId)
    end
end
-- end

-- Function to handle the gossip menu selection
local function OnGossipSelect(event, player, object, sender, intid, code)
    if object:GetEntry() == NPC_ENTRY_ID and intid == 1 then
        player:GossipClearMenu()
        player:GossipSetText("Okay $r. I will try put my teachings in your head.", 2)
        local playerClass = player:GetClass()
        for i = 1, 11, 1 do
            if ClassName(i) then
                if(playerClass ~= i) then
                    if( i ~= 6) then
                        player:GossipMenuAddItem(0, ClassName(i), 0, i+1,false, "Are you sure you want to be a "..tostring(ClassName(i)).."?")
                    end
                end
            end
        end
        player:GossipSendMenu(2, object, MenuId2)

    else
        player:SetSecondaryClass(intid-1)
        player:SendServerResponse("DualClass", 1, player:GetSecondaryClass())
        player:GossipComplete()
    end
end


-- Register the gossip event handlers
RegisterCreatureGossipEvent(NPC_ENTRY_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ENTRY_ID, 2, OnGossipSelect)
