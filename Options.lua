local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LDBIcon = LibStub("LibDBIcon-1.0")

local options = {
    name = "EpicPlates",
    type = 'group',
    args = {
        -- Icon Settings Header
        iconSettingsHeader = {
            type = 'header',
            name = "Icon Settings",
            order = 1,
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
            order = 2,
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
            order = 3,
        },
        
        -- Timer Settings Header
        timerSettingsHeader = {
            type = 'header',
            name = "Timer Settings",
            order = 4,
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
            order = 5,
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
            order = 6,
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
        useStaticColor = {
            type = 'toggle',
            name = "Use Fixed Color",
            desc = "Enable this option to use a single, fixed color for the timer text.\n\n" ..
                   "When enabled, you can customize the color of the timer text using the color picker below. " ..
                   "This setting is useful if you prefer consistent visual feedback without color changes.",
            order = 7,
            get = function() 
                return EpicPlates.db.profile.colorMode == "static"
            end,
            set = function(_, value) 
                if value then
                    EpicPlates.db.profile.colorMode = "static"
                else
                    EpicPlates.db.profile.colorMode = "dynamic"
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
            order = 8,
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
            order = 9,
        },
        
        -- Minimap Icon Settings Header
        minimapIconHeader = {
            type = 'header',
            name = "Minimap Icon",
            order = 10,
        },
        showMinimapIcon = {
            type = "toggle",
            name = "Show Minimap Icon",
            desc = "Toggle the display of the EpicPlates minimap icon.\n\n" ..
                   "The minimap icon provides quick access to the EpicPlates settings. " ..
                   "Disable this option if you prefer not to have the icon on your minimap.",
            order = 11,
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
            order = 12,
        },
        
        -- Aura Filters Header
        auraFiltersHeader = {
            type = 'header',
            name = "Aura Filters",
            order = 13,
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
            order = 14,
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
            order = 15,
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
            order = 16,
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
            order = 17,
        },

        -- Always Show Spells Header
        alwaysShowHeader = {
            type = 'header',
            name = "Always Show Spells",
            order = 18,
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
            order = 19,
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
            order = 20,
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
    order = 21,


        },
    },
}

AceConfig:RegisterOptionsTable("EpicPlates", options)
AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")
