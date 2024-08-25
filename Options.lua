-- Made by Sharpedge_Gaming
-- v1.1 - 11.0.2

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LDBIcon = LibStub("LibDBIcon-1.0")

local options = {
    name = "EpicPlates",
    type = 'group',
    args = {

        -- Health Bar Settings
        healthBarSettingsHeader = {
            type = 'header',
            name = "Health Bar Settings",
            order = 1,
        },
        showHealthPercent = {
            type = 'toggle',
            name = "Show Health Percentage",
            desc = "|cFFFFD700Enable this option|r to display the health percentage on the nameplate's health bar. This option is useful if you prefer to see exact health values rather than just relying on the visual health bar, allowing for more precise decision-making during combat.",
            order = 2,
            get = function() 
                return EpicPlates.db.profile.showHealthPercent 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.showHealthPercent = value
                EpicPlates:UpdateAllNameplates()  
            end,
        },
        healthPercentFontColor = {
            type = 'color',
            name = "Health Percent Font Color",
            desc = "|cFF00FF00Choose the color|r of the font used to display the health percentage on nameplates. This setting allows customization to match your user interface's theme or to make the text more readable against different backgrounds.",
            hasAlpha = false,
            order = 3,
            get = function()
                local color = EpicPlates.db.profile.healthPercentFontColor or {1, 1, 1}
                return unpack(color)
            end,
            set = function(_, r, g, b)
                EpicPlates.db.profile.healthPercentFontColor = {r, g, b}
                EpicPlates:UpdateAllNameplates()  
            end,
            disabled = function()
                return not EpicPlates.db.profile.showHealthPercent
            end,
        },
        healthBarTexture = {
            type = "select",
            dialogControl = 'LSM30_Statusbar',
            name = "Health Bar Texture",
            desc = "|cFF00BFFFSelect the texture|r used for the nameplate's health bar. Different textures can provide better visibility or better match the overall aesthetic of your user interface.",
            values = LSM:HashTable("statusbar"),
            order = 4,
            get = function() 
                return EpicPlates.db.profile.healthBarTexture 
            end,
            set = function(_, value)
                EpicPlates.db.profile.healthBarTexture = value
                EpicPlates:ApplyTextureToAllNameplates()  
            end,
        },

        -- Icon Settings
        iconSettingsHeader = {
            type = 'header',
            name = "Icon Settings",
            order = 5,
        },
        iconSize = {
            type = 'range',
            name = "Icon Size",
            desc = "|cFFDAA520Adjust the size|r of buff and debuff icons displayed above nameplates. Larger icons are easier to see but might overlap with other UI elements, while smaller icons are less intrusive but can be harder to notice.",
            min = 15,
            max = 25,
            step = 1,
            order = 6,
            get = function() 
                return EpicPlates.db.profile.iconSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.iconSize = value
                EpicPlates:UpdateIconSize()
            end,
        },
        iconXOffset = {
            type = 'range',
            name = "Icon X Offset (Right to Left)",
            desc = "|cFFFF4500Adjust the horizontal (X) offset|r for icons displayed above nameplates. This setting allows you to shift the icons left or right to better align with other UI elements or to create a custom layout that suits your preferences.",
            min = -50,
            max = 50,
            step = 1,
            order = 7,
            get = function() 
                return EpicPlates.db.profile.iconXOffset 
            end,
             set = function(_, value) 
        EpicPlates.db.profile.iconXOffset = value
        EpicPlates:PromptReloadUI()
    end,
        },
        iconYOffset = {
            type = 'range',
            name = "Icon Y Offset (Up and Down)",
            desc = "|cFF8A2BE2Adjust the vertical (Y) offset|r for icons displayed above nameplates. Use this to move the icons higher or lower, which is particularly helpful if the default positioning causes them to overlap with other elements on your screen.",
            min = -50,
            max = 50,
            step = 1,
            order = 8,
            get = function() 
                return EpicPlates.db.profile.iconYOffset 
            end,
           set = function(_, value) 
        EpicPlates.db.profile.iconYOffset = value
        EpicPlates:PromptReloadUI()
    end,
        },

        -- Timer Settings
        timerSettingsHeader = {
            type = 'header',
            name = "Timer Settings",
            order = 9,
        },
        timerFont = {
            type = 'select',
            name = "Timer Font",
            desc = "|cFF7FFF00Select the font|r used for the timer text on icons. This option allows you to choose a font that best matches your UI or personal aesthetic preferences, ensuring consistency in your interface.",
            values = LSM:HashTable("font"),
            dialogControl = 'LSM30_Font',
            order = 10,
            get = function() 
                return EpicPlates.db.profile.timerFont 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.timerFont = value
                EpicPlates:UpdateTimerFontSize()
            end,
        },
        timerFontSize = {
            type = 'range',
            name = "Timer Font Size",
            desc = "|cFFCD5C5CAdjust the font size|r of the timer text on icons. Larger text is easier to read but may overlap with the icon or other UI elements, while smaller text is less intrusive but can be harder to read at a glance.",
            min = 6,
            max = 24,
            step = 2,
            order = 11,
            get = function() 
                return EpicPlates.db.profile.timerFontSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.timerFontSize = value
                EpicPlates:UpdateTimerFontSize()
            end,
        },
        useDynamicColor = {
            type = 'toggle',
            name = "Use Dynamic Countdown Color",
            desc = "|cFF4682B4Enable this option|r to make the timer text change color dynamically as the remaining time decreases. The color starts as green and gradually shifts to red, providing a visual cue for when buffs or debuffs are about to expire.",
            order = 12,
            get = function() 
                return EpicPlates.db.profile.colorMode == "dynamic"
            end,
            set = function(_, value) 
                EpicPlates.db.profile.colorMode = value and "dynamic" or "static"
                EpicPlates:UpdateIconSize()
            end,
        },
        timerFontColor = {
            type = 'color',
            name = "Timer Font Color",
            desc = "|cFF9932CCustomize the color|r of the timer text displayed on icons. This option is only available when 'Use Fixed Color' is enabled, allowing you to select a color that contrasts well with the icon's background for better readability.",
            hasAlpha = false,
            order = 13,
            get = function()
                return unpack(EpicPlates.db.profile.timerFontColor or {1, 1, 1})
            end,
            set = function(_, r, g, b)
                EpicPlates.db.profile.timerFontColor = {r, g, b}
                EpicPlates:UpdateIconSize()
            end,
            disabled = function()
                return EpicPlates.db.profile.colorMode == "dynamic"
            end,
        },
timerPosition = {
    type = 'select',
    name = "Timer Position",
    desc = "|cFFDA70D6Select the position|r for the timer text on the icons. You can choose to display the timer below the icon, center it within the icon itself, or hide the timer entirely.",
    values = {
        BELOW = "Below Icon",
        MIDDLE = "Center of Icon",
        NONE = "No Timers",  -- Add this line
    },
    order = 14,
    get = function() 
        return EpicPlates.db.profile.timerPosition 
    end,
    set = function(_, value) 
        EpicPlates.db.profile.timerPosition = value
        EpicPlates:UpdateIconSize()  
    end,
        },

        -- Minimap Icon Settings
        minimapIconHeader = {
            type = 'header',
            name = "Minimap Icon",
            order = 15,
        },
        showMinimapIcon = {
            type = "toggle",
            name = "Show Minimap Icon",
            desc = "|cFF1E90FFToggle the display|r of the EpicPlates minimap icon. This icon provides quick access to the addon's settings, but if you prefer to reduce clutter on your minimap or access settings through other means, you can disable the icon here.",
            order = 16,
            get = function()
                return not EpicPlates.db.profile.minimap.hide
            end,
            set = function(_, value)
                EpicPlates.db.profile.minimap.hide = not value
                if value then
                    LDBIcon:Show("EpicPlates")
                else
                    LDBIcon:Hide("EpicPlates")
                end
            end,
        },

        -- Aura Filters
        auraFiltersHeader = {
            type = 'header',
            name = "Aura Filters",
            order = 17,
        },
        addFilterByID = {
            type = 'input',
            name = "Add Filter by Spell ID",
            desc = "|cFFFF6347Enter the numerical ID|r of the spell you wish to filter out. This option allows you to hide a specific spell's auras from being displayed on nameplates, which is useful for reducing visual clutter or ignoring irrelevant buffs and debuffs.",
            order = 18,
            set = function(_, value)
                local spellID = tonumber(value)
                if spellID then
                    local spellInfo = C_Spell.GetSpellInfo(spellID)
                    if spellInfo then
                        EpicPlates.db.profile.auraFilters.spellIDs[spellID] = true
                        EpicPlates:UpdateAllAuras()
                    else
                        print("Error: Invalid Spell ID")
                    end
                else
                    print("Error: Please enter a valid Spell ID")
                end
            end,
        },
        addFilterByName = {
            type = 'input',
            name = "Add Filter by Spell Name",
            desc = "|cFF00CED1Enter the name|r of the spell you wish to filter out. This option hides the specified spell's auras from nameplates, useful for customizing which buffs and debuffs are important to track.",
            order = 19,
            set = function(_, value)
                local spellInfo = C_Spell.GetSpellInfo(value)
                if spellInfo then
                    EpicPlates.db.profile.auraFilters.spellNames[spellInfo.name] = true
                    EpicPlates:UpdateAllAuras()
                else
                    print("Error: Invalid Spell Name")
                end
            end,
        },
        addFilterByCaster = {
            type = 'input',
            name = "Add Filter by Caster Name",
            desc = "|cFF00FA9AEnter the name|r of the caster whose spells you want to filter. This setting hides all auras cast by the specified character from being displayed on nameplates, which is particularly useful in PvP or to ignore specific NPCs.",
            order = 20,
            set = function(_, value)
                EpicPlates.db.profile.auraFilters.casterNames[value] = true
                EpicPlates:UpdateAllAuras()
            end,
        },
removeFilter = {
    type = 'select',
    name = "Remove Filter",
    desc = "|cFFFFD700Select a filter|r to remove from the list. Removing a filter will allow the previously hidden auras to be displayed again on nameplates, which can be useful if your tracking needs change.",
    order = 21,
    values = function()
    local filters = {}
    local alwaysShow = EpicPlates.db.profile.alwaysShow
    if alwaysShow then
        if importantSpells then
            for _, spellID in ipairs(importantSpells) do
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    filters["id_" .. spellID] = "ID: " .. spellID .. " (" .. spellInfo.name .. ")"
                end
            end
        end
        if semiImportantSpells then
            for _, spellID in ipairs(semiImportantSpells) do
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    filters["id_" .. spellID] = "ID: " .. spellID .. " (" .. spellInfo.name .. ")"
                end
            end
        end
        for spellID in pairs(alwaysShow.spellIDs) do
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                filters["id_" .. spellID] = "ID: " .. spellID .. " (" .. spellInfo.name .. ")"
            end
        end
        for spellName in pairs(alwaysShow.spellNames) do
            filters["name_" .. spellName] = "Name: " .. spellName
        end
    end
    return filters
    end,
    set = function(_, value)
        local prefix, key = value:match("^(%a+)_(.+)$")
        local auraFilters = EpicPlates.db.profile.auraFilters
        if prefix == "id" then
            auraFilters.spellIDs[tonumber(key)] = nil
        elseif prefix == "name" then
            auraFilters.spellNames[key] = nil
        elseif prefix == "caster" then
            auraFilters.casterNames[key] = nil
        end
        EpicPlates:UpdateAllAuras()
    end,
        },

        -- Always Show Spells
        alwaysShowHeader = {
            type = 'header',
            name = "Always Show Spells",
            order = 22,
        },
        addAlwaysShowByID = {
            type = 'input',
            name = "Always Show by Spell ID",
            desc = "|cFF7B68EEEnter the numerical ID|r of the spell you want to always display on nameplates. For example, entering '774' would ensure that the Rejuvenation buff is always visible, regardless of other filtering settings.",
            order = 23,
            set = function(_, value)
                local spellID = tonumber(value)
                if spellID then
                    local spellInfo = C_Spell.GetSpellInfo(spellID)
                    if spellInfo then
                        EpicPlates.db.profile.alwaysShow.spellIDs[spellID] = true
                        EpicPlates:UpdateAllAuras()
                    else
                        print("Error: Invalid Spell ID")
                    end
                else
                    print("Error: Please enter a valid Spell ID")
                end
            end,
        },
        addAlwaysShowByName = {
            type = 'input',
            name = "Always Show by Spell Name",
            desc = "|cFF4682B4Enter the name|r of the spell you want to always display on nameplates. This option is useful for ensuring that critical buffs or debuffs are always visible, even if other filters are in place.",
            order = 24,
            set = function(_, value)
                local spellInfo = C_Spell.GetSpellInfo(value)
                if spellInfo then
                    EpicPlates.db.profile.alwaysShow.spellNames[spellInfo.name] = true
                    EpicPlates:UpdateAllAuras()
                else
                    print("Error: Invalid Spell Name")
                end
            end,
        },
        removeAlwaysShow = {
            type = 'select',
            name = "Remove Always Show Spell",
            desc = "|cFFDC143CRemove a spell|r from the always show list. This will stop the spell from being displayed on nameplates, which is useful if you no longer need to track it consistently.",
            order = 25,
            values = function()
                local filters = {}
                local alwaysShow = EpicPlates.db.profile.alwaysShow
                if alwaysShow then
                    for spellID in pairs(alwaysShow.spellIDs) do
                        local spellInfo = C_Spell.GetSpellInfo(spellID)
                        if spellInfo then
                            filters["id_" .. spellID] = "ID: " .. spellID .. " (" .. spellInfo.name .. ")"
                        end
                    end
                    for spellName in pairs(alwaysShow.spellNames) do
                        filters["name_" .. spellName] = "Name: " .. spellName
                    end
                end
                return filters
            end,
            set = function(_, value)
                local prefix, key = value:match("^(%a+)_(.+)$")
                local alwaysShow = EpicPlates.db.profile.alwaysShow
                if prefix == "id" then
                    alwaysShow.spellIDs[tonumber(key)] = nil
                elseif prefix == "name" then
                    alwaysShow.spellNames[key] = nil
                end
                EpicPlates:UpdateAllAuras()
            end,
        },

        -- Aura Settings
        auraSettingsHeader = {
            type = 'header',
            name = "Aura Settings",
            order = 26,
        },
        showAurasWithMoreThan = {
            type = 'range',
            name = "Show Auras with More Than X Seconds",
            desc = "|cFF8B0000This setting controls the display of auras|r based on their remaining duration. Only auras with more than the specified number of seconds remaining will be shown on nameplates. This helps in focusing on long-lasting buffs or debuffs, filtering out those that might not be as impactful.",
            min = 0,
            max = 60,
            step = 1,
            order = 27,
            get = function() 
                return EpicPlates.db.profile.auraThresholdMore 
            end,
            set = function(_, value) 
                if value > 60 then 
                    value = 60 
                    print("Warning: The maximum allowed value is 60 seconds. The value has been adjusted accordingly.")
                end  
                EpicPlates.db.profile.auraThresholdMore = value
                EpicPlates:UpdateAllAuras()
            end,
        },
        showAurasWithLessThan = {
            type = 'range',
            name = "Show Auras with Less Than X Seconds",
            desc = "|cFF008080This setting controls the display of auras|r based on their remaining duration. Only auras with less than the specified number of seconds remaining will be shown on nameplates, which is especially useful for tracking auras that are about to expire.",
            min = 0,
            max = 60,
            step = 1,
            order = 28,
            get = function() 
                return EpicPlates.db.profile.auraThresholdLess 
            end,
            set = function(_, value) 
                if value > 60 then 
                    value = 60 
                    print("Warning: The maximum allowed value is 60 seconds. The value has been adjusted accordingly.")
                end  
                EpicPlates.db.profile.auraThresholdLess = value
                EpicPlates:UpdateAllAuras()
            end,
        },
    },
}

AceConfig:RegisterOptionsTable("EpicPlates", options)
AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")
