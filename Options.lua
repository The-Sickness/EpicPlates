-- Made by Sharpedge_Gaming
-- v1.5 - 11.0.2

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LDBIcon = LibStub("LibDBIcon-1.0")

local options = {
    name = "EpicPlates",
    type = 'group',
    args = {
                -- Health Bar Settings Header
        healthBarSettingsHeader = {
            type = 'header',
            name = "Health Bar Settings",
            order = 1,
        },
        healthBarTexture = {
            type = "select",
            dialogControl = 'LSM30_Statusbar',
            name = "Health Bar Texture",
            desc = "Select the texture for the nameplate health bar.",
            values = LSM:HashTable("statusbar"),
            get = function(info) return EpicPlates.db.profile.healthBarTexture end,
            set = function(info, value)
                EpicPlates.db.profile.healthBarTexture = value
                EpicPlates:ApplyTextureToAllNameplates()  -- Apply the texture change immediately
            end,
            order = 2,
        },
        showHealthPercent = {
            type = 'toggle',
            name = "Show Health Percentage",
            desc = "Enable this option to display the health percentage on the nameplate health bar.",
            order = 3,
            get = function() 
                return EpicPlates.db.profile.showHealthPercent 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.showHealthPercent = value
                EpicPlates:UpdateAllNameplates()  -- Update all nameplates to reflect the new setting
            end,
        },

        -- Icon Settings Header
        iconSettingsHeader = {
            type = 'header',
            name = "Icon Settings",
            order = 3,
        },
        iconSize = {
            type = 'range',
            name = "Icon Size",
            desc = "Adjust the size of buff/debuff icons displayed above nameplates.\n\n" ..
                   "Use this slider to increase or decrease the icon size. Larger icons are more visible, " ..
                   "but may overlap with other UI elements. Smaller icons take up less space but may be harder to see.",
            min = 15,
            max = 25,
            step = 1,
            order = 4,
            get = function() 
                return EpicPlates.db.profile.iconSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.iconSize = value
                EpicPlates:UpdateIconSize()
            end,
        },
        spacer1 = {
            type = 'description',
            name = "",
            order = 5,
        },
        
        -- Timer Settings Header
        timerSettingsHeader = {
            type = 'header',
            name = "Timer Settings",
            order = 6,
        },
        timerFont = {
            type = 'select',
            name = "Timer Font",
            desc = "Select the font used for the timer text on icons.\n\n" ..
                   "Choose a font that best fits your UI preferences. The font you select will be used for all timer text displayed on icons.",
            values = LSM:HashTable("font"),
            dialogControl = 'LSM30_Font',
            order = 7,
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
            desc = "Adjust the font size of the timer text on icons.\n\n" ..
                   "Use this slider to increase or decrease the size of the timer font. " ..
                   "A larger font size will make the countdown more visible, but may overlap with other UI elements.",
            min = 6,
            max = 24,
            step = 1,
            order = 8,
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
            desc = "Enable this option to make the timer color change dynamically based on the remaining time.\n\n" ..
                   "When enabled, the timer will start with a green color and gradually change to red as the " ..
                   "time runs out, making it easier to track important buffs and debuffs during gameplay.",
            order = 9,
            get = function() 
                return EpicPlates.db.profile.colorMode == "dynamic"
            end,
            set = function(_, value) 
                if value then
                    EpicPlates.db.profile.colorMode = "dynamic"
                else
                    EpicPlates.db.profile.colorMode = "static"
                end
            end,
        },
        timerFontColor = {
            type = 'color',
            name = "Timer Font Color",
            desc = "Select the color for the timer text displayed on icons.\n\n" ..
                   "This setting is only available when 'Use Fixed Color' is enabled. " ..
                   "Use the color picker to choose a color that stands out against the background for better readability.",
            hasAlpha = false,
            order = 10,
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
        spacer2 = {
            type = 'description',
            name = "",
            order = 11,
        },
        
        -- Minimap Icon Settings Header
        minimapIconHeader = {
            type = 'header',
            name = "Minimap Icon",
            order = 12,
        },
        showMinimapIcon = {
            type = "toggle",
            name = "Show Minimap Icon",
            desc = "Toggle the display of the EpicPlates minimap icon.\n\n" ..
                   "The minimap icon provides quick access to the EpicPlates settings. " ..
                   "Disable this option if you prefer not to have the icon on your minimap.",
            order = 13,
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
        
        spacer3 = {
            type = 'description',
            name = "",
            order = 14,
        },
        
        -- Aura Filters Header
        auraFiltersHeader = {
            type = 'header',
            name = "Aura Filters",
            order = 15,
        },
        addFilterByID = {
            type = 'input',
            name = "Add Filter by Spell ID",
            desc = "|cFF00FF00Add Filter by Spell ID|r\n\n" ..
                   "Enter the numerical ID of the spell you wish to filter. This will hide the specified spell's auras " ..
                   "from being displayed on nameplates.\n\nExample: Enter '774' to filter out the Rejuvenation buff.",
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
            order = 16,
        },
        addFilterByName = {
            type = 'input',
            name = "Add Filter by Spell Name",
            desc = "|cFF00FF00Add Filter by Spell Name|r\n\n" ..
                   "Enter the name of the spell you wish to filter. This will hide the specified spell's auras " ..
                   "from being displayed on nameplates.\n\nExample: Enter 'Rejuvenation' to filter out the Rejuvenation buff.",
            set = function(_, value)
                local spellInfo = C_Spell.GetSpellInfo(value)
                if spellInfo then
                    EpicPlates.db.profile.auraFilters.spellNames[spellInfo.name] = true
                    EpicPlates:UpdateAllAuras()
                else
                    print("Error: Invalid Spell Name")
                end
            end,
            order = 17,
        },
        addFilterByCaster = {
            type = 'input',
            name = "Add Filter by Caster Name",
            desc = "|cFF00FF00Add Filter by Caster Name|r\n\n" ..
                   "Enter the name of the caster whose spells you want to filter. This will hide all auras cast by this " ..
                   "character from being displayed on nameplates.\n\nExample: Enter 'Thrall' to filter all spells cast by Thrall.",
            set = function(_, value)
                EpicPlates.db.profile.auraFilters.casterNames[value] = true
                EpicPlates:UpdateAllAuras()
            end,
            order = 18,
        },
        removeFilter = {
            type = 'select',
            name = "Remove Filter",
            desc = "Remove an existing filter by selecting it from the list.\n\n" ..
                   "Select the filter you wish to remove from the dropdown menu. This will allow the previously filtered " ..
                   "spell or caster's auras to be displayed again on nameplates.",
            values = function()
                local filters = {}
                
                local auraFilters = EpicPlates.db.profile.auraFilters
                if auraFilters then
                    for spellID in pairs(auraFilters.spellIDs) do
                        local spellInfo = C_Spell.GetSpellInfo(spellID)
                        if spellInfo then
                            filters["id_" .. spellID] = "ID: " .. spellID .. " (" .. spellInfo.name .. ")"
                        end
                    end
                    for spellName in pairs(auraFilters.spellNames) do
                        filters["name_" .. spellName] = "Name: " .. spellName
                    end
                    for casterName in pairs(auraFilters.casterNames) do
                        filters["caster_" .. casterName] = "Caster: " .. casterName
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
            order = 19,
        },

        -- Always Show Spells Header
        alwaysShowHeader = {
            type = 'header',
            name = "Always Show Spells",
            order = 20,
        },
        addAlwaysShowByID = {
            type = 'input',
            name = "Always Show by Spell ID",
            desc = "|cFF00FF00Always Show by Spell ID|r\n\n" ..
                   "Enter the numerical ID of the spell you want to always display on nameplates.\n\n" ..
                   "Example: Enter '774' to always show the Rejuvenation buff on nameplates.",
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
            order = 21,
        },
        addAlwaysShowByName = {
            type = 'input',
            name = "Always Show by Spell Name",
            desc = "|cFF00FF00Always Show by Spell Name|r\n\n" ..
                   "Enter the name of the spell you want to always display on nameplates.\n\n" ..
                   "Example: Enter 'Rejuvenation' to always show the Rejuvenation buff on nameplates.",
            set = function(_, value)
                local spellInfo = C_Spell.GetSpellInfo(value)
                if spellInfo then
                    EpicPlates.db.profile.alwaysShow.spellNames[spellInfo.name] = true
                    EpicPlates:UpdateAllAuras()
                else
                    print("Error: Invalid Spell Name")
                end
            end,
            order = 22,
        },
        removeAlwaysShow = {
            type = 'select',
            name = "Remove Always Show Spell",
            desc = "Remove a spell from the always show list.\n\n" ..
                   "Select the spell you want to remove from the dropdown menu. This will stop the spell " ..
                   "from being always displayed on nameplates.",
            values = function()
                local filters = {}

                local alwaysShow = EpicPlates.db.profile.alwaysShow
                if alwaysShow then
                    -- Add default spells from Spells.lua
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

                    -- Add custom spells added by the player
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
            order = 23,
        },

        -- Aura Settings Header (Added for Aura Duration Threshold)
        auraSettingsHeader = {
            type = 'header',
            name = "Aura Settings",
            order = 24,
        },
        showAurasWithMoreThan = {
            type = 'range',
            name = "Show Auras with More Than X Seconds",
            desc = "This setting controls the display of auras based on their remaining duration. Only auras with more than the specified number of seconds remaining will be shown on the nameplates.\n\n" ..
                   "|cFF00FF00Usage Example:|r\n" ..
                   "If you set this slider to 10 seconds, only auras that have more than 10 seconds remaining will be visible on the nameplates. This can help you focus on long-lasting buffs or debuffs, filtering out shorter, less relevant effects.\n\n" ..
                   "|cFFFF0000Important:|r This value cannot exceed 60 seconds. If you try to enter a number greater than 60, the value will automatically be adjusted to 60 to ensure proper functionality of the addon.",
            min = 0,
            max = 60,
            step = 1,
            order = 25,
            get = function() 
                return EpicPlates.db.profile.auraThresholdMore 
            end,
            set = function(_, value) 
                if value > 60 then 
                    value = 60 
                    print("Warning: The maximum allowed value is 60 seconds. The value has been adjusted accordingly.")
                end  -- Safeguard to cap the value at 60
                EpicPlates.db.profile.auraThresholdMore = value
                EpicPlates:UpdateAllAuras()
            end,
        },
        showAurasWithLessThan = {
            type = 'range',
            name = "Show Auras with Less Than X Seconds",
            desc = "This setting controls the display of auras based on their remaining duration. Only auras with less than the specified number of seconds remaining will be shown on the nameplates.\n\n" ..
                   "|cFF00FF00Usage Example:|r\n" ..
                   "If you set this slider to 5 seconds, only auras that have less than 5 seconds remaining will be visible on the nameplates. This is particularly useful for tracking auras that are about to expire, allowing you to react quickly to them.\n\n" ..
                   "|cFFFF0000Important:|r This value cannot exceed 60 seconds. If you try to enter a number greater than 60, the value will automatically be adjusted to 60 to ensure proper functionality of the addon.",
            min = 0,
            max = 60,
            step = 1,
            order = 26,
            get = function() 
                return EpicPlates.db.profile.auraThresholdLess 
            end,
            set = function(_, value) 
                if value > 60 then 
                    value = 60 
                    print("Warning: The maximum allowed value is 60 seconds. The value has been adjusted accordingly.")
                end  -- Safeguard to cap the value at 60
                EpicPlates.db.profile.auraThresholdLess = value
                EpicPlates:UpdateAllAuras()
            end,
        },
    },
}

AceConfig:RegisterOptionsTable("EpicPlates", options)
AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")
