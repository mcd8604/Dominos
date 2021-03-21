local AddonName, Addon = ...
local ConfigRegistry = LibStub('AceConfigRegistry-3.0')
local ConfigDialog = LibStub('AceConfigDialog-3.0')
local ContextMenu = {}

function ContextMenu:Show(bar)
    local registryKey = ('%sContextMenu%s'):format(AddonName, bar.id)

    if not ConfigRegistry:GetOptionsTable(registryKey) then
        ConfigRegistry:RegisterOptionsTable(registryKey, function()
            local options = {
                name = bar:GetDisplayName(),
                type = "group",
                childGroups = "select",
                args = { }
            }

            bar:MaybeCallMethod("OnInitializingContextMenu", options)

            return options
        end)
    end

    ConfigDialog:SetDefaultSize(registryKey, 320, 480)
    ConfigDialog:Open(registryKey)
end

function ContextMenu:GetStandardDisplayOptions(bar)
    return {
        type = "group",
        name = "Display",
        order = 0,
        args = {
            show = {
                type = "toggle",
                name = "Show",
                set = function(_, enable)
                    bar:SetShown(enable)
                end,
                get = function()
                    return bar:GetShown()
                end,
                width = "full",
                order = 0
            },

            scale = {
                type = "range",
                name = "Scale",
                get = function()
                    return bar:GetFrameScale()
                end,
                set = function(_, value)
                    return bar:SetFrameScale(value)
                end,
                min = 0,
                softMax = 2,
                step = 0.01,
                bigStep = 0.05,
                isPercent = true,
                width = "full",
                order = 100
            },

            opacity = {
                type = "range",
                name = "Opacity",
                get = function()
                    return bar:GetFrameAlpha()
                end,
                set = function(_, value)
                    return bar:SetFrameAlpha(value)
                end,
                min = 0,
                max = 1,
                step = 0.01,
                bigStep = 0.05,
                isPercent = true,
                width = "full",
                order = 110
            },

            faded_opacity = {
                type = "range",
                name = "Faded Opacity Modifier",
                desc = "Decrease to make a bar more transparent when not moused over",
                get = function()
                    return bar:GetFadeMultiplier()
                end,
                set = function(_, value)
                    return bar:SetFadeMultiplier(value)
                end,
                min = 0,
                max = 1,
                step = 0.01,
                bigStep = 0.05,
                isPercent = true,
                width = "full",
                order = 120
            }
        },
        plugins = {}
    };
end

function ContextMenu:GetStandardButtonLayoutOptions(bar)
    return {
        type = "group",
        name = "Button Layout",
        args = {
            columns = {
                type = "range",
                name = "Columns",
                min = 1,
                max = bar:NumButtons(),
                step = 1,
                get = function()
                    return bar:NumColumns()
                end,
                set = function(_, value)
                    bar:SetColumns(value)
                end,
                order = 110,
                width = "full",
                disabled = bar:NumButtons() <= 1
            },

            spacing = {
                type = "range",
                name = "Button Spacing",
                softMin = 0,
                softMax = 32,
                step = 1,
                get = function()
                    return bar:GetSpacing()
                end,
                set = function(_, value)
                    bar:SetSpacing(value)
                end,
                order = 200,
                width = "full"
            },

            padding = {
                type = "range",
                name = "Bar Padding",
                softMin = 0,
                softMax = 32,
                step = 1,
                get = function()
                    return bar:GetPadding()
                end,
                set = function(_, value)
                    bar:SetPadding(value)
                end,
                order = 210,
                width = "full"
            }
        },
        plugins = {}
    }
end

function ContextMenu:GetStandardVisibilityOptions(bar)
    local options = {
        type = "group",
        name = "Show States",
        order = 5000,
        args = {
            combat = {
                type = "toggle",
                name = "Show In Combat",
                set = function(_, enable)
                    if enable then
                        bar:SetUserDisplayConditions("[combat]show;hide")
                    else
                        bar:SetUserDisplayConditions("")
                    end
                end,
                get = function()
                    return (bar:GetUserDisplayConditions() or ""):match("%[combat%]show")
                end,
                width = "full",
                order = 100
            },

            group = {
                type = "toggle",
                name = "Show In Group",
                set = function(_, enable)
                    if enable then
                        bar:SetUserDisplayConditions("[group]show;hide")
                    else
                        bar:SetUserDisplayConditions("")
                    end
                end,
                get = function()
                    return (bar:GetUserDisplayConditions() or ""):match("%[group%]show")
                end,
                width = "full",
                order = 100
            },

            override_ui = {
                type = "toggle",
                name = "Show with Override UI",
                set = function(_, enable)
                    bar:ShowInOverrideUI(enable)
                end,
                get = function()
                    return bar:ShowingInOverrideUI()
                end,
                width = "full",
                order = 100
            },

            pet_battles = {
                type = "toggle",
                name = "Show with Pet Battle UI",
                set = function(_, enable)
                    bar:ShowInPetBattleUI(enable)
                end,
                get = function()
                    return bar:ShowingInPetBattleUI()
                end,
                width = "full",
                order = 100
            },

            states = {
                type = "input",
                name = "Custom Display Conditions",
                desc = "Enter a macro conditional along with show, hide, or an explicit opacity level (0-100).\nExample: [combat]100;hide will show a bar at 100% opacity in combat, and hide it otherwise.",
                multiline = true,
                get = function() return bar:GetUserDisplayConditions() or "" end,
                set = function(_, value) return bar:SetUserDisplayConditions(value or "") end,
                width = "full",
                order = 200,
            },
        }
    }

    return options
end

function ContextMenu:GetStandardAdvancedOptions(bar)
    local options = {
        type = "group",
        name = "Advanced",
        order = 10000,
        args = {
            click_through = {
                type = "toggle",
                name = "Click Through",
                set = function(_, enable)
                    bar:SetClickThrough(enable)
                end,
                get = function()
                    return bar:GetClickThrough()
                end,
                width = "full",
                order = 200
            },

            orientation = {
                type = "select",
                name = "Layout Orientation",
                get = function()
                    if bar:GetLeftToRight() then
                        if bar:GetTopToBottom() then
                            return "lrtb"
                        end
                        return "lrbt"
                    end

                    if bar:GetTopToBottom() then
                        return "rltb"
                    end

                    return "rlbt"
                end,

                set = function(_, value)
                    if value == "lrtb" then
                        bar:SetLeftToRight(true)
                        bar:SetTopToBottom(true)
                    elseif value =="lrbt" then
                        bar:SetLeftToRight(true)
                        bar:SetTopToBottom(false)
                    elseif value == "rltb" then
                        bar:SetLeftToRight(false)
                        bar:SetTopToBottom(true)
                    elseif value == "rlbt" then
                        bar:SetLeftToRight(false)
                        bar:SetTopToBottom(false)
                    end
                end,
                values = {
                    lrtb = "Left to right, top to bottom",
                    lrbt = "Left to right, bottom to top",
                    rltb = "Right to left, top to bottom",
                    rlbt = "Right to left, bottom to top"
                },
                sorting = {"lrtb", "lrbt", "rltb", "rlbt"},
                width = "full",
                order = 210
            },

            strata = {
                type = "select",
                name = "Frame Strata",
                get = function()
                    return bar:GetDisplayLayer()
                end,
                set = function(_, value)
                    return bar:SetDisplayLayer(value)
                end,
                values = {
                    BACKGROUND = BACKGROUND,
                    LOW = LOW,
                    MEDIUM = "Medium",
                    HIGH = HIGH
                },
                sorting = {"BACKGROUND", "LOW", "MEDIUM", "HIGH"},
                width = "full",
                order = 220
            },

            lavel = {
                type = "range",
                name = "Frame Level",
                get = function()
                    return bar:GetDisplayLevel()
                end,
                set = function(_, value)
                    return bar:SetDisplayLevel(value)
                end,
                min = 0,
                softMax = 200,
                max = 999,
                step = 1,
                width = "full",
                order = 230
            },

            fade_in = {
                type = "group",
                name = "Fade In Timings",
                order = 240,
                inline = true,
                args = {
                    duration = {
                        type = "range",
                        name = "Duration (MS)",
                        get = function()
                            return bar:GetFadeInDuration() * 1000
                        end,
                        set = function(_, value)
                            return bar:SetFadeInDuration(value / 1000)
                        end,
                        min = 0,
                        softMax = 2000,
                        step = 1,
                        bigStep = 50,
                        width = "full"
                    },

                    delay = {
                        type = "range",
                        name = "Delay (MS)",
                        get = function()
                            return bar:GetFadeInDelay() * 1000
                        end,
                        set = function(_, value)
                            return bar:SetFadeInDelay(value / 1000)
                        end,
                        min = 0,
                        softMax = 1000,
                        step = 1,
                        bigStep = 50,
                        width = "full"
                    }
                }
            },

            fade_out = {
                type = "group",
                name = "Fade Out Timings",
                order = 250,
                inline = true,
                args = {
                    duration = {
                        type = "range",
                        name = "Duration (MS)",
                        get = function()
                            return bar:GetFadeOutDuration() * 1000
                        end,
                        set = function(_, value)
                            return bar:SetFadeOutDuration(value / 1000)
                        end,
                        min = 0,
                        softMax = 2000,
                        step = 1,
                        bigStep = 50,
                        width = "full"
                    },

                    delay = {
                        type = "range",
                        name = "Delay (MS)",
                        get = function()
                            return bar:GetFadeOutDelay() * 1000
                        end,
                        set = function(_, value)
                            return bar:SetFadeOutDelay(value / 1000)
                        end,
                        min = 0,
                        softMax = 1000,
                        step = 1,
                        bigStep = 50,
                        width = "full"
                    }
                }
            },
        }
    }

    return options
end

Addon.ContextMenu = ContextMenu
