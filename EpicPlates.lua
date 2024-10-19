-- Made by Sharpedge_Gaming
-- v1.5 - 11.0.2

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local LibButtonGlow = LibStub("LibButtonGlow-1.0") 

local INFO_POINT            = 'TOP'
local INFO_RELATIVE_POINT   = 'BOTTOM'
local INFO_X                = 0
local INFO_Y                = 0

local NAMEPLATE_ALPHA       = 0.7
local ICON_SIZE             = 20 
local MAX_BUFFS             = 10 
local MAX_DEBUFFS           = 10  
local BUFF_ICON_OFFSET_Y    = 20 
local DEBUFF_ICON_OFFSET_Y  = 10 
local BUFFS_PER_LINE        = 6 
local DEBUFFS_PER_LINE      = 6 
local MAX_ROWS              = 3  
local LINE_SPACING_Y        = 9 

if not EpicPlates then
    EpicPlates = LibStub('AceAddon-3.0'):NewAddon('EpicPlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
end

local gladiatorMedallionSpellID = 336126 
local adaptationSpellID = 214027 
local trinketCooldown = 120 

EpicPlates.defaults = {
    profile = {
        iconSize = 20,
        timerFontSize = 10,
        timerFont = "Friz Quadrata TT",
        timerFontColor = {1, 1, 1},
        buffIconPositions = {},
        debuffIconPositions = {},
        showHealthPercent = false,
        healthPercentFontColor = {1, 1, 1}, 
        timerPosition = "BELOW",	
        iconXOffset = 0,   
        iconYOffset = 0,
        iconGlowEnabled = true,		
    },
}

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local EpicPlatesTooltip = CreateFrame('GameTooltip', 'EpicPlatesTooltip', nil, 'GameTooltipTemplate')

local racialSpells = {
    [59752] = 180,  -- Will to Survive
    [7744] = 120,   -- Will of the Forsaken
    [20594] = 120, -- Stoneform
    [58984] = 120,  -- Shadowmeld
    [20589] = 60,   -- Escape Artist
    [59542] = 180,  -- Gift of the Naaru
    [68992] = 120,  -- Darkflight
    [107079] = 120, -- Quaking Palm
    [33697] = 120,  -- Blood Fury
    [20549] = 90,   -- War Stomp
    [26297] = 180,  -- Berserking
    [202719] = 90,  -- Arcane Torrent
    [69070] = 90,   -- Rocket Jump
    [255647] = 150, -- Light's Judgment
    [255654] = 120, -- Bull Rush
    [260364] = 180, -- Arcane Pulse
    [274738] = 120, -- Ancestral Call
    [265221] = 120, -- Fireblood
    [291944] = 160, -- Regeneratin'
    [256948] = 180, -- Spatial Rift
    [287712] = 160, -- Haymaker
    [312924] = 180, -- Hyper Organic Light Originator
    [312411] = 90,  -- Bag of Tricks
    [368970] = 90,  -- Tail Swipe
    [357214] = 90,  -- Wing Buffet
    [436344] = 120 -- Azerite Surge
}

local racialData = {
    [1] = { texture = C_Spell.GetSpellTexture(59752), sharedCD = 90 },   -- Human (Will to Survive)
    [5] = { texture = C_Spell.GetSpellTexture(7744), sharedCD = 30 },    -- Scourge (Will of the Forsaken)
    [3] = { texture = C_Spell.GetSpellTexture(20594), sharedCD = 30 },   -- Dwarf (Stoneform)
    [4] = { texture = C_Spell.GetSpellTexture(58984), sharedCD = 0 },    -- Night Elf (Shadowmeld)
    [7] = { texture = C_Spell.GetSpellTexture(20589), sharedCD = 0 },    -- Gnome (Escape Artist)
    [11] = { texture = C_Spell.GetSpellTexture(59542), sharedCD = 0 },   -- Draenei (Gift of the Naaru)
    [22] = { texture = C_Spell.GetSpellTexture(68992), sharedCD = 0 },   -- Worgen (Darkflight)
    [26] = { texture = C_Spell.GetSpellTexture(107079), sharedCD = 0 },   -- Pandaren (Quaking Palm) Horde
	[25] = { texture = C_Spell.GetSpellTexture(107079), sharedCD = 0 },   --Pandaren Alliance
    [2] = { texture = C_Spell.GetSpellTexture(33697), sharedCD = 0 },    -- Orc (Blood Fury)
    [6] = { texture = C_Spell.GetSpellTexture(20549), sharedCD = 0 },    -- Tauren (War Stomp)
    [8] = { texture = C_Spell.GetSpellTexture(26297), sharedCD = 0 },   -- Troll (Berserking)
    [10] = { texture = C_Spell.GetSpellTexture(202719), sharedCD = 0 },   -- Blood Elf (Arcane Torrent)
    [9] = { texture = C_Spell.GetSpellTexture(69070), sharedCD = 0 },   -- Goblin (Rocket Jump)
    [30] = { texture = C_Spell.GetSpellTexture(255647), sharedCD = 0 },  -- Lightforged Draenei (Light's Judgment)
    [28] = { texture = C_Spell.GetSpellTexture(255654), sharedCD = 0 },  -- Highmountain Tauren (Bull Rush)
    [27] = { texture = C_Spell.GetSpellTexture(260364), sharedCD = 0 },  -- Nightborne (Arcane Pulse)
    [36] = { texture = C_Spell.GetSpellTexture(274738), sharedCD = 0 },  -- Mag'har Orc (Ancestral Call)
    [34] = { texture = C_Spell.GetSpellTexture(265221), sharedCD = 30 }, -- Dark Iron Dwarf (Fireblood)
    [31] = { texture = C_Spell.GetSpellTexture(291944), sharedCD = 0 },  -- Zandalari Troll (Regeneratin')
    [29] = { texture = C_Spell.GetSpellTexture(256948), sharedCD = 0 },  -- Void Elf (Spatial Rift)
    [32] = { texture = C_Spell.GetSpellTexture(287712), sharedCD = 0 },  -- Kul Tiran (Haymaker)
    [37] = { texture = C_Spell.GetSpellTexture(312924), sharedCD = 0 },  -- Mechagnome (Hyper Organic Light Originator)
    [35] = { texture = C_Spell.GetSpellTexture(312411), sharedCD = 0 },  -- Vulpera (Bag of Tricks)
    [52] = { texture = C_Spell.GetSpellTexture(368970), sharedCD = 0 },  -- Dracthyr (Tail Swipe)
    [70] = { texture = C_Spell.GetSpellTexture(357214), sharedCD = 0 },  -- Dracthyr (Wing Buffet)
    [84] = { texture = C_Spell.GetSpellTexture(436344), sharedCD = 0 },  -- Earthen (Azerite Surge) Horde
	[85] = { texture = C_Spell.GetSpellTexture(436344), sharedCD = 0 },  --Earthen Alliance
}

local healingSpells = {
    -- Druid (Restoration only)
    [48438] = true,  -- Wild Growth
    [18562] = true,  -- Swiftmend
    [33763] = true,  -- Lifebloom
    [740] = true,    -- Tranquility
	
    -- Priest (Holy and Discipline)
    [33076] = true,  -- Prayer of Mending (Holy/Disc)
    [34861] = true,  -- Holy Word: Sanctify (Holy)
    [2050] = true,   -- Holy Word: Serenity (Holy)
    [194509] = true, -- Power Word: Radiance (Disc)
    [47540] = true,  -- Penance (Disc)
	[372835] = true,  -- Lightwell (Holy)
	
    -- Paladin (Holy only)
    [20473] = true,  -- Holy Shock
    [223306] = true, -- Bestow Faith
    [85222] = true,  -- Light of Dawn
    [183998] = true, -- Light of the Martyr
	
    -- Shaman (Restoration only)
    [73920] = true,  -- Healing Rain
    [61295] = true,  -- Riptide
    [98008] = true,  -- Spirit Link Totem
    [108280] = true, -- Healing Tide Totem
	[1064] = true,   -- Chain Heal
	
    -- Monk (Mistweaver only)
    [191837] = true, -- Essence Font
    [124682] = true, -- Enveloping Mist
    [116849] = true, -- Life Cocoon
    [115151] = true, -- Renewing Mist
	
    -- Evoker (Preservation only)
    [355941] = true, -- Dream Breath
    [367226] = true, -- Spiritbloom
    [366155] = true, -- Reversion
    [359816] = true, -- Dream Flight
    
}

local healerGUIDs = {}
local inspectedGUIDs = {}

local healerClasses = {
    ["DRUID"] = true,   -- Druid
    ["PRIEST"] = true,  -- Priest
    ["PALADIN"] = true, -- Paladin
    ["SHAMAN"] = true,  -- Shaman
    ["MONK"] = true,    -- Monk
    ["EVOKER"] = true   -- Evoker
}

local function AddHealerIcon(self)
    local unit = self.namePlateUnitToken
    if not unit then return end
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end
    if nameplate.HealerIcon then
        nameplate.HealerIcon:Hide()
    end
    local _, class = UnitClass(unit)
    if not healerClasses[class] then 
        return
    end
    if UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
        NotifyInspect(unit)
        inspectedGUIDs[UnitGUID(unit)] = unit
    end
end
 
local function OnInspectReady(self, event, guid)
    if inspectedGUIDs[guid] then
        local unit = inspectedGUIDs[guid]
        if unit and UnitGUID(unit) == guid then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate then
                local specID = GetInspectSpecialization(unit)
                if specID and healerSpecs[specID] then
                    if not nameplate.HealerIcon then
                        nameplate.HealerIcon = CreateFrame("Frame", nil, nameplate)
                        nameplate.HealerIcon:SetSize(30, 30)
                        nameplate.HealerIcon.Texture = nameplate.HealerIcon:CreateTexture(nil, "OVERLAY")
                        nameplate.HealerIcon.Texture:SetAllPoints(nameplate.HealerIcon)
                        nameplate.HealerIcon.Texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")
                    end
                    nameplate.HealerIcon:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "LEFT", -40, 0)
                    nameplate.HealerIcon:Show()
                else
                    if nameplate.HealerIcon then
                        nameplate.HealerIcon:Hide()
                    end
                end
            end
        end
        inspectedGUIDs[guid] = nil
    end
end

-- Register the INSPECT_READY event
local frame = CreateFrame("Frame")
frame:RegisterEvent("INSPECT_READY")
frame:SetScript("OnEvent", OnInspectReady)
 
hooksecurefunc(NamePlateBaseMixin, "OnAdded", AddHealerIcon)

-- Function to remove healer icon
local function RemoveHealerIcon(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.HealerIcon then
        nameplate.HealerIcon:Hide()
    end
end

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

local function RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and r >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
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

local function GetRacialAbility(unit)
    if not unit or not UnitIsPlayer(unit) then
        return nil
    end

    local playerLocation = PlayerLocation:CreateFromUnit(unit)
    local raceID = C_PlayerInfo.GetRace(playerLocation)   
    if raceID then
        local racialAbility = racialData[raceID]
        if racialAbility then
            return racialAbility
        end
    end
    
    return nil
end

local function ShowPvPItem(unit, isRacial)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not UnitIsPlayer(unit) or not UnitIsEnemy("player", unit) then return end

    local UnitFrame = nameplate.UnitFrame
    local frameKey = isRacial and "PvPRacialFrame" or "PvPTrinketFrame"
    local racialAbility = GetRacialAbility(unit)
    local iconTexture = isRacial and (racialAbility and racialAbility.texture) or 1322720  -- Default trinket icon

    if UnitFrame[frameKey] then
        UnitFrame[frameKey]:Hide()
    end

    if not UnitFrame[frameKey] then
        UnitFrame[frameKey] = CreateFrame("Frame", nil, UnitFrame)
        UnitFrame[frameKey]:SetSize(22, 22)  
        UnitFrame[frameKey].icon = UnitFrame[frameKey]:CreateTexture(nil, "OVERLAY")
        UnitFrame[frameKey].icon:SetAllPoints(UnitFrame[frameKey])
        
        UnitFrame[frameKey].timerText = UnitFrame[frameKey]:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        UnitFrame[frameKey].timerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        UnitFrame[frameKey].timerText:SetTextColor(1, 1, 1)  
        UnitFrame[frameKey].timerText:SetPoint("CENTER", UnitFrame[frameKey], "CENTER", 0, 0)  
        UnitFrame[frameKey].timerText:Hide()
    end

    if isRacial then
        UnitFrame[frameKey]:SetPoint("RIGHT", UnitFrame, "RIGHT", 38, 0)  
    else
        if UnitFrame.PvPRacialFrame and UnitFrame.PvPRacialFrame:IsShown() then
            UnitFrame[frameKey]:SetPoint("RIGHT", UnitFrame.PvPRacialFrame, "LEFT", 0, 0)  
        else
            UnitFrame[frameKey]:SetPoint("RIGHT", UnitFrame, "RIGHT", 20, 0)  
        end
    end

    UnitFrame[frameKey].icon:SetTexture(iconTexture)
    UnitFrame[frameKey]:Show()
end

-- Function to Hide Trinket or Racial Ability
local function HidePvPItem(unit, isRacial)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not nameplate.UnitFrame then return end

    local UnitFrame = nameplate.UnitFrame
    local frameKey = isRacial and "PvPRacialFrame" or "PvPTrinketFrame"

    if UnitFrame[frameKey] then
        UnitFrame[frameKey]:Hide()
    end
end

-- Function to show the PvP trinket icon
local function ShowPvPTrinket(unit)
    if not UnitIsPlayer(unit) or not UnitIsEnemy("player", unit) then return end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not nameplate.UnitFrame then return end

    local UnitFrame = nameplate.UnitFrame
    local frameKey = "PvPTrinketFrame"
    local cooldownKey = "TrinketCooldownOverlay"
    local iconTexture = 1322720  

    if UnitFrame[frameKey] then
        UnitFrame[frameKey]:Hide()
    end

    if not UnitFrame[frameKey] then
        UnitFrame[frameKey] = CreateFrame("Frame", nil, UnitFrame)
        UnitFrame[frameKey]:SetSize(22, 22)
        UnitFrame[frameKey]:SetPoint("LEFT", UnitFrame, "RIGHT", 2, 0)
    end

    if not UnitFrame[frameKey].icon then
        UnitFrame[frameKey].icon = UnitFrame[frameKey]:CreateTexture(nil, "OVERLAY")
        UnitFrame[frameKey].icon:SetAllPoints(UnitFrame[frameKey])
    end

    UnitFrame[frameKey].icon:SetTexture(iconTexture)
    UnitFrame[frameKey]:Show()

    if not UnitFrame[cooldownKey] then
        UnitFrame[cooldownKey] = CreateFrame("Cooldown", nil, UnitFrame[frameKey], "CooldownFrameTemplate")
        UnitFrame[cooldownKey]:SetAllPoints(UnitFrame[frameKey])
    end

    UnitFrame[cooldownKey]:SetCooldown(GetTime(), 120)  
end

-- Define the HidePvPTrinket function
local function HidePvPTrinket(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.PvPTrinketFrame then
        nameplate.UnitFrame.PvPTrinketFrame:Hide()
    end
end

local function StartCooldown(unit, isRacial, spellId)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not UnitIsPlayer(unit) or not UnitIsEnemy("player", unit) then return end

    local UnitFrame = nameplate.UnitFrame
    local frameKey = isRacial and "PvPRacialFrame" or "PvPTrinketFrame"
    local cooldownKey = isRacial and "RacialCooldown" or "TrinketCooldown"
    local cooldownDuration = isRacial and (racialSpells[spellId] or 120) or 120  

    if UnitFrame and UnitFrame[frameKey] then

        if UnitFrame[frameKey][cooldownKey] then
            UnitFrame[frameKey][cooldownKey]:SetCooldown(GetTime(), cooldownDuration)
        else
            UnitFrame[frameKey][cooldownKey] = CreateFrame("Cooldown", nil, UnitFrame[frameKey], "CooldownFrameTemplate")
            UnitFrame[frameKey][cooldownKey]:SetAllPoints(UnitFrame[frameKey])  
            UnitFrame[frameKey][cooldownKey]:SetCooldown(GetTime(), cooldownDuration)
        end

        if not UnitFrame[frameKey].timerText then
            UnitFrame[frameKey].timerText = UnitFrame[frameKey]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            UnitFrame[frameKey].timerText:SetPoint("CENTER", UnitFrame[frameKey], "CENTER", 0, 0)
            UnitFrame[frameKey].timerText:SetTextColor(1, 1, 1)  
        end
        UnitFrame[frameKey].timerText:Show()

        C_Timer.NewTicker(0.1, function()
            local startTime, duration = UnitFrame[frameKey][cooldownKey]:GetCooldownTimes()
            local remainingTime = (startTime + duration) / 1000 - GetTime()  

            if remainingTime > 0 then
                UnitFrame[frameKey].timerText:SetText(math.ceil(remainingTime))
            else
                UnitFrame[frameKey].timerText:Hide()
            end
        end, cooldownDuration * 10)  
    end
end

local function StartSharedCooldown(unit, spellId)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate or not UnitIsPlayer(unit) or not UnitIsEnemy("player", unit) then return end

    local UnitFrame = nameplate.UnitFrame
    if not UnitFrame then return end

    local sharedCooldownDuration = 90

    if racialSpells[spellId] then
        StartCooldown(unit, true, spellId)
    elseif spellId == gladiatorMedallionSpellID or spellId == adaptationSpellID then
        StartCooldown(unit, false, spellId)
    end
end

-- Utility to get remaining cooldown
local function GetRemainingCD(frame)
    local startTime, duration = frame:GetCooldownTimes()
    if startTime == 0 then return 0 end

    local currTime = GetTime()
    return (startTime + duration) / 1000 - currTime
end

-- Utility function to update the cooldown text
local function UpdateCooldownText(UnitFrame, cooldownText, endTime)
    if not cooldownText or not endTime or endTime <= GetTime() then
        cooldownText:Hide()
        return
    end
	
    if not UnitFrame.ticker then
        UnitFrame.ticker = C_Timer.NewTicker(0.1, function()
            local remainingTime = endTime - GetTime()
            if remainingTime > 0 then
                cooldownText:SetText(string.format("%d", math.ceil(remainingTime)))
                cooldownText:Show()
            else
                cooldownText:Hide()
                UnitFrame.ticker:Cancel()
                UnitFrame.ticker = nil
            end
        end)
    end
end

-- Function to handle racial or trinket use
function EpicPlates:OnSpellCastSuccess(event, unit, castGUID, spellId)
    if not spellId or not unit then
        return
    end

    if racialSpells[spellId] then
        ShowPvPItem(unit, true)  
        StartCooldown(unit, true, spellId)  
        if racialData[spellId] and racialData[spellId].sharedCD then
            StartSharedCooldown(unit, spellId) 
        end
    elseif spellId == gladiatorMedallionSpellID or spellId == adaptationSpellID then
        ShowPvPItem(unit, false)  
        StartCooldown(unit, false, spellId)  
        StartSharedCooldown(unit, spellId)  
    end
end

function EpicPlates:OnCombatLogEventUnfiltered()
    local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId = CombatLogGetCurrentEventInfo()

    if (eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" or eventType == "SPELL_CAST_SUCCESS") and healingSpells[spellId] then
        if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 then
            healerGUIDs[sourceGUID] = true
            local unit = self:GetUnitByGUID(sourceGUID)
            if unit then
                self:UpdateHealerIcon(unit)
            end
        end
    end

    -- Trinket and Racial Ability Detection (existing code)
    if eventType == "SPELL_CAST_SUCCESS" then
        local unit = self:GetUnitByGUID(sourceGUID)

        if unit then
            if racialSpells[spellId] then
                ShowPvPItem(unit, true)  
                StartCooldown(unit, true, spellId)  
                StartSharedCooldown(unit, spellId)  
            elseif spellId == gladiatorMedallionSpellID or spellId == adaptationSpellID then
                ShowPvPItem(unit, false)  
                StartCooldown(unit, false, spellId)  
                StartSharedCooldown(unit, spellId)  
            end
        end
    end
end

function EpicPlates:UpdateHealerIcon(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end

    if not nameplate.HealerIcon then
        nameplate.HealerIcon = CreateFrame("Frame", nil, nameplate)
        nameplate.HealerIcon:SetSize(30, 30)
        nameplate.HealerIcon.Texture = nameplate.HealerIcon:CreateTexture(nil, "OVERLAY")
        nameplate.HealerIcon.Texture:SetAllPoints(nameplate.HealerIcon)
        nameplate.HealerIcon.Texture:SetTexture("Interface\\AddOns\\EpicPlates\\Textures\\Heal.png")
    end
    nameplate.HealerIcon:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "LEFT", -40, 0)
    nameplate.HealerIcon:Show()
end

function EpicPlates:OnArenaOpponentUpdate(event, unit, type)
    if not unit or not UnitIsPlayer(unit) or not UnitIsEnemy("player", unit) then
        return
    end

    if type == "seen" then
        ShowPvPItem(unit, false)  
        ShowPvPItem(unit, true)   
    end
end

function EpicPlates:OnArenaCCSpellUpdate(event, unit, spellID)
    if not UnitIsPlayer(unit) or not IsInInstance() or not UnitIsEnemy("player", unit) then return end

end

function EpicPlates:GetUnitByGUID(guid)
    local units = {"target", "focus", "mouseover"}
    for i = 1, 40 do
        table.insert(units, "nameplate" .. i)
    end

    for _, unit in ipairs(units) do
        if UnitGUID(unit) == guid then
            return unit
        end
    end
    return nil
end

function EpicPlates:UpdateAuras(unit)
    local NamePlate = C_NamePlate.GetNamePlateForUnit(unit)
    local UnitFrame = NamePlate and NamePlate.UnitFrame

    if not UnitFrame then return end

    -- Hide buffs and debuffs if the unit is not the target or mouseover
    if not UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "mouseover") then
        for i = 1, MAX_BUFFS do
            if UnitFrame.buffIcons[i] then
                UnitFrame.buffIcons[i].icon:Hide()
                UnitFrame.buffIcons[i].timer:Hide()
                if UnitFrame.buffIcons[i].stackCount then
                    UnitFrame.buffIcons[i].stackCount:Hide()
                end
                -- Ensure glow is removed, but only if updateFrame exists
                if UnitFrame.buffIcons[i].updateFrame then
                    ActionButton_HideOverlayGlow(UnitFrame.buffIcons[i].updateFrame)
                end
            end
        end
        for i = 1, MAX_DEBUFFS do
            if UnitFrame.debuffIcons[i] then
                UnitFrame.debuffIcons[i].icon:Hide()
                UnitFrame.debuffIcons[i].timer:Hide()
                if UnitFrame.debuffIcons[i].stackCount then
                    UnitFrame.debuffIcons[i].stackCount:Hide()
                end
                -- Ensure glow is removed, but only if updateFrame exists
                if UnitFrame.debuffIcons[i].updateFrame then
                    ActionButton_HideOverlayGlow(UnitFrame.debuffIcons[i].updateFrame)
                end
            end
        end
        return
    end

    local buffIndex = 1
    local debuffIndex = 1
    local currentTime = GetTime()

    -- Buffs processing
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, AuraUtil.AuraFilters.Helpful)
        if not aura or buffIndex > MAX_BUFFS then break end

        -- Filtering logic to skip certain spells
        if not self:IsAuraFiltered(aura.name, aura.spellId, aura.sourceName, aura.expirationTime - currentTime) then
            local auraUpdateType = AuraUtil.ProcessAura(aura, false, false, true, true)
            if auraUpdateType == AuraUtil.AuraUpdateChangedType.Buff then
                self:HandleAuraDisplay(UnitFrame.buffIcons[buffIndex], aura, currentTime, UnitFrame)
                buffIndex = buffIndex + 1
            end
        end
    end

    -- Debuffs processing
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, AuraUtil.AuraFilters.Harmful)
        if not aura or debuffIndex > MAX_DEBUFFS then break end

        -- Filtering logic to skip certain spells
        if not self:IsAuraFiltered(aura.name, aura.spellId, aura.sourceName, aura.expirationTime - currentTime) then
            local auraUpdateType = AuraUtil.ProcessAura(aura, false, true, false, false)
            if auraUpdateType == AuraUtil.AuraUpdateChangedType.Debuff then
                self:HandleAuraDisplay(UnitFrame.debuffIcons[debuffIndex], aura, currentTime, UnitFrame)
                debuffIndex = debuffIndex + 1
            end
        end
    end

    -- Hide extra icons and stack counts
    for i = buffIndex, MAX_BUFFS do
        if UnitFrame.buffIcons[i] then
            UnitFrame.buffIcons[i].icon:Hide()
            UnitFrame.buffIcons[i].timer:Hide()
            if UnitFrame.buffIcons[i].stackCount then
                UnitFrame.buffIcons[i].stackCount:Hide()
            end
            if UnitFrame.buffIcons[i].updateFrame then
                ActionButton_HideOverlayGlow(UnitFrame.buffIcons[i].updateFrame)
            end
        end
    end
    for i = debuffIndex, MAX_DEBUFFS do
        if UnitFrame.debuffIcons[i] then
            UnitFrame.debuffIcons[i].icon:Hide()
            UnitFrame.debuffIcons[i].timer:Hide()
            if UnitFrame.debuffIcons[i].stackCount then
                UnitFrame.debuffIcons[i].stackCount:Hide()
            end
            if UnitFrame.debuffIcons[i].updateFrame then
                ActionButton_HideOverlayGlow(UnitFrame.debuffIcons[i].updateFrame)
            end
        end
    end
end

function EpicPlates:HandleAuraDisplay(iconTable, aura, currentTime, UnitFrame)
    local icon = iconTable.icon
    if not icon then
        icon = UnitFrame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(self.db.profile.iconSize, self.db.profile.iconSize)
        iconTable.icon = icon
    end

    icon:SetTexture(aura.icon)
    icon:Show()

    local timer = iconTable.timer
    if not timer then
        timer = UnitFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        iconTable.timer = timer
    end

    timer:ClearAllPoints()
    timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
    timer:SetFont(LSM:Fetch("font", self.db.profile.timerFont), self.db.profile.timerFontSize, "OUTLINE")
    timer:Show()

    if not iconTable.updateFrame then
        iconTable.updateFrame = CreateFrame("Frame", nil, UnitFrame)
        iconTable.updateFrame:SetAllPoints(icon) 
    end

    iconTable.updateFrame:SetScript("OnUpdate", nil)

    iconTable.updateFrame:SetScript("OnUpdate", function(self, elapsed)
        local remainingTime = aura.expirationTime - GetTime()

        if remainingTime > 0 then
            timer:SetText(string.format("%.1f", remainingTime))

            if remainingTime > 5 then
                timer:SetTextColor(0, 1, 0)  
            else
                timer:SetTextColor(1, 0, 0)  
            end

            if EpicPlates.db.profile.iconGlowEnabled and remainingTime <= 5 and not iconTable.updateFrame.glowApplied and icon:IsShown() then
                ActionButton_ShowOverlayGlow(iconTable.updateFrame)
                iconTable.updateFrame.glowApplied = true
            end

            if remainingTime <= 0 and iconTable.updateFrame.glowApplied then
                ActionButton_HideOverlayGlow(iconTable.updateFrame)
                iconTable.updateFrame.glowApplied = false
            end
        else
            
            timer:Hide()
            icon:Hide()
            if iconTable.updateFrame.glowApplied then
                ActionButton_HideOverlayGlow(iconTable.updateFrame)
                iconTable.updateFrame.glowApplied = false
            end
           
            self:SetScript("OnUpdate", nil)
        end
    end)

    if not EpicPlates.db.profile.iconGlowEnabled and iconTable.updateFrame.glowApplied then
        ActionButton_HideOverlayGlow(iconTable.updateFrame)
        iconTable.updateFrame.glowApplied = false
    end

    icon:SetScript("OnEnter", function(self)
        if aura and aura.index and aura.index > 0 then
            local filter = aura.isHarmful and "HARMFUL" or "HELPFUL"
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(UnitFrame.unit, aura.index, filter)
            GameTooltip:Show()
        else
            GameTooltip:Hide()
        end
    end)

    icon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function EpicPlates:HandleAuraApplied(unit, spellId, auraType)
    self:UpdateAuras(unit)
end

function EpicPlates:HandleAuraRemoved(unit, spellId, auraType)
    self:UpdateAuras(unit)
end

function EpicPlates:IsAuraFiltered(spellName, spellID, casterName, remainingTime)
    local filters = self.db.profile.auraFilters
    local alwaysShow = self.db.profile.alwaysShow
    local thresholdMore = self.db.profile.auraThresholdMore or 0
    local thresholdLess = self.db.profile.auraThresholdLess or 60

    -- Check if the aura should always be shown based on spellID or spellName
    if spellID then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo and (alwaysShow.spellIDs[spellID] or alwaysShow.spellNames[spellInfo.name]) then
            return false
        end
    elseif spellName and alwaysShow.spellNames[spellName] then
        return false
    end

    -- Filter based on remaining time thresholds
    if remainingTime and (remainingTime < thresholdMore or remainingTime > thresholdLess) then
        return true
    end

    -- Filter based on spell ID, spell name, or caster name
    if spellID and filters.spellIDs[spellID] then
        return true
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

    -- If none of the filters apply, the aura is not filtered
    return false
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

        local texture = LSM:Fetch("statusbar", self.db.profile.healthBarTexture)
        UnitFrame.healthBar:SetStatusBarTexture(texture)

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

function EpicPlates:ApplyTextureToAllNameplates()
    local texture = LSM:Fetch("statusbar", self.db.profile.healthBarTexture)
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        nameplate.UnitFrame.healthBar:SetStatusBarTexture(texture)
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

function EpicPlates:CompactUnitFrame_UpdateName(frame)
    if frame.unit and strsub(frame.unit, 1, 9) == "nameplate" then
        self:NiceNameplateInfo_Update(frame.unit)
        self:NiceNameplateFrames_Update(frame.unit)
        self:UpdateHealthBarWithPercent(frame.unit)  
    end
end

function EpicPlates:ApplyHealthBarTexture(texture)
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        nameplate.UnitFrame.healthBar:SetStatusBarTexture(texture)
    end
end

local function UpdateNameplateHealthBar(nameplate)
    local texture = LSM:Fetch("statusbar", EpicPlates.db.profile.healthBarTexture)
    nameplate.healthBar:SetStatusBarTexture(texture)
end

local function ApplyTextureToAllNameplates()
    local texture = LSM:Fetch("statusbar", EpicPlates.db.profile.healthBarTexture)
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        nameplate.UnitFrame.healthBar:SetStatusBarTexture(texture)
    end
end

function EpicPlates:UpdateHealthBarWithPercent(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.UnitFrame then
        local healthBar = nameplate.UnitFrame.healthBar
        if UnitIsUnit(unit, "target") and self.db.profile.showHealthPercent then
            local healthPercent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
            if not healthBar.text then
                healthBar.text = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                healthBar.text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
            end
            healthBar.text:SetText(string.format("%.1f%%", healthPercent))
            local color = self.db.profile.healthPercentFontColor or {1, 1, 1}  
            local r, g, b = unpack(color)
            healthBar.text:SetTextColor(r, g, b)  
            healthBar.text:Show()
        else
            if healthBar.text then
                healthBar.text:Hide()
            end
        end
    end
end

function EpicPlates:UpdateAllNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local unit = namePlate.UnitFrame.unit
        if unit then
            self:UpdateAuras(unit)
            self:UpdateHealthBarWithPercent(unit)
        end
    end
end

function EpicPlates:UpdateAllAuras()
    for _, NamePlate in pairs(C_NamePlate.GetNamePlates()) do
        local UnitFrame = NamePlate.UnitFrame
        if UnitFrame and UnitFrame.unit then
            self:UpdateAuras(UnitFrame.unit)
            self:UpdateHealthBarWithPercent(UnitFrame.unit)  
        end
    end
end

function EpicPlates:CreateAuraIcons(UnitFrame)
    if not UnitFrame then return end

    UnitFrame.buffIcons = {}
    UnitFrame.debuffIcons = {}

    local iconSize = self.db.profile.iconSize
    local rowSpacing = 14  -- Space between rows

    local iconXOffset = self.db.profile.iconXOffset or 0
    local iconYOffset = self.db.profile.iconYOffset or 0

    local buffIconPos = self.db.profile.buffIconPositions or { y = 0, x = 0 }
    local debuffIconPos = self.db.profile.debuffIconPositions or { y = 0, x = 0 }

    -- Create Buff Icons
    for i = 1, MAX_BUFFS do
        local icon = UnitFrame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(iconSize, iconSize)

        local availableWidth = UnitFrame:GetWidth()
        local maxIconsPerRow = math.floor((availableWidth + 2) / (iconSize + 2))

        local row = math.floor((i - 1) / maxIconsPerRow)
        local col = (i - 1) % maxIconsPerRow
        local xPos = col * (iconSize + 2) + iconXOffset + buffIconPos.x
        local yPos = buffIconPos.y + row * (iconSize + rowSpacing) + iconYOffset

        icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", xPos, yPos)
        icon:Hide()

        local timer = UnitFrame:CreateFontString(nil, "OVERLAY")
        timer:SetFontObject(SystemFont_Outline_Small)
        timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        timer:Hide()

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

        icon:Show()
    end

    -- Create Debuff Icons
    for i = 1, MAX_DEBUFFS do
        local icon = UnitFrame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(iconSize, iconSize)

        local availableWidth = UnitFrame:GetWidth()
        local maxIconsPerRow = math.floor((availableWidth + 2) / (iconSize + 2))

        local row = math.floor((i - 1) / maxIconsPerRow)
        local col = (i - 1) % maxIconsPerRow
        local xPos = col * (iconSize + 2) + iconXOffset + debuffIconPos.x
        local yPos = debuffIconPos.y + row * (iconSize + rowSpacing) + iconYOffset

        icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", xPos, yPos)
        icon:Hide()

        local timer = UnitFrame:CreateFontString(nil, "OVERLAY")
        timer:SetFontObject(SystemFont_Outline_Small)
        timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        timer:Hide()

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

        icon:Show()
    end

    self:UpdateIconSize()
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

function EpicPlates:UpdateIconPositions()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local UnitFrame = namePlate.UnitFrame
        if UnitFrame and UnitFrame.buffIcons and UnitFrame.debuffIcons then
            local iconXOffset = self.db.profile.iconXOffset or 0
            local iconYOffset = self.db.profile.iconYOffset or 0

            -- Adjust Buff Icons
            for i = 1, #UnitFrame.buffIcons do
                local icon = UnitFrame.buffIcons[i].icon
                local timer = UnitFrame.buffIcons[i].timer

                local availableWidth = UnitFrame:GetWidth()
                local maxIconsPerRow = math.floor((availableWidth + 2) / (ICON_SIZE + 2))

                local row = math.floor((i - 1) / maxIconsPerRow)
                local col = (i - 1) % maxIconsPerRow

                local xPos = col * (ICON_SIZE + 2) + iconXOffset
                local yPos = BUFF_ICON_OFFSET_Y + row * (ICON_SIZE + LINE_SPACING_Y) + iconYOffset

                icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", xPos, yPos)
                icon:Show()
              
                timer:ClearAllPoints()
                if self.db.profile.timerPosition == "MIDDLE" then
                    timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
                else
                    timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
                end
              
                local font, size, flags = timer:GetFont()
                timer:SetFont(font, size, flags)
                timer:Show()
            end

            -- Adjust Debuff Icons (same logic as above)
            for i = 1, #UnitFrame.debuffIcons do
                local icon = UnitFrame.debuffIcons[i].icon
                local timer = UnitFrame.debuffIcons[i].timer

                local availableWidth = UnitFrame:GetWidth()
                local maxIconsPerRow = math.floor((availableWidth + 2) / (ICON_SIZE + 2))

                local row = math.floor((i - 1) / maxIconsPerRow)
                local col = (i - 1) % maxIconsPerRow

                local xPos = col * (ICON_SIZE + 2) + iconXOffset
                local yPos = DEBUFF_ICON_OFFSET_Y + row * (ICON_SIZE + LINE_SPACING_Y) + iconYOffset

                icon:SetPoint("BOTTOMLEFT", UnitFrame, "TOPLEFT", xPos, yPos)
                icon:Show()

                timer:ClearAllPoints()
                if self.db.profile.timerPosition == "MIDDLE" then
                    timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
                else
                    timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
                end

                local font, size, flags = timer:GetFont()
                timer:SetFont(font, size, flags)
                timer:Show()
            end
        end
    end
end

function EpicPlates:UpdateIconSize()
    local iconSize = self.db.profile.iconSize
    local timerFontSize = self.db.profile.timerFontSize
    local timerFont = LSM:Fetch("font", self.db.profile.timerFont)  
    local timerFontColor = self.db.profile.timerFontColor or {1, 1, 1} 
    local timerPosition = self.db.profile.timerPosition  -- Get the timer position

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
                if timerPosition == "MIDDLE" then
                    timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
                else
                    timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
                end
            end

            for i = 1, #UnitFrame.debuffIcons do
                local icon = UnitFrame.debuffIcons[i].icon
                local timer = UnitFrame.debuffIcons[i].timer

                icon:SetSize(iconSize, iconSize)
                timer:SetFont(timerFont, timerFontSize, "OUTLINE")
                timer:SetTextColor(unpack(timerFontColor))
                timer:ClearAllPoints()
                if timerPosition == "MIDDLE" then
                    timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
                else
                    timer:SetPoint("TOP", icon, "BOTTOM", 0, -2)
                end
            end
        end
    end
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

function EpicPlates:PromptReloadUI()
    StaticPopupDialogs["EPICPLATES_RELOADUI"] = {
        text = "|cFFFF0000You have changed the icon offsets.|r\n\n|cFFFFFF00These changes require a UI reload to take effect.|r\n\n|cFF00FF00Would you like to reload the UI now?|r",
        button1 = "|cFF00FF00Reload UI|r",
        button2 = "|cFFFF0000Cancel|r",
        OnAccept = function()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("EPICPLATES_RELOADUI")
end

function EpicPlates:NAME_PLATE_UNIT_ADDED(_, unit)
    if UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
        ShowPvPItem(unit, true)  -- Show racial ability
        ShowPvPItem(unit, false) -- Show trinket
    else
        HidePvPItem(unit, true)  -- Hide racial ability
        HidePvPItem(unit, false) -- Hide trinket
    end

    -- Healer Icon Detection
    local guid = UnitGUID(unit)
    if healerGUIDs[guid] then
        self:UpdateHealerIcon(unit)
    end
end

function EpicPlates:NAME_PLATE_UNIT_REMOVED(_, unit)
    HidePvPItem(unit, true)  -- Hide racial ability
    HidePvPItem(unit, false) -- Hide trinket

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.HealerIcon then
        nameplate.HealerIcon:Hide()
    end
end


function EpicPlates:UNIT_THREAT_LIST_UPDATE(_, unit)
    if unit and unit:match('nameplate') then
        self:NiceNameplateInfo_Update(unit)
        self:NiceNameplateFrames_Update(unit)
        self:UpdateHealthBarWithPercent(unit)  
    end
end

function EpicPlates:PLAYER_TARGET_CHANGED()
    self:UpdateAllNameplates()
end

function EpicPlates:NAME_PLATE_CREATED(_, frame)
    if not frame then
        print("Error: Nameplate frame is nil")
        return
    end

    self:NiceNameplateInfo_Create(frame)
    if frame.UnitFrame then
        local texture = LSM:Fetch("statusbar", self.db.profile.healthBarTexture)
        frame.UnitFrame.healthBar:SetStatusBarTexture(texture)
        self:UpdateHealthBarWithPercent(frame.UnitFrame.unit)
    end
end

-- Ensure this function is placed before it is called in OnEnable
function EpicPlates:InitializeAlwaysShow()
    if not self.db.profile.alwaysShow then
        self.db.profile.alwaysShow = {
            spellIDs = {},
            spellNames = {}
        }
    end

    if _G.defaultSpells1 then
        for _, spellID in ipairs(_G.defaultSpells1) do
            self.db.profile.alwaysShow.spellIDs[spellID] = true
        end
    end

    if _G.defaultSpells2 then
        for _, spellID in ipairs(_G.defaultSpells2) do
            self.db.profile.alwaysShow.spellIDs[spellID] = true
        end
    end
end

function EpicPlates:OnEnable()
    C_CVar.SetCVar('nameplateShowAll', '1')
    C_CVar.SetCVar('nameplateShowFriends', '0') 
    C_CVar.SetCVar('nameplateShowFriendlyNPCs', '0') 
    C_CVar.SetCVar('showQuestTrackingTooltips', '1')

    self:RegisterEvent('NAME_PLATE_CREATED')
    self:RegisterEvent('NAME_PLATE_UNIT_ADDED')
    self:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
    self:RegisterEvent('UNIT_THREAT_LIST_UPDATE')
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellCastSuccess")
    self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE", "OnArenaCCSpellUpdate")
    self:RegisterEvent("ARENA_OPPONENT_UPDATE", "OnArenaOpponentUpdate")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")

    if not self:IsHooked('CompactUnitFrame_UpdateName') then
        self:SecureHook('CompactUnitFrame_UpdateName')
    end

    self:ScheduleRepeatingTimer("UpdateAllAuras", 0.1)

    self:DisableDefaultBuffsDebuffs()

    C_Timer.After(1, function()
        self:InitializeAlwaysShow()
    end)
end

function EpicPlates:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("EpicPlatesDB", {
        profile = {
            iconSize = 20,
            timerFontSize = 12,
            timerFont = "Arial Narrow",
            timerFontColor = {1, 1, 1},
            healthBarTexture = LSM:GetDefault("statusbar"),
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

    if not self.db then
        
        return
    end

    self:SetupOptions()
    self:UpdateIconPositions()
    self:OnEnable()
    self:UpdateTimerFontSize()

    if LDBIcon and EpicPlatesLDB then
        LDBIcon:Register("EpicPlates", EpicPlatesLDB, self.db.profile.minimap)
    end

    self:UpdateIconSize()
    self:ApplyTextureToAllNameplates()
end

function EpicPlates:SetupOptions()
    
    local options = {
        name = "EpicPlates",
        type = "group",
        args = {
            iconSize = {
                type = "range",
                name = "Icon Size",
                min = 10,
                max = 50,
                step = 1,
                get = function() return self.db.profile.iconSize end,
                set = function(_, value) self.db.profile.iconSize = value end
            },
            
        }
    }

    -- Register the options
    AceConfig:RegisterOptionsTable("EpicPlates", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")

    -- Ensure db callbacks are set
    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateIconSize")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateIconSize")
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateIconSize")
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

-- Script to handle various events and apply updates accordingly
EpicPlates.Events = CreateFrame("Frame")
EpicPlates.Events:RegisterEvent("ADDON_LOADED")
EpicPlates.Events:RegisterEvent("PLAYER_LOGIN")

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

-- Hook into the nameplate event
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
        if unit and UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
            EpicPlates:NAME_PLATE_UNIT_ADDED(nil, unit)
            AddHealerIcon(unit)
        else
            
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        if unit then
            EpicPlates:NAME_PLATE_UNIT_REMOVED(nil, unit)
            RemoveHealerIcon(unit)
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if strmatch(unit, "nameplate%d+") then
            EpicPlates:UpdateAuras(unit)
        end
    end
end)
