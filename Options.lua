local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local options = {
    name = "EpicPlates",
    type = 'group',
    args = {
        iconSize = {
            type = 'range',
            name = "Icon Size",
            desc = "Adjust the size of buff/debuff icons.",
            min = 15,
            max = 25,
            step = 1,
            get = function() 
                return EpicPlates.db.profile.iconSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.iconSize = value
                EpicPlates:UpdateIconSize()
            end,
        },
        timerFontSize = {
            type = 'range',
            name = "Timer Font Size",
            desc = "Adjust the font size of the timer text on icons.",
            min = 6,
            max = 16,
            step = 1,
            get = function() 
                return EpicPlates.db.profile.timerFontSize 
            end,
            set = function(_, value) 
                EpicPlates.db.profile.timerFontSize = value
                EpicPlates:UpdateIconSize()
            end,
        },
    },
}

AceConfig:RegisterOptionsTable("EpicPlates", options)
AceConfigDialog:AddToBlizOptions("EpicPlates", "EpicPlates")


