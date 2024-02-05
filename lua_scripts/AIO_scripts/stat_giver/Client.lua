local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local MyHandlers = AIO.AddHandlers("upgradeItems", {})

local frameAttributes = CreateFrame("Frame", "frameAttributes", UIParent)
frameAttributes:SetSize(200, 300)
frameAttributes:SetMovable(true)
frameAttributes:EnableMouse(true)
frameAttributes:RegisterForDrag("LeftButton")
frameAttributes:SetPoint("CENTER")
frameAttributes:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 20,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
-- Drag & Drop
frameAttributes:SetScript("OnDragStart", frameAttributes.StartMoving)
frameAttributes:SetScript("OnHide", frameAttributes.StopMovingOrSizing)
frameAttributes:SetScript("OnDragStop", frameAttributes.StopMovingOrSizing)
frameAttributes:Hide()

-- Close button
local buttonAttributesClose = CreateFrame("Button", "buttonAttributesClose",
    frameAttributes, "UIPanelCloseButton")
buttonAttributesClose:SetPoint("TOPRIGHT", -5, -5)
buttonAttributesClose:EnableMouse(true)
buttonAttributesClose:SetSize(27, 27)

-- Title bar
local frameAttributesTitleBar = CreateFrame("Frame", "frameAttributesTitleBar",
    frameAttributes, nil)
frameAttributesTitleBar:SetSize(135, 25)
frameAttributesTitleBar:SetBackdrop(
    {
        bgFile = "Interface/CHARACTERFRAME/UI-Party-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        edgeSize = 16,
        tileSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
frameAttributesTitleBar:SetPoint("TOP", 0, 9)

local fontAttributesTitleText = frameAttributesTitleBar:CreateFontString(
    "fontAttributesTitleText")
fontAttributesTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontAttributesTitleText:SetSize(190, 5)
fontAttributesTitleText:SetPoint("CENTER", 0, 0)
fontAttributesTitleText:SetText("|cffFFC125Attribute Points|r")


-- local itemSlot = CreateFrame("Button", "MyItemAddonItemSlot", frameAttributes,
--     "ItemButtonTemplate")
-- itemSlot:SetSize(40, 40)
-- itemSlot:SetPoint("CENTER")
-- itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
-- itemSlot:SetScript("OnClick", function(self, button)
--     -- Handle clicks on the item slot
--     if button == "LeftButton" then
--         -- Handle left-click
--         print("Left-clicked on item slot")
--     elseif button == "RightButton" then
--         -- Handle right-click
--         print("Right-clicked on item slot")
--     end
-- end)

-- -- Enable dragging for the item slot
-- itemSlot:SetScript("OnReceiveDrag", function(self)
--     local type, id, link = GetCursorInfo()
--     print(string.find(link,
--         "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))
--     printable = gsub(link, "\124", "\124\124");
--     ChatFrame1:AddMessage("Here's what it really looks like: \"" ..
--         printable .. "\"");
--     if type == "item" then
--         -- An item is being dragged onto the item slot
--         print("Item dragged into the item slot:", id, link, type)

--         itemIcon = GetItemIcon(id)
--         -- Add your logic to handle the dragged item (e.g., display the icon)
--         self:SetNormalTexture(itemIcon)
--     end
--     ClearCursor()
-- end)






-- Attribute points left
local fontAttributesPointsLeft = frameAttributes:CreateFontString(
    "fontAttributesPointsLeft")
fontAttributesPointsLeft:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesPointsLeft:SetSize(50, 5)
fontAttributesPointsLeft:SetPoint("TOPLEFT", 107, -25)
fontAttributesPointsLeft:Hide()

-- Clear
local ClearAttributes = CreateFrame("Button", "ClearAttributes",
    frameAttributes, "GameMenuButtonTemplate")
ClearAttributes:SetSize(30, 20)
ClearAttributes:SetPoint("TOPLEFT", 117, -18)
ClearAttributes:SetText("Reset")
ClearAttributes:EnableMouse(true)
ClearAttributes:SetScript("OnMouseUp",
    function()
        AIO.Handle("upgradeItems", "ClearAttributes")
    end)

-- Strength
local fontAttributesStrength = frameAttributes:CreateFontString(
    "fontAttributesStrength")
fontAttributesStrength:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesStrength:SetSize(137, 5)
fontAttributesStrength:SetPoint("TOPLEFT", -20, -45)
fontAttributesStrength:SetText("|cFF000000Strength|r")

local fontAttributesStrengthValue = frameAttributes:CreateFontString(
    "fontAttributesStrengthValue")
fontAttributesStrengthValue:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesStrengthValue:SetSize(50, 5)
fontAttributesStrengthValue:SetPoint("TOPLEFT", 107, -45)

local buttonAttributesIncreaseStrength = CreateFrame("Button",
    "buttonAttributesIncreaseStrength", frameAttributes, nil)
buttonAttributesIncreaseStrength:SetSize(20, 20)
buttonAttributesIncreaseStrength:SetPoint("TOPLEFT", 144, -39)
buttonAttributesIncreaseStrength:EnableMouse(true)
buttonAttributesIncreaseStrength:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseStrength:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseStrength:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseStrength:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 1, points)
    end)

local buttonAttributesDecreaseStrength = CreateFrame("Button",
    "buttonAttributesDecreaseStrength", frameAttributes, nil)
buttonAttributesDecreaseStrength:SetSize(20, 20)
buttonAttributesDecreaseStrength:SetPoint("TOPLEFT", 104, -39)
buttonAttributesDecreaseStrength:EnableMouse(true)
buttonAttributesDecreaseStrength:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseStrength:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseStrength:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseStrength:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 1, points)
    end)

-- Agility
local fontAttributesAgility = frameAttributes:CreateFontString(
    "fontAttributesAgility")
fontAttributesAgility:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesAgility:SetSize(137, 5)
fontAttributesAgility:SetPoint("TOPLEFT", -20, -65)
fontAttributesAgility:SetText("|cFF000000Agility|r")

local fontAttributesAgilityValue = frameAttributes:CreateFontString(
    "fontAttributesAgilityValue")
fontAttributesAgilityValue:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesAgilityValue:SetSize(50, 5)
fontAttributesAgilityValue:SetPoint("TOPLEFT", 107, -65)

local buttonAttributesIncreaseAgility = CreateFrame("Button",
    "buttonAttributesIncreaseAgility", frameAttributes, nil)
buttonAttributesIncreaseAgility:SetSize(20, 20)
buttonAttributesIncreaseAgility:SetPoint("TOPLEFT", 144, -59)
buttonAttributesIncreaseAgility:EnableMouse(true)
buttonAttributesIncreaseAgility:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseAgility:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseAgility:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseAgility:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 2, points)
    end)

local buttonAttributesDecreaseAgility = CreateFrame("Button",
    "buttonAttributesDecreaseAgility", frameAttributes, nil)
buttonAttributesDecreaseAgility:SetSize(20, 20)
buttonAttributesDecreaseAgility:SetPoint("TOPLEFT", 104, -59)
buttonAttributesDecreaseAgility:EnableMouse(true)
buttonAttributesDecreaseAgility:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseAgility:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseAgility:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseAgility:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 2, points)
    end)

-- Stamina
local fontAttributesStamina = frameAttributes:CreateFontString(
    "fontAttributesStamina")
fontAttributesStamina:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesStamina:SetSize(137, 5)
fontAttributesStamina:SetPoint("TOPLEFT", -20, -85)
fontAttributesStamina:SetText("|cFF000000Stamina|r")

local fontAttributesStaminaValue = frameAttributes:CreateFontString(
    "fontAttributesStaminaValue")
fontAttributesStaminaValue:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesStaminaValue:SetSize(50, 5)
fontAttributesStaminaValue:SetPoint("TOPLEFT", 107, -85)

local buttonAttributesIncreaseStamina = CreateFrame("Button",
    "buttonAttributesIncreaseStamina", frameAttributes, nil)
buttonAttributesIncreaseStamina:SetSize(20, 20)
buttonAttributesIncreaseStamina:SetPoint("TOPLEFT", 144, -79)
buttonAttributesIncreaseStamina:EnableMouse(true)
buttonAttributesIncreaseStamina:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseStamina:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseStamina:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseStamina:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 3, points)
    end)

local buttonAttributesDecreaseStamina = CreateFrame("Button",
    "buttonAttributesDecreaseStamina", frameAttributes, nil)
buttonAttributesDecreaseStamina:SetSize(20, 20)
buttonAttributesDecreaseStamina:SetPoint("TOPLEFT", 104, -79)
buttonAttributesDecreaseStamina:EnableMouse(true)
buttonAttributesDecreaseStamina:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseStamina:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseStamina:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseStamina:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 3, points)
    end)

-- Intellect
local fontAttributesIntellect = frameAttributes:CreateFontString(
    "fontAttributesIntellect")
fontAttributesIntellect:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesIntellect:SetSize(137, 5)
fontAttributesIntellect:SetPoint("TOPLEFT", -20, -105)
fontAttributesIntellect:SetText("|cFF000000Intellect|r")

local fontAttributesIntellectValue = frameAttributes:CreateFontString(
    "fontAttributesIntellectValue")
fontAttributesIntellectValue:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesIntellectValue:SetSize(50, 5)
fontAttributesIntellectValue:SetPoint("TOPLEFT", 107, -105)

local buttonAttributesIncreaseIntellect = CreateFrame("Button",
    "buttonAttributesIncreaseIntellect", frameAttributes, nil)
buttonAttributesIncreaseIntellect:SetSize(20, 20)
buttonAttributesIncreaseIntellect:SetPoint("TOPLEFT", 144, -99)
buttonAttributesIncreaseIntellect:EnableMouse(true)
buttonAttributesIncreaseIntellect:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseIntellect:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseIntellect:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseIntellect:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 4, points)
    end)

local buttonAttributesDecreaseIntellect = CreateFrame("Button",
    "buttonAttributesDecreaseIntellect", frameAttributes, nil)
buttonAttributesDecreaseIntellect:SetSize(20, 20)
buttonAttributesDecreaseIntellect:SetPoint("TOPLEFT", 104, -99)
buttonAttributesDecreaseIntellect:EnableMouse(true)
buttonAttributesDecreaseIntellect:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseIntellect:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseIntellect:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseIntellect:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 4, points)
    end)

-- Spirit
local fontAttributesSpirit = frameAttributes:CreateFontString(
    "fontAttributesSpirit")
fontAttributesSpirit:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesSpirit:SetSize(137, 5)
fontAttributesSpirit:SetPoint("TOPLEFT", -20, -125)
fontAttributesSpirit:SetText("|cFF000000Spirit|r")

local fontAttributesSpiritValue = frameAttributes:CreateFontString(
    "fontAttributesSpiritValue")
fontAttributesSpiritValue:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesSpiritValue:SetSize(50, 5)
fontAttributesSpiritValue:SetPoint("TOPLEFT", 107, -125)

local buttonAttributesIncreaseSpirit = CreateFrame("Button",
    "buttonAttributesIncreaseSpirit", frameAttributes, nil)
buttonAttributesIncreaseSpirit:SetSize(20, 20)
buttonAttributesIncreaseSpirit:SetPoint("TOPLEFT", 144, -119)
buttonAttributesIncreaseSpirit:EnableMouse(true)
buttonAttributesIncreaseSpirit:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseSpirit:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseSpirit:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseSpirit:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 5, points)
    end)

local buttonAttributesDecreaseSpirit = CreateFrame("Button",
    "buttonAttributesDecreaseSpirit", frameAttributes, nil)
buttonAttributesDecreaseSpirit:SetSize(20, 20)
buttonAttributesDecreaseSpirit:SetPoint("TOPLEFT", 104, -119)
buttonAttributesDecreaseSpirit:EnableMouse(true)
buttonAttributesDecreaseSpirit:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseSpirit:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseSpirit:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseSpirit:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 5, points)
    end)

--Hit10
local fontAttributesHit10 = frameAttributes:CreateFontString(
    "fontAttributesHit10")
fontAttributesHit10:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesHit10:SetSize(137, 5)
fontAttributesHit10:SetPoint("TOPLEFT", -20, -145)
fontAttributesHit10:SetText("|cFF000000Hit10|r")

local fontAttributesHit10Value = frameAttributes:CreateFontString(
    "fontAttributesHit10Value")
fontAttributesHit10Value:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesHit10Value:SetSize(50, 5)
fontAttributesHit10Value:SetPoint("TOPLEFT", 107, -145)

local buttonAttributesIncreaseHit1 = CreateFrame("Button",
    "buttonAttributesIncreaseHit1", frameAttributes, nil)
buttonAttributesIncreaseHit1:SetSize(20, 20)
buttonAttributesIncreaseHit1:SetPoint("TOPLEFT", 144, -139)
buttonAttributesIncreaseHit1:EnableMouse(true)
buttonAttributesIncreaseHit1:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseHit1:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseHit1:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseHit1:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 6, points)
    end)

local buttonAttributesDecreaseHit10 = CreateFrame("Button",
    "buttonAttributesDecreaseHit10", frameAttributes, nil)
buttonAttributesDecreaseHit10:SetSize(20, 20)
buttonAttributesDecreaseHit10:SetPoint("TOPLEFT", 104, -139)
buttonAttributesDecreaseHit10:EnableMouse(true)
buttonAttributesDecreaseHit10:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseHit10:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseHit10:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseHit10:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 6, points)
    end)


--Lucky10
local fontAttributesLucky10 = frameAttributes:CreateFontString(
    "fontAttributesLucky10")
fontAttributesLucky10:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesLucky10:SetSize(137, 5)
fontAttributesLucky10:SetPoint("TOPLEFT", -20, -165)
fontAttributesLucky10:SetText("|cFF000000Lucky10|r")

local fontAttributesLucky10Value = frameAttributes:CreateFontString(
    "fontAttributesLucky10Value")
fontAttributesLucky10Value:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesLucky10Value:SetSize(50, 5)
fontAttributesLucky10Value:SetPoint("TOPLEFT", 107, -165)

local buttonAttributesIncreaseLucky10 = CreateFrame("Button",
    "buttonAttributesIncreaseLucky10", frameAttributes, nil)
buttonAttributesIncreaseLucky10:SetSize(20, 20)
buttonAttributesIncreaseLucky10:SetPoint("TOPLEFT", 144, -159)
buttonAttributesIncreaseLucky10:EnableMouse(true)
buttonAttributesIncreaseLucky10:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseLucky10:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseLucky10:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseLucky10:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 7, points)
    end)

local buttonAttributesDecreaseLucky10 = CreateFrame("Button",
    "buttonAttributesDecreaseLucky10", frameAttributes, nil)
buttonAttributesDecreaseLucky10:SetSize(20, 20)
buttonAttributesDecreaseLucky10:SetPoint("TOPLEFT", 104, -159)
buttonAttributesDecreaseLucky10:EnableMouse(true)
buttonAttributesDecreaseLucky10:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseLucky10:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseLucky10:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseLucky10:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 7, points)
    end)

--Parry20
local fontAttributesParry20 = frameAttributes:CreateFontString(
    "fontAttributesParry20")
fontAttributesParry20:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesParry20:SetSize(137, 5)
fontAttributesParry20:SetPoint("TOPLEFT", -20, -185)
fontAttributesParry20:SetText("|cFF000000Parry20|r")

local fontAttributesParry20Value = frameAttributes:CreateFontString(
    "fontAttributesParry20Value")
fontAttributesParry20Value:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesParry20Value:SetSize(50, 5)
fontAttributesParry20Value:SetPoint("TOPLEFT", 107, -185)

local buttonAttributesIncreaseParry20 = CreateFrame("Button",
    "buttonAttributesIncreaseParry20", frameAttributes, nil)
buttonAttributesIncreaseParry20:SetSize(20, 20)
buttonAttributesIncreaseParry20:SetPoint("TOPLEFT", 144, -179)
buttonAttributesIncreaseParry20:EnableMouse(true)
buttonAttributesIncreaseParry20:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseParry20:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseParry20:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseParry20:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 8, points)
    end)

local buttonAttributesDecreaseParry20 = CreateFrame("Button",
    "buttonAttributesDecreaseParry20", frameAttributes, nil)
buttonAttributesDecreaseParry20:SetSize(20, 20)
buttonAttributesDecreaseParry20:SetPoint("TOPLEFT", 104, -179)
buttonAttributesDecreaseParry20:EnableMouse(true)
buttonAttributesDecreaseParry20:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseParry20:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseParry20:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseParry20:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 8, points)
    end)

--Block5
local fontAttributesBlock5 = frameAttributes:CreateFontString(
    "fontAttributesBlock5")
fontAttributesBlock5:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesBlock5:SetSize(137, 5)
fontAttributesBlock5:SetPoint("TOPLEFT", -20, -205)
fontAttributesBlock5:SetText("|cFF000000Block5|r")

local fontAttributesBlock5Value = frameAttributes:CreateFontString(
    "fontAttributesBlock5Value")
fontAttributesBlock5Value:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesBlock5Value:SetSize(50, 5)
fontAttributesBlock5Value:SetPoint("TOPLEFT", 107, -205)

local buttonAttributesIncreaseBlock5 = CreateFrame("Button",
    "buttonAttributesIncreaseBlock5", frameAttributes, nil)
buttonAttributesIncreaseBlock5:SetSize(20, 20)
buttonAttributesIncreaseBlock5:SetPoint("TOPLEFT", 144, -199)
buttonAttributesIncreaseBlock5:EnableMouse(true)
buttonAttributesIncreaseBlock5:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseBlock5:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseBlock5:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseBlock5:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 9, points)
    end)

local buttonAttributesDecreaseBlock5 = CreateFrame("Button",
    "buttonAttributesDecreaseBlock5", frameAttributes, nil)
buttonAttributesDecreaseBlock5:SetSize(20, 20)
buttonAttributesDecreaseBlock5:SetPoint("TOPLEFT", 104, -199)
buttonAttributesDecreaseBlock5:EnableMouse(true)
buttonAttributesDecreaseBlock5:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseBlock5:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseBlock5:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseBlock5:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 9, points)
    end)


--Dodge20
local fontAttributesDodge20 = frameAttributes:CreateFontString(
    "fontAttributesDodge20")
fontAttributesDodge20:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesDodge20:SetSize(137, 5)
fontAttributesDodge20:SetPoint("TOPLEFT", -20, -225)
fontAttributesDodge20:SetText("|cFF000000Dodge20|r")

local fontAttributesDodge20Value = frameAttributes:CreateFontString(
    "fontAttributesDodge20Value")
fontAttributesDodge20Value:SetFont("Fonts\\FRIZQT__.TTF", 15)
fontAttributesDodge20Value:SetSize(50, 5)
fontAttributesDodge20Value:SetPoint("TOPLEFT", 107, -225)

local buttonAttributesIncreaseDodge20 = CreateFrame("Button",
    "buttonAttributesIncreaseDodge20", frameAttributes, nil)
buttonAttributesIncreaseDodge20:SetSize(20, 20)
buttonAttributesIncreaseDodge20:SetPoint("TOPLEFT", 144, -219)
buttonAttributesIncreaseDodge20:EnableMouse(true)
buttonAttributesIncreaseDodge20:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
buttonAttributesIncreaseDodge20:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesIncreaseDodge20:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
buttonAttributesIncreaseDodge20:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesIncrease", 10, points)
    end)

local buttonAttributesDecreaseDodge20 = CreateFrame("Button",
    "buttonAttributesDecreaseDodge20", frameAttributes, nil)
buttonAttributesDecreaseDodge20:SetSize(20, 20)
buttonAttributesDecreaseDodge20:SetPoint("TOPLEFT", 104, -219)
buttonAttributesDecreaseDodge20:EnableMouse(true)
buttonAttributesDecreaseDodge20:SetNormalTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Up")
buttonAttributesDecreaseDodge20:SetHighlightTexture(
    "Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
buttonAttributesDecreaseDodge20:SetPushedTexture(
    "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down")
buttonAttributesDecreaseDodge20:SetScript("OnMouseUp",
    function()
        local points = 1
        if (IsShiftKeyDown()) then
            points = 10
        end
        AIO.Handle("upgradeItems", "AttributesDecrease", 10, points)
    end)


function MyHandlers.ShowAttributes(player)
    frameAttributes:Show()
end

function MyHandlers.SetStats(player, left, p1, p2, p3, p4, p5, p6, p7, p8, p9,
                             p10, p11)
    fontAttributesStrengthValue:SetText("|cFF000000" .. p1 .. "|r")
    fontAttributesAgilityValue:SetText("|cFF000000" .. p2 .. "|r")
    fontAttributesStaminaValue:SetText("|cFF000000" .. p3 .. "|r")
    fontAttributesIntellectValue:SetText("|cFF000000" .. p4 .. "|r")
    fontAttributesSpiritValue:SetText("|cFF000000" .. p5 .. "|r")
    fontAttributesHit10Value:SetText("|cFF000000" .. p6 .. "|r")
    fontAttributesLucky10Value:SetText("|cFF000000" .. p7 .. "|r")
    fontAttributesParry20Value:SetText("|cFF000000" .. p8 .. "|r")
    fontAttributesBlock5Value:SetText("|cFF000000" .. p9 .. "|r")
    fontAttributesDodge20Value:SetText("|cFF000000" .. p10 .. "|r")
    fontAttributesPointsLeft:SetText("|cFF000000" .. left .. "|r")
end
