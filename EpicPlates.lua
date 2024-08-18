-- Made by Sharpedge_Gaming
-- v1.2 - 11.0.2

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local INFO_POINT            = 'TOP'
local INFO_RELATIVE_POINT   = 'BOTTOM'
local INFO_X                = 0
local INFO_Y                = 0

local NAMEPLATE_ALPHA       = 0.7
local ICON_SIZE             = 20 
local MAX_BUFFS             = 12  
local MAX_DEBUFFS           = 12  
local BUFF_ICON_OFFSET_Y    = 20 
local DEBUFF_ICON_OFFSET_Y  = 10 
local BUFFS_PER_LINE        = 6   
local DEBUFFS_PER_LINE      = 6 
local MAX_ROWS = 3  
local LINE_SPACING_Y        = 9 

if not EpicPlates then
    EpicPlates = LibStub('AceAddon-3.0'):NewAddon('EpicPlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
end

EpicPlates.defaults = {
    profile = {
        iconSize = 20,       -- Default icon size
        timerFontSize = 10,  -- Default timer font size
        timerFont = "Friz Quadrata TT",  -- Default font
        timerFontColor = {1, 1, 1},  -- Default color (white)
        buffIconPositions = {},
        debuffIconPositions = {},
    },
}
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local EpicPlatesTooltip = CreateFrame('GameTooltip', 'EpicPlatesTooltip', nil, 'GameTooltipTemplate')

function EpicPlates:OnEnable()
    C_CVar.SetCVar('nameplateShowAll', '1')
    C_CVar.SetCVar('nameplateShowFriends', '1') 
    C_CVar.SetCVar('nameplateShowFriendlyNPCs', '0') 
    C_CVar.SetCVar('showQuestTrackingTooltips', '1')

    self:RegisterEvent('NAME_PLATE_CREATED')
    self:RegisterEvent('NAME_PLATE_UNIT_ADDED')
    self:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
    self:RegisterEvent('UNIT_THREAT_LIST_UPDATE')

    if not self:IsHooked('CompactUnitFrame_UpdateName') then
        self:SecureHook('CompactUnitFrame_UpdateName')
    end

    self:ScheduleRepeatingTimer("UpdateAllAuras", 0.1)

    self:DisableDefaultBuffsDebuffs()
end

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local EpicPlatesLDB = LibStub("LibDataBroker-1.1"):NewDataObject("EpicPlates", {
    type = "launcher",
    text = "EpicPlates",
    icon = 3565720,  
    OnClick = function(_, button)
        if button == "LeftButton" then
            if Settings and Settings.OpenToCategory then
                Settings.OpenToCategory("EpicPlates")
            else
                InterfaceOptionsFrame_OpenToCategory("EpicPlates")
                InterfaceOptionsFrame_OpenToCategory("EpicPlates")  
            end
        elseif button == "RightButton" then
            if Settings and Settings.OpenToCategory then
                Settings.OpenToCategory("InterfaceOptionsFrame")  
            else
                InterfaceOptionsFrame_OpenToCategory("InterfaceOptionsFrame")
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cFF00FF00EpicPlates|r")  
        tooltip:AddLine("|cFF00CCFFLeft-click|r: Open EpicPlates settings")  
        tooltip:AddLine("|cFFFFA500Right-click|r: Open Interface Options")  
    end,
})

function EpicPlates:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("EpicPlatesDB", {
        profile = {
            iconSize = 20,
            timerFontSize = 12,
            timerFont = "Arial Narrow",
            timerFontColor = {1, 1, 1},
            minimap = { hide = false },
            auraFilters = {
                spellIDs = {},
                spellNames = {},
                casterNames = {}
            },
            alwaysShow = {
                spellIDs = {},
                spellNames = {}
            }
        }
    }, true)

    if not _G.defaultSpells1 or not _G.defaultSpells2 then
    else
        importantSpells = importantSpells or _G.defaultSpells1
        semiImportantSpells = semiImportantSpells or _G.defaultSpells2

    end

    if not self.db.profile.minimap then
        self.db.profile.minimap = { hide = false }
    end

    self:SetupOptions()
    self:UpdateIconPositions()
    self:OnEnable()
    self:UpdateTimerFontSize()
	

    -- Register the minimap icon
    LDBIcon:Register("EpicPlates", EpicPlatesLDB, self.db.profile.minimap)
    
    self:UpdateIconSize()

    C_Timer.After(0.5, function() 
        self:UpdateIconSize() 
    end)
end

importantSpells = importantSpells or defaultSpells1
semiImportantSpells = semiImportantSpells or defaultSpells2

function EpicPlates:IsImportantSpell(spellID)
    for _, id in ipairs(importantSpells) do
        if id == spellID then
            return true
        end
    end
    return false
end

function EpicPlates:IsSemiImportantSpell(spellID)
    for _, id in ipairs(semiImportantSpells) do
        if id == spellID then
            return true
        end
    end
    return false
end

function EpicPlates:CompactUnitFrame_UpdateName(frame)
    if frame.unit and strsub(frame.unit, 1, 9) == "nameplate" then
        self:NiceNameplateInfo_Update(frame.unit)
        self:NiceNameplateFrames_Update(frame.unit)
    end
end

function EpicPlates:NAME_PLATE_CREATED(_, frame)
    self:NiceNameplateInfo_Create(frame)
end

function EpicPlates:NAME_PLATE_UNIT_ADDED(_, unit)
    self:NiceNameplateInfo_Update(unit)
    self:NiceNameplateFrames_Update(unit)
end

function EpicPlates:NAME_PLATE_UNIT_REMOVED(_, unit)
    self:NiceNameplateInfo_Update(unit)
    self:NiceNameplateFrames_Update(unit)
end

function EpicPlates:UNIT_THREAT_LIST_UPDATE(_, unit)
    if unit and unit:match('nameplate') then
        self:NiceNameplateInfo_Update(unit)
        self:NiceNameplateFrames_Update(unit)
    end
end

function EpicPlates:UpdateAllAuras()
    for _, NamePlate in pairs(C_NamePlate.GetNamePlates()) do
        local UnitFrame = NamePlate.UnitFrame
        if UnitFrame and UnitFrame.unit then
            self:UpdateAuras(UnitFrame.unit)
        end
    end
end

-- Disable default buffs/debuffs on the nameplate
function EpicPlates:DisableDefaultBuffsDebuffs()
    local f = CreateFrame("Frame")
    local events = {}

    function events:NAME_PLATE_UNIT_ADDED(plate)
        local unitId = plate
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitId)
        local frame = nameplate.UnitFrame
        if not nameplate or frame:IsForbidden() then return end
        frame.BuffFrame:ClearAllPoints()
        frame.BuffFrame:SetAlpha(0)
    end

    for j, u in pairs(events) do
        f:RegisterEvent(j)
    end

    f:SetScript("OnEvent", function(self, event, ...) events[event](self, ...) end)
end

local function GetUnitProperties(unit)
    local guid = UnitGUID(unit)
    if not guid then return end
    local unitType, _, _, _, _, ID = strsplit('-', guid)
    return unitType, ID
end

local function IsNPC(unit)
    local unitType, ID = GetUnitProperties(unit)
    return  not UnitIsBattlePet(unit) and
            not UnitIsPlayer(unit) and
            not UnitPlayerControlled(unit) and
            not UnitIsEnemy('player', unit) and
            not UnitCanAttack('player', unit) and
            (unitType == 'Creature')
end


local function RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and r >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function EpicPlates:MakeInfoString(unit, item)
    EpicPlatesTooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
    EpicPlatesTooltip:SetUnit(unit)

    if item == 'name' then
        local name = UnitName(unit)
        return name
    elseif item == 'realm' then
        local _, realm = UnitName(unit)
        return realm
    elseif item == 'level' then
        local level = UnitLevel(unit)
        return (level == -1) and '??' or level
    elseif item == 'levelcolor' then
        local level = UnitLevel(unit)
        local levelcolor = GetCreatureDifficultyColor((level == -1) and 255 or level)
        return levelcolor
    elseif item == 'fullname' then
        local _, realm = UnitName(unit)
        local TooltipTextLeft1 = EpicPlatesTooltipTextLeft1:GetText()
        return (not realm and TooltipTextLeft1) or TooltipTextLeft1:gsub('-'..realm, '(*)')
    elseif item == 'guild' then
        local guild = GetGuildInfo(unit)
        return guild
    elseif item == 'profession' then
        if EpicPlatesTooltip:NumLines() > 2 then
            for i = 2, EpicPlatesTooltip:NumLines() do
                local TooltipTextLeft = _G['EpicPlatesTooltipTextLeft' .. i]:GetText()
                if not TooltipTextLeft:lower():match(LEVEL_GAINED:gsub('%%d', '[%%d?]+'):lower()) and
                   not TooltipTextLeft:lower():match(LEVEL:lower()..' ([%d?]+)%s?%(?([^)]*)%)?') then
                    return TooltipTextLeft
                end
            end
        end
    elseif item == 'localizedclass' then
        return UnitClassBase(unit)
    elseif item == 'englishclass' then
        local _, englishclass = UnitClass(unit)
        return englishclass
    elseif item == 'classcolor' then
        local _, englishclass = UnitClass(unit)
        return RAID_CLASS_COLORS[englishclass]
    elseif item == 'localizedrace' then
        return UnitRace(unit)
    elseif item == 'englishrace' then
        local _, englishrace = UnitRace(unit)
        return englishrace
    elseif item == 'creaturetype' then
        return UnitCreatureType(unit)
    elseif item == 'creaturefamily' then
        return UnitCreatureFamily(unit)
    elseif item == 'questinfo' then
        return self:GetQuestInfo(unit)
    elseif item == 'questcolorinfo' then
        return self:GetQuestColorInfo(unit)
    end
end

function EpicPlates:GetQuestInfo(unit)
    local ObjectiveCount = 0
    local QuestName

    if EpicPlatesTooltip:NumLines() >= 3 then
        for i = 3, EpicPlatesTooltip:NumLines() do
            local QuestLine = _G['EpicPlatesTooltipTextLeft' .. i]
            local QuestLineText = QuestLine and QuestLine:GetText()

            local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')

            if not (PlayerName and PlayerName ~= '' and PlayerName ~= UnitName('player')) then
                if not QuestName and ProgressText then
                    QuestName = _G['EpicPlatesTooltipTextLeft' .. i - 1]:GetText()
                end
                if ProgressText then
                    local x, y = strmatch(ProgressText, '(%d+)/(%d+)')
                    if x and y then
                        local NumLeft = y - x
                        if NumLeft > ObjectiveCount then 
                            ObjectiveCount = NumLeft
                            return ProgressText
                        end
                    else
                        return QuestName .. ': ' .. ProgressText
                    end
                end
            end
        end
    end
    return false
end

function EpicPlates:GetQuestColorInfo(unit)
    local ObjectiveCount = 0
    local QuestName
    local ProgressColored

    if EpicPlatesTooltip:NumLines() >= 3 then
        for i = 3, EpicPlatesTooltip:NumLines() do
            local QuestLine = _G['EpicPlatesTooltipTextLeft' .. i]
            local QuestLineText = QuestLine and QuestLine:GetText()

            local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')

            if not (PlayerName and PlayerName ~= '' and PlayerName ~= UnitName('player')) then
                if not QuestName and ProgressText then
                    QuestName = _G['EpicPlatesTooltipTextLeft' .. i - 1]:GetText()
                end
                if ProgressText then
                    local x, y = strmatch(ProgressText, '(%d+)/(%d+)')
                    if x and y then
                        local NumLeft = y - x
                        if NumLeft > ObjectiveCount then
                            ObjectiveCount = NumLeft
                            ProgressColored = ProgressText
                        end
                    else
                        ProgressColored = QuestName .. ': ' .. ProgressText
                    end
                end
            end
        end
        if ProgressColored then
            for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                local questInfo = C_QuestLog.GetInfo(i)
                if not questInfo.isHeader and questInfo.title == QuestName then
                    local colors = GetQuestDifficultyColor(questInfo.level)
                    return '|cFF'..RGBToHex(colors.r, colors.g, colors.b)..ProgressColored..'|r'
                end
            end
        end
    end
    return false
end

function EpicPlates:EnableGroupDragging(namePlate)
    local UnitFrame = namePlate.UnitFrame
    if not UnitFrame then return end

    if not UnitFrame.IconGroupFrame then
        UnitFrame.IconGroupFrame = CreateFrame("Frame", nil, UnitFrame)
        UnitFrame.IconGroupFrame:SetSize(1, 1)  
        UnitFrame.IconGroupFrame:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", 0, 0)
    end

    UnitFrame.IconGroupFrame:SetMovable(true)
    UnitFrame.IconGroupFrame:EnableMouse(true)
    UnitFrame.IconGroupFrame:RegisterForDrag("LeftButton")

    UnitFrame.IconGroupFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    UnitFrame.IconGroupFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint()
        EpicPlates.db.profile.iconGroupPosition = {point, relativePoint, xOffset, yOffset}
    end)
end

function EpicPlates:UpdateTimerFontSize()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local unitFrame = namePlate.UnitFrame

        if unitFrame and unitFrame.buffIcons then
            for _, icon in ipairs(unitFrame.buffIcons) do
                icon.timer:SetFont(LSM:Fetch("font", self.db.profile.timerFont), self.db.profile.timerFontSize, "OUTLINE")
            end
        end

        if unitFrame and unitFrame.debuffIcons then
            for _, icon in ipairs(unitFrame.debuffIcons) do
                icon.timer:SetFont(LSM:Fetch("font", self.db.profile.timerFont), self.db.profile.timerFontSize, "OUTLINE")
            end
        end
    end
end


function EpicPlates:UpdateIconPositions()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local UnitFrame = namePlate.UnitFrame
        if UnitFrame and UnitFrame.buffIcons and UnitFrame.debuffIcons then
            if EpicPlates.db.profile.iconGroupPosition then
                UnitFrame.IconGroupFrame:SetPoint(unpack(EpicPlates.db.profile.iconGroupPosition))
            end

            for i = 1, #UnitFrame.buffIcons do
                local icon = UnitFrame.buffIcons[i].icon
                icon:SetParent(UnitFrame.IconGroupFrame)
            end

            for i = 1, #UnitFrame.debuffIcons do
                local icon = UnitFrame.debuffIcons[i].icon
                icon:SetParent(UnitFrame.IconGroupFrame)
            end

            self:EnableGroupDragging(namePlate)
        end
    end
end

function EpicPlates:UpdateIconSize()
    local iconSize = self.db.profile.iconSize
    local timerFontSize = self.db.profile.timerFontSize
    local timerFont = LSM:Fetch("font", self.db.profile.timerFont)  
    local timerFontColor = self.db.profile.timerFontColor or {1, 1, 1} 

    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local UnitFrame = namePlate.UnitFrame
        if UnitFrame and UnitFrame.buffIcons and UnitFrame.debuffIcons then
            for i = 1, #UnitFrame.buffIcons do
                local icon = UnitFrame.buffIcons[i].icon
                local timer = UnitFrame.buffIcons[i].timer

                icon:SetSize(iconSize, iconSize)
                timer:SetFont(timerFont, timerFontSize, "OUTLINE")
                timer:SetTextColor(unpack(timerFontColor))  
                timer:ClearAllPoints()
                timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
            end

            for i = 1, #UnitFrame.debuffIcons do
                local icon = UnitFrame.debuffIcons[i].icon
                local timer = UnitFrame.debuffIcons[i].timer

                icon:SetSize(iconSize, iconSize)
                timer:SetFont(timerFont, timerFontSize, "OUTLINE")
                timer:SetTextColor(unpack(timerFontColor))  
                timer:ClearAllPoints()
                timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
            end
        end
    end
end

-- Setup options after ensuring the options table is defined
function EpicPlates:SetupOptions()
    if not options then
        
        return
    end

    AceConfig:RegisterOptionsTable("EpicPlates", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")

    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateIconSize")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateIconSize")
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateIconSize")
end

function EpicPlates:NiceNameplateFrames_Update(unit)
    if not UnitIsUnit('player', unit) then
        local NamePlate = GetNamePlateForUnit(unit)
        if not NamePlate then return end
        local UnitFrame = NamePlate.UnitFrame
        if not UnitFrame then return end

        if not UnitFrame.buffIcons or not UnitFrame.debuffIcons then
            self:CreateAuraIcons(UnitFrame)
        end

        local healthBar = UnitFrame.healthBar
        local NiceNameplateInfo = UnitFrame.NiceNameplateInfo
        local classificationIndicator = UnitFrame.ClassificationFrame and UnitFrame.ClassificationFrame.classificationIndicator

        local isFriend = UnitIsFriend('player', unit)
        local isPlayer = UnitIsPlayer(unit)
        local isTarget = UnitIsUnit('target', unit)
        local isCombat = UnitThreatSituation('player', unit)
        local classification = UnitClassification(unit)
        local isBoss = (classification == 'elite' or classification == 'worldboss' or classification == 'rareelite')

        UnitFrame:SetAlpha((isTarget and 1) or NAMEPLATE_ALPHA)

        if healthBar and healthBar.border then
            healthBar.border:SetScale((isTarget and 1.2) or 1)
            healthBar:SetShown(isCombat or not (isFriend or not isTarget) or (isPlayer and isTarget) or (isPlayer and not isFriend))
        end

        if classificationIndicator then
            classificationIndicator:SetShown(isCombat and isBoss or (isBoss and not (isFriend or not isTarget)))
        end

        if NiceNameplateInfo then
            NiceNameplateInfo:SetShown(UnitFrame.name:GetText() and UnitFrame.name:IsVisible() and not healthBar:IsVisible())
        end

        self:UpdateAuras(unit)
    end
end

function EpicPlates:NiceNameplateInfo_Create(frame)
    local NamePlate = frame
    local UnitFrame = NamePlate and NamePlate.UnitFrame

    if not UnitFrame then return end

    if UnitFrame and not UnitFrame.NiceNameplateInfo then
        UnitFrame.NiceNameplateInfo = UnitFrame:CreateFontString(nil, 'OVERLAY')
        UnitFrame.NiceNameplateInfo:SetFontObject(SystemFont_NamePlate)
        UnitFrame.NiceNameplateInfo:SetPoint(INFO_POINT, UnitFrame.name, INFO_RELATIVE_POINT, INFO_X, INFO_Y)
        UnitFrame.NiceNameplateInfo:Hide()
    end

    self:CreateAuraIcons(UnitFrame)
end

function EpicPlates:NiceNameplateInfo_Update(unit)
    local NamePlate = GetNamePlateForUnit(unit)
    local UnitFrame = NamePlate and NamePlate.UnitFrame

    if not UnitFrame then return end

    if not UnitFrame.buffIcons or not UnitFrame.debuffIcons then
        self:CreateAuraIcons(UnitFrame)
    end

    local UnitName = UnitFrame.name
    local NiceNameplateInfo = UnitFrame.NiceNameplateInfo

    local isFriend = UnitIsFriend('player', unit)
    local isPlayer = UnitIsPlayer(unit)
    local isEnemy = UnitIsEnemy('player', unit) or UnitCanAttack('player', unit)
    local isNPC = IsNPC(unit)
    if NiceNameplateInfo then
        if isPlayer and not isEnemy then
            local classColor = self:MakeInfoString(unit, 'classcolor')
            NiceNameplateInfo:SetText(self:MakeInfoString(unit, 'guild'))
            UnitName:SetTextColor(classColor.r, classColor.g, classColor.b)
            UnitName:SetText(self:MakeInfoString(unit, 'fullname'))
        elseif isPlayer and isEnemy then
            NiceNameplateInfo:SetText(self:MakeInfoString(unit, 'guild'))
            UnitName:SetText(self:MakeInfoString(unit, 'fullname'))
        elseif isEnemy and not self:MakeInfoString(unit, 'questinfo') then
            local levelColor = self:MakeInfoString(unit, 'levelcolor') or {r = 1, g = 1, b = 1}
            local InfoString = format('%s, '..LEVEL_GAINED:gsub('%%d', '|cFF%%s%%s|r'), self:MakeInfoString(unit, 'creaturetype') or ENEMY, RGBToHex(levelColor.r, levelColor.g, levelColor.b), self:MakeInfoString(unit, 'level'))
            NiceNameplateInfo:SetText(InfoString)
        elseif isNPC and not self:MakeInfoString(unit, 'questinfo') then
            NiceNameplateInfo:SetText(self:MakeInfoString(unit, 'profession'))
        elseif self:MakeInfoString(unit, 'questinfo') then
            NiceNameplateInfo:SetText(self:MakeInfoString(unit, 'questcolorinfo'))
        else
            NiceNameplateInfo:SetText(nil)
        end
    end

    self:UpdateAuras(unit)
end

function EpicPlates:NiceNameplateInfo_Delete(unit)
    local NamePlate = GetNamePlateForUnit(unit)
    local UnitFrame = NamePlate and NamePlate.UnitFrame
    local NiceNameplateInfo = UnitFrame and UnitFrame.NiceNameplateInfo

    if NiceNameplateInfo then
        NiceNameplateInfo:SetText(nil)
        NiceNameplateInfo:Hide()
    end
end

function EpicPlates:CreateAuraIcons(UnitFrame)
    if not UnitFrame then return end

    UnitFrame.buffIcons = {}
    UnitFrame.debuffIcons = {}

    local iconSize = self.db.profile.iconSize
    local rowSpacing = 13  -- Space between rows

    -- Create Buff Icons
    for i = 1, MAX_BUFFS do
        local icon = UnitFrame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(iconSize, iconSize)
        
        local row = math.floor((i - 1) / BUFFS_PER_LINE)
        local col = (i - 1) % BUFFS_PER_LINE
        icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", col * (iconSize + 2), BUFF_ICON_OFFSET_Y + row * (iconSize + rowSpacing))

        icon:Hide()

        local timer = UnitFrame:CreateFontString(nil, "OVERLAY")
        timer:SetFontObject(SystemFont_Outline_Small)
        timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        timer:Hide()

        -- Tooltip functionality for buffs
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(UnitFrame.unit, i, "HELPFUL")
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        UnitFrame.buffIcons[i] = {
            icon = icon,
            timer = timer
        }
    end

    -- Create Debuff Icons
    for i = 1, MAX_DEBUFFS do
        local icon = UnitFrame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(iconSize, iconSize)

        local row = math.floor((i - 1) / DEBUFFS_PER_LINE)
        local col = (i - 1) % DEBUFFS_PER_LINE
        icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", col * (iconSize + 2), DEBUFF_ICON_OFFSET_Y + row * (iconSize + rowSpacing))

        icon:Hide()

        local timer = UnitFrame:CreateFontString(nil, "OVERLAY")
        timer:SetFontObject(SystemFont_Outline_Small)
        timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        timer:Hide()

        -- Tooltip functionality for debuffs
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(UnitFrame.unit, i, "HARMFUL")
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        UnitFrame.debuffIcons[i] = {
            icon = icon,
            timer = timer
        }
    end

    -- Ensure the sizes and positions are correct after creation
    self:UpdateIconSize()
end



local function IsAuraFiltered(spellName, spellID, casterName)
    local filters = EpicPlates.db.profile.auraFilters
    local alwaysShow = EpicPlates.db.profile.alwaysShow

    -- Always show specific spells, regardless of other filters
    if spellID then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo and (alwaysShow.spellIDs[spellID] or alwaysShow.spellNames[spellInfo.name]) then
            return false
        end
    end

    -- Normal filtering logic
    if spellID then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo and filters.spellIDs[spellID] then
            return true
        end
    end

    if spellName then
        local spellInfo = C_Spell.GetSpellInfo(spellName)
        if spellInfo and filters.spellNames[spellInfo.name] then
            return true
        end
    end

    if casterName and filters.casterNames[casterName] then
        return true
    end

    return false
end



function EpicPlates:UpdateAuras(unit)
    local NamePlate = C_NamePlate.GetNamePlateForUnit(unit)
    local UnitFrame = NamePlate and NamePlate.UnitFrame

    if not UnitFrame then return end

    if not UnitIsUnit("target", unit) and not UnitIsUnit("mouseover", unit) then
        for i = 1, MAX_BUFFS do
            UnitFrame.buffIcons[i].icon:Hide()
            UnitFrame.buffIcons[i].timer:Hide()
        end
        for i = 1, MAX_DEBUFFS do
            UnitFrame.debuffIcons[i].icon:Hide()
            UnitFrame.debuffIcons[i].timer:Hide()
        end
        return
    end

    local buffIndex = 1
    local debuffIndex = 1
    local currentTime = GetTime()

    -- Buffs
    for i = 1, 40 do
        local aura = C_UnitAuras.GetBuffDataByIndex(unit, i)
        if not aura or buffIndex > MAX_BUFFS then break end

        if not IsAuraFiltered(aura.name, aura.spellId, aura.sourceName) then
            self:DisplayAura(UnitFrame.buffIcons[buffIndex], aura, currentTime)
            buffIndex = buffIndex + 1
        end
    end

    -- Debuffs
    for i = 1, 40 do
        local aura = C_UnitAuras.GetDebuffDataByIndex(unit, i)
        if not aura or debuffIndex > MAX_DEBUFFS then break end

        if not IsAuraFiltered(aura.name, aura.spellId, aura.sourceName) then
            self:DisplayAura(UnitFrame.debuffIcons[debuffIndex], aura, currentTime)
            debuffIndex = debuffIndex + 1
        end
    end

    -- Hide unused icons
    for i = buffIndex, MAX_BUFFS do
        UnitFrame.buffIcons[i].icon:Hide()
        UnitFrame.buffIcons[i].timer:Hide()
    end

    for i = debuffIndex, MAX_DEBUFFS do
        UnitFrame.debuffIcons[i].icon:Hide()
        UnitFrame.debuffIcons[i].timer:Hide()
    end
end

function EpicPlates:DisplayAura(iconTable, aura, currentTime)
    local icon = iconTable.icon
    local timer = iconTable.timer

    icon:SetTexture(aura.icon)
    icon:Show()

    local remainingTime = aura.expirationTime - currentTime
    if remainingTime > 0 then
        if EpicPlates.db.profile.colorMode == "dynamic" then
            -- Change color based on remaining time
            if remainingTime > 5 then
                timer:SetTextColor(0, 1, 0)  -- Green
            elseif remainingTime > 2 then
                timer:SetTextColor(1, 1, 0)  -- Yellow
            else
                timer:SetTextColor(1, 0, 0)  -- Red
            end
        else
            -- Use fixed color
            local r, g, b = unpack(EpicPlates.db.profile.timerFontColor or {1, 1, 1})
            timer:SetTextColor(r, g, b)
        end
        
        timer:SetText(string.format("%.1f", remainingTime))
        timer:Show()
    else
        timer:Hide()
    end
end


-- Script to handle various events and apply updates accordingly
EpicPlates.Events = CreateFrame("Frame")
EpicPlates.Events:RegisterEvent("ADDON_LOADED")
EpicPlates.Events:RegisterEvent("PLAYER_LOGIN")

EpicPlates.Events:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and (...) == "EpicPlates" then
        EpicPlates:OnEnable()
    elseif event == "PLAYER_LOGIN" then
        EpicPlates:OnEnable()
        EpicPlates.Events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        EpicPlates.Events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        EpicPlates.Events:RegisterEvent("UNIT_AURA")
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        EpicPlates:NAME_PLATE_UNIT_ADDED(nil, unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        EpicPlates:NAME_PLATE_UNIT_REMOVED(nil, unit)
    elseif event == "UNIT_AURA" then
        local unit = ...
        if strmatch(unit, "nameplate%d+") then
            EpicPlates:UpdateAuras(unit)
        end
     end
end)











