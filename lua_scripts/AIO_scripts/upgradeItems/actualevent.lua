local AIO = AIO or require("AIO")


if AIO.AddAddon() then
    local crc32 = require("crc32lua").crc32
    local Smallfolk = Smallfolk or require("smallfolk")

    -- Brackets are split by 10 lvls. 1-20 is split into two as well
    local function sortedKeys(query, sortFunction)
        local keys, len = {}, 0
        for k, _ in pairs(query) do
            len = len + 1
            keys[len] = k
        end
        table.sort(keys, sortFunction)
        return keys
    end

    local brackets = {
        [1] = {
            bracket = "lvl_bracket1",
            max_level = 9,
            min_level = 0,
            materials = {},
        },
        [2] = {
            bracket = "lvl_bracket1",
            max_level = 19,
            min_level = 10,
            materials = {},
        },
        [3] = {
            bracket = "lvl_bracket2",
            max_level = 29,
            min_level = 20,
            materials = {},
        },
        [4] = {
            bracket = "lvl_bracket3",
            max_level = 39,
            min_level = 30,
            materials = {},
        },
        [5] = {
            bracket = "lvl_bracket4",
            max_level = 49,
            min_level = 40,
            materials = {},
        },
        [6] = {
            bracket = "lvl_bracket5",
            max_level = 59,
            min_level = 50,
            materials = {},
        },
    }

    local mat_costs = {}

    for _, value in ipairs(brackets) do
        local Q = WorldDBQuery("SELECT item FROM reference_loot_template " ..
            "JOIN item_template ON item_template.entry = reference_loot_template.item " ..
            "WHERE reference_loot_template.entry IN (SELECT " ..
            value["bracket"] .. " FROM creature_template " ..
            "JOIN creature_template_addon ON creature_template_addon.entry = creature_template.entry " ..
            "JOIN craftcraft_aura_loot_template ON creature_template_addon.auras LIKE CONCAT('%', craftcraft_aura_loot_template.aura_id, '%') " ..
            "WHERE maxlevel >= " ..
            value["min_level"] ..
            " and maxlevel <= " ..
            value["max_level"] ..
            " AND creature_template.rank < 2) AND item > 0 AND class = 7")
        if Q then
            repeat
                local entry = Q:GetUInt32(0)
                table.insert(value["materials"], entry)
            until not Q:NextRow()
        end
        --print(#value["materials"])
    end

    local Q = WorldDBQuery("SELECT entry, cost from craftcraft_material_costs")
    if Q then
        repeat
            local entry, cost = Q:GetUInt32(0), Q:GetFloat(1)
            mat_costs[entry] = cost
        until not Q:NextRow()
    end

    local crc1 = crc32(Smallfolk.dumps(sortedKeys(brackets)))
    mat_costs["crc"] = crc32(Smallfolk.dumps(sortedKeys(mat_costs)))

    local function SendBracketMaterials(player, crc_mats, crc_costs)
        if crc_mats ~= crc1 then --compare cached
            AIO.Msg():Add("SetBracketMaterials", brackets, crc1):Send(player);
        end

        if crc_costs ~= mat_costs["crc"] then --compare cached
            AIO.Msg():Add("SetBracketMaterialsCosts", mat_costs):Send(
                player);
        end
    end

    function CastItemUpgrade(player, bagId, slotId, desiredQuality,
                             desiredItemLevel)
        -- if (not player:HasSpell(100012)) then
        --     -- Could check if learned
        -- end

        if (bagId == 0) then
            bagId = 255
            slotId = slotId + 23
        end
        if (bagId ~= 255) then
            bagId = bagId + 18
        end
        if (bagId == -1) then return end

        local item = player:GetItemByPos(bagId, slotId - 1)
        if item:GetItemLevel() >= player:GetLevel() + 5 then
            player:SendBroadcastMessage(
                "Your level is too low to upgrade this item. (temp message)")
            return
        end

        if (desiredItemLevel > player:GetLevel() + 5) then
            player:SendBroadcastMessage(
                "Your level is too low to fully upgrade, capping at ilvl" ..
                player:GetLevel() + 5)


            player:CastCustomSpell(nil, 100012, false, player:GetLevel() + 5,
                desiredQuality, nil, item, player:GetGUID())
            return
        end

        player:CastCustomSpell(nil, 100012, false, desiredItemLevel,
            desiredQuality, nil, item, player:GetGUID())
    end

    AIO.RegisterEvent("RequestBracketMaterials", SendBracketMaterials)
else
    assert(not CastItemUpgrade,
        "CastItemUpgrade: CastItemUpgrade is already defined")

    function CastItemUpgrade(bagId, slotId, desiredQuality, desiredItemLevel)
        AIO.Msg():Add("CastItemUpgrade", bagId, slotId, desiredQuality,
            desiredItemLevel):Send()
    end

    local function SetBracketMaterials(player, brackets, crc)
        MAT_BRACKETS = brackets
        MAT_BRACKETS["crc"] = crc
        print("Received mat brackets")
    end

    local function SetBracketMaterialCosts(player, mat_costs)
        MAT_COSTS = mat_costs
        print("Received mat costs")
    end

    MAT_BRACKETS = MAT_BRACKETS or {}
    MAT_COSTS = MAT_COSTS or {}
    AIO.AddSavedVar("MAT_BRACKETS")
    AIO.AddSavedVar("MAT_COSTS")

    AIO.RegisterEvent("SetBracketMaterials", SetBracketMaterials)
    AIO.RegisterEvent("SetBracketMaterialsCosts", SetBracketMaterialCosts)

    AIO.Msg():Add("RequestBracketMaterials", MAT_BRACKETS["crc"],
        MAT_COSTS["crc"]):Send()

    local function StringHash(text)
        local counter = 1
        local len = string.len(text)
        for i = 1, len, 3 do
            counter = math.fmod(counter * 8161, 4294967279) + -- 2^32 - 17: Prime!
                (string.byte(text, i) * 16776193) +
                ((string.byte(text, i + 1) or (len - i + 256)) * 8372226) +
                ((string.byte(text, i + 2) or (len - i + 256)) * 3932164)
        end
        return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
    end
    print(StringHash("string"))
    print(#MAT_COSTS)
    for index, value in ipairs(MAT_COSTS) do
        print(index, value)
    end -- DOESNT WORK YET
end
AIO.RegisterEvent("CastItemUpgrade", CastItemUpgrade)
