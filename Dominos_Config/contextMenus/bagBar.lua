local _, Addon = ...
local ParentAddon = Addon:GetParent()
local L = Addon:GetLocale()

local function getLayoutOptions(bar)
    local options = Addon.ContextMenu:GetStandardButtonLayoutOptions(bar)

    options.args.bags = {
        type = "toggle",
        name = L.BagBarShowBags,
        get = function()
            return bar:ShowBags()
        end,
        set = function(_, value)
            bar:SetShowBags(value)
        end,
        order = 10,
        width = "full"
    }

    if Addon:IsBuild('Classic') then
        options.args.keyring = {
            type = "toggle",
            name = L.BagBarShowKeyRing,
            get = function()
                return bar:ShowKeyRing()
            end,
            set = function(_, value)
                bar:SetShowKeyRing(value)
            end,
            order = 20,
            width = "full"
        }
    end

    return options
end

function ParentAddon.BagBar:OnInitializingContextMenu(options)
    options.args.display = Addon.ContextMenu:GetStandardDisplayOptions(self)
    options.args.layout = getLayoutOptions(self)
    options.args.visibility = Addon.ContextMenu:GetStandardVisibilityOptions(self)
    options.args.advanced = Addon.ContextMenu:GetStandardAdvancedOptions(self)
end
