local _, Addon = ...
local ParentAddon = Addon:GetParent()
local L = Addon:GetLocale()

--[[
    display:
        enable; true | false

        scale: 1 - 200,

        opacity:
            default: 0 - 100,
            active: 0 - 100,

            fade in:
                delay: 0 - 500ms,
                duration: 0 - 500ms,

            fade out:
                delay: 0 - 500ms,
                duration: 0 - 500ms,

        layer:
            background,
            low,
            med,
            high

        level: 0-200

    layout:
        length: 1, max_bar_length(),

        columns: 1, length(),

        spacing:
            horizontal: -32, 32,
            vertical: -32, 32,

        padding:
            horizontal: -32, 32,
            vertical: -32, 32,

        orientation: {
            left to right, top to bottom,
            right to left, top to bottom,
            left to right, bottom to top,
            right to left, bottom to top,
        },

    paging:
        [group]:
            [state]: 1 - num_bars(),

    advanced:
        pet_battles: true | false,

        override_ui: true | false,

        combat: true | false,
            opacity: default, 0 | 100,

        custom: true | false,
            states: "",
--]]

local function getDisplayOptions(bar)
    return Addon.ContextMenu:GetStandardDisplayOptions(bar)
end

local function getLayoutOptions(bar)
    local options = Addon.ContextMenu:GetStandardButtonLayoutOptions(bar)

    options.args.size = {
        type = "range",
        name = "Size",
        min = 1,
        max = bar:MaxLength(),
        step = 1,
        get = function()
            return bar:NumButtons()
        end,
        set = function(_, value)
            bar:SetNumButtons(value)
        end,
        order = 0,
        width = "full"
    }

    return options
end

local getPagingValues
do
    local numBars = nil
    local values = {[-1] = DISABLE}

    getPagingValues = function()
        if ParentAddon:NumBars() ~= numBars then
            numBars = ParentAddon:NumBars()

            for i = 1, numBars do
                values[i] = ParentAddon.Frame:Get(i):GetDisplayName()
            end

            for i = numBars + 1, #values do
                values[i] = nil
            end
        end

        return values
    end
end

local function getGroupPagingOptions(bar, groupId, groupName)
    local states = ParentAddon.BarStates:map(
                       function(s)
            return s.type == groupId
        end)

    if #states == 0 then
        return
    end

    local options = {type = "group", name = groupName or groupId, args = {}}

    for i, state in ipairs(states) do
        local name = state.text
        if type(name) == 'function' then
            name = name()
        elseif not name then
            name = L['State_' .. state.id:upper()]
        end

        options.args[state.id] = {
            order = i,
            name = name,
            type = "select",
            width = "full",

            values = getPagingValues,

            get = function()
                local offset = bar:GetOffset(state.id) or -1

                if offset > -1 then
                    return (bar.id + offset - 1) % ParentAddon:NumBars() + 1
                end

                return offset
            end,

            set = function(_, value)
                local offset

                if value == -1 then
                    offset = nil
                elseif value < bar.id then
                    offset = (ParentAddon:NumBars() - bar.id) + value
                else
                    offset = value - bar.id
                end

                bar:SetOffset(state.id, offset)
            end
        }
    end

    return options
end

local function getPagingOptions(bar)
    local options = {type = "group", name = "Paging", args = {}}

    local state_groups = {
        {"class", UnitClass('player')}, {"modifier", "Modifiers"},
        {"target", "Targeting"}, {"page", "Quick Paging"}
    }

    for i, group in ipairs(state_groups) do
        local settings = getGroupPagingOptions(bar, unpack(group))

        if settings then
            options.args[group[1]] = settings
            options.args[group[1]].inline = true
            options.args[group[1]].order = i
        end
    end

    return options
end

function ParentAddon.ActionBar:OnInitializingContextMenu(options)
    options.args.display = getDisplayOptions(self)

    options.args.layout = getLayoutOptions(self)

    options.args.paging = getPagingOptions(self)

    options.args.visibility = Addon.ContextMenu:GetStandardVisibilityOptions(self)

    options.args.advanced = Addon.ContextMenu:GetStandardAdvancedOptions(self)

    options.args.advanced.args.flyout_direction = {
        type = "select",
        name = "Flyout Direction",
        get = function()
            return self:GetFlyoutDirection()
        end,
        set = function(_, value)
            return self:SetFlyoutDirection(value)
        end,
        values = {
            auto = "Automatic",
            UP = "Up",
            DOWN = "Down",
            LEFT = "Left",
            RIGHT = "Right"
        },
        sorting = {"auto", "UP", "DOWN", "LEFT", "RIGHT"},
        width = "full",
        order = 1000
    }
end