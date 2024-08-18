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
            desc = "Adjust the size of buff/debuff icons.",
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
            desc = "Adjust the font size of the timer text on icons.",
            min = 6,
            max = 16,
            step = 1,
            order = 5,
            get = function() 
                return EpicPlates.db.profile.timerFontSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.timerFontSize = value
                EpicPlates:UpdateIconSize()
            end,
        },
        timerFont = {
            type = 'select',
            name = "Timer Font",
            desc = "Select the font for the timer text on icons.",
            values = LSM:HashTable("font"),
            dialogControl = 'LSM30_Font',
            order = 6,
            get = function() 
                return EpicPlates.db.profile.timerFont
            end,
            set = function(_, value) 
                EpicPlates.db.profile.timerFont = value
                EpicPlates:UpdateIconSize()
            end,
        },
        timerFontColor = {
            type = 'color',
            name = "Timer Font Color",
            desc = "Change the color of the timer text on icons.",
            hasAlpha = false,
            order = 7,
            get = function()
                return unpack(EpicPlates.db.profile.timerFontColor or {1, 1, 1})
            end,
            set = function(_, r, g, b)
                EpicPlates.db.profile.timerFontColor = {r, g, b}
                EpicPlates:UpdateIconSize()
            end,
        },
        spacer2 = {
            type = 'description',
            name = "",
            order = 8,
        },
        
        -- Minimap Icon Settings Header
        minimapIconHeader = {
            type = 'header',
            name = "Minimap Icon",
            order = 9,
        },
        showMinimapIcon = {
            type = "toggle",
            name = "Show Minimap Icon",
            desc = "Toggle the display of the minimap icon.",
            order = 10,
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
            order = 11,
        },
        
        -- Aura Filters Header
        auraFiltersHeader = {
            type = 'header',
            name = "Aura Filters",
            order = 12,
        },
        addFilterByID = {
            type = 'input',
            name = "Add Filter by Spell ID",
            desc = "|cFF00FF00Add Filter by Spell ID|r\n\n" ..
                   "Enter the numerical ID of the spell you wish to filter.",
            set = function(_, value)
                local spellID = tonumber(value)
                if spellID then
                    EpicPlates.db.profile.auraFilters.spellIDs[spellID] = true
                    EpicPlates:UpdateAllAuras()
                end
            end,
            order = 13,
        },
        addFilterByName = {
            type = 'input',
            name = "Add Filter by Spell Name",
            desc = "|cFF00FF00Add Filter by Spell Name|r\n\n" ..
                   "Enter the name of the spell you wish to filter.",
            set = function(_, value)
                EpicPlates.db.profile.auraFilters.spellNames[value] = true
                EpicPlates:UpdateAllAuras()
            end,
            order = 14,
        },
        addFilterByCaster = {
            type = 'input',
            name = "Add Filter by Caster Name",
            desc = "|cFF00FF00Add Filter by Caster Name|r\n\n" ..
                   "Enter the name of the caster whose spells you want to filter.",
            set = function(_, value)
                EpicPlates.db.profile.auraFilters.casterNames[value] = true
                EpicPlates:UpdateAllAuras()
            end,
            order = 15,
        },
removeFilter = {
    type = 'select',
    name = "Remove Filter",
    desc = "Remove an existing filter by selecting it from the list.",
    values = function()
        local filters = {}
        
        local auraFilters = EpicPlates.db.profile.auraFilters
        if auraFilters then
            for spellID in pairs(auraFilters.spellIDs) do
                filters["id_" .. spellID] = "ID: " .. spellID
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
    order = 16,
        },
    },
}

AceConfig:RegisterOptionsTable("EpicPlates", options)
AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")
