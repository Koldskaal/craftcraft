require("SMH")
local md5 = require 'md5'
local config = {
    Prefix = "DualClass",
    Functions = {
        [1] = "OnClassSecondRequest",
        [2] = "OnTalentCacheRequest",
        [3] = "OnPlayerTalentsRequest",
        [4] = "OnLearnTalentRequest"
    }
}

local tabdata = {
    Paladin = {
        [1] = { "Holy", "Interface\\Icons\\Spell_Holy_HolyBolt", 0, "PaladinHoly", 0, 382 },
        [2] = { "Protection", "Interface\\Icons\\Spell_Holy_DevotionAura", 0,
            "PaladinProtection", 0, 383 },
        [3] = { "Retribution", "Interface\\Icons\\Spell_Holy_AuraOfLight", 0,
            "PaladinCombat", 0, 381 }
    },
    Shaman = {
        [1] = { "Elemental", "Interface\\Icons\\Spell_Nature_Lightning", 0,
            "ShamanElementalCombat", 0, 261 },
        [2] = { "Enhancement", "Interface\\Icons\\Spell_Nature_LightningShield", 0,
            "ShamanEnhancement", 0, 263 },
        [3] = { "Restoration", "Interface\\Icons\\Spell_Nature_MagicImmunity", 0,
            "ShamanRestoration", 0, 262 }
    },
    Warrior = {
        [1] = { "Arms", "Interface\\Icons\\Ability_Rogue_Eviscerate", 0,
            "WarriorArms", 0, 161 },
        [2] = { "Fury", "Interface\\Icons\\Ability_Warrior_InnerRage", 0,
            "WarriorFury", 0, 164 },
        [3] = { "Protection", "Interface\\Icons\\INV_Shield_06", 0,
            "WarriorProtection", 0, 163 }
    },
    Mage = {
        [1] = { "Arcane", "Interface\\Icons\\Spell_Holy_MagicalSentry", 0,
            "MageArcane", 0, 81 },
        [2] = { "Fire", "Interface\\Icons\\Spell_Fire_FireBolt02", 0, "MageFire", 0, 41 },
        [3] = { "Frost", "Interface\\Icons\\Spell_Frost_FrostBolt02", 0,
            "MageFrost", 0, 61 }
    },
    Priest = {
        [1] = { "Discipline", "Interface\\Icons\\Spell_Holy_WordFortitude", 0,
            "PriestDiscipline", 0, 201 },
        [2] = { "Holy", "Interface\\Icons\\Spell_Holy_GuardianSpirit", 0,
            "PriestHoly", 0, 202 },
        [3] = { "Shadow", "Interface\\Icons\\Spell_Shadow_ShadowWordPain", 0,
            "PriestShadow", 0, 203 }
    },
    Rogue = {
        [1] = { "Assassination", "Interface\\Icons\\Ability_Rogue_Eviscerate", 0,
            "RogueAssassination", 0, 182 },
        [2] = { "Combat", "Interface\\Icons\\Ability_BackStab", 0, "RogueCombat", 0, 181 },
        [3] = { "Subtlety", "Interface\\Icons\\Ability_Stealth", 0,
            "RogueSubtlety", 0, 183 }
    },
    Druid = {
        [1] = { "Balance", "Interface\\Icons\\Spell_Nature_StarFall", 0,
            "DruidBalance", 0, 283 },
        [2] = { "Feral Combat", "Interface\\Icons\\Ability_Racial_BearForm", 0,
            "DruidFeralCombat", 0, 281 },
        [3] = { "Restoration", "Interface\\Icons\\Spell_Nature_HealingTouch", 0,
            "DruidRestoration", 0, 282 }
    },
    Hunter = {
        [1] = { "Beast Mastery", "Interface\\Icons\\Ability_Hunter_BeastTaming", 0,
            "HunterBeastMastery", 0, 361 },
        [2] = { "Marksmanship", "Interface\\Icons\\Ability_Marksmanship", 0,
            "HunterMarksmanship", 0, 363 },
        [3] = { "Survival", "Interface\\Icons\\Ability_Hunter_SwiftStrike", 0,
            "HunterSurvival", 0, 362 }
    },
    Warlock = {
        [1] = { "Affliction", "Interface\\Icons\\Spell_Shadow_DeathCoil", 0,
            "WarlockCurses", 0, 302 },
        [2] = { "Demonology", "Interface\\Icons\\Spell_Shadow_Metamorphosis", 0,
            "WarlockSummoning", 0, 303 },
        [3] = { "Destruction", "Interface\\Icons\\Spell_Shadow_RainOfFire", 0,
            "WarlockDestruction", 0, 301 }
    },
    DeathKnight = {
        [1] = { "Blood", "Interface\\Icons\\Spell_Deathknight_BloodPresence", 0,
            "DeathKnightBlood", 0, 398 },
        [2] = { "Frost", "Interface\\Icons\\Spell_Deathknight_FrostPresence", 0,
            "DeathKnightFrost", 0, 399 },
        [3] = { "Unholy", "Interface\\Icons\\Spell_Deathknight_UnholyPresence", 0,
            "DeathKnightUnholy", 0, 400 }
    },
    Temp = {
        [1] = {},
        [2] = {},
        [3] = {}
    }
}

local talentMap = {};
local crc = 0;

function ClassName(class)
    if class == 1 then
        return "Warrior"
    end
    if class == 2 then
        return "Paladin"
    end
    if class == 3 then
        return "Hunter"
    end
    if class == 4 then
        return "Rogue"
    end
    if class == 5 then
        return "Priest"
    end
    if class == 6 then
        return "DeathKnight"
    end
    if class == 7 then
        return "Shaman"
    end
    if class == 8 then
        return "Mage"
    end
    if class == 9 then
        return "Warlock"
    end
    if class == 10 then
        return nil
    end
    if class == 11 then
        return "Druid"
    end

    return nil
end

function OnClassSecondRequest(player, argTable)
    player:SendBroadcastMessage(tostring("Recieved"));
    player:SendServerResponse(config.Prefix, 1, player:GetSecondaryClass());
end

function OnTalentCacheRequest(player, argTable)
    OnPlayerTalentsRequest(player, argTable);
    local hash = argTable[1];
    local force = argTable[2];
    player:SendBroadcastMessage("Sending talentMap");
    if hash == nil or hash ~= crc or force == true then
        player:SendServerResponse(config.Prefix, 2, talentMap, crc);
    end
end

function OnLearnTalentRequest(player, argTable)
    local talentID = argTable[1]
    local rank = argTable[2]

    player:LearnTalent(talentID, rank);
end

function OnPlayerTalentsRequest(player, argTable)
    local playerTalentRanks = {};
    local sClassTabs = tabdata[ClassName(player:GetSecondaryClass())];
    local classTabs = tabdata[ClassName(player:GetClass())];

    local tabs = {};
    if sClassTabs then
        for _, value in pairs(sClassTabs) do
            table.insert(tabs, value[6]);
        end
    end
    for _, value in pairs(classTabs) do
        table.insert(tabs, value[6]);
    end

    local count = 0
    for _, tabID in ipairs(tabs) do
        for roworcount, colData in pairs(talentMap[tabID]) do
            if roworcount ~= "count" then
                for col, data in pairs(colData) do
                    local rank = 0;
                    local maxRank = 0;
                    for index, spellID in ipairs(data["spells"]) do
                        if spellID then
                            maxRank = maxRank + 1;
                        end

                        if spellID and player:HasTalent(spellID, 0) then
                            rank = index;
                        end
                    end

                    playerTalentRanks[data["talentID"]] = {
                        rank = rank,
                        maxRank = maxRank
                    }
                    count = count + 1
                end
            end
        end
    end

    player:SendServerResponse(config.Prefix, 3, playerTalentRanks);
    --
end

function CreateTalentMaps()
    for i = 0, GetTalentCount() do
        local row, col, tabID, dependsOn, minRankOnDepend, rank1, rank2, rank3, rank4, rank5 =
            GetTalentEntry(i);
        if (row ~= nil) then
            row = row + 1;
            col = col + 1;
            if (talentMap[tabID] == nil) then talentMap[tabID] = {} end
            if (talentMap[tabID][row] == nil) then talentMap[tabID][row] = {} end
            if (talentMap[tabID][row][col] == nil) then talentMap[tabID][row][col] = {} end
            if (talentMap[tabID]["count"] == nil) then talentMap[tabID]["count"] = 0 end

            local spells = {};
            if (rank1 ~= nil) then table.insert(spells, rank1) end
            if (rank2 ~= nil) then table.insert(spells, rank2) end
            if (rank3 ~= nil) then table.insert(spells, rank3) end
            if (rank4 ~= nil) then table.insert(spells, rank4) end
            if (rank5 ~= nil) then table.insert(spells, rank5) end
            -- print(row, col, i)
            talentMap[tabID][row][col]["spells"] = spells;
            talentMap[tabID][row][col]["dependsOn"] = dependsOn;
            talentMap[tabID][row][col]["dependsOnRank"] = minRankOnDepend;
            talentMap[tabID][row][col]["talentID"] = i;
            talentMap[tabID]["count"] = talentMap[tabID]["count"] + 1;
        end
    end
    local tab = serializeTable(talentMap);
    crc = hash(tab);
end

CreateTalentMaps()
RegisterClientRequests(config)

PLAYER_EVENT_ON_LEARN_TALENTS = 39  -- (event, player, talentId, talentRank, spellid)
PLAYER_EVENT_ON_TALENTS_CHANGE = 16 -- (event, player, points)
function SendTalentUpdate(event, player, talentId, talentRank, spellid)
    player:SendServerResponse(config.Prefix, 4, talentId, talentRank);
end

function SendTalentResetUpdate(event, player, points)
    if points == player:GetLevel() then -- Hack to only activate on talent reset
        OnPlayerTalentsRequest(player);
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_LEARN_TALENTS, SendTalentUpdate)
RegisterPlayerEvent(PLAYER_EVENT_ON_TALENTS_CHANGE, SendTalentResetUpdate)
