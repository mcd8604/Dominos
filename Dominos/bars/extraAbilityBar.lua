local ExtraAbilityContainer = _G.ExtraAbilityContainer
if not ExtraAbilityContainer then return end

local _, Addon = ...

--[[ bar ]]--

local ExtraAbilityBar = Addon:CreateClass('Frame', Addon.Frame)

function ExtraAbilityBar:New()
	local bar = ExtraAbilityBar.proto.New(self, 'extra')

	bar:Layout()

	return bar
end

function ExtraAbilityBar:GetDefaults()
	return {
		point = 'BOTTOM',
		x = 0,
		y = 160,
		showInPetBattleUI = true,
		showInOverrideUI = true
	}
end

function ExtraAbilityBar:Layout()
	ExtraAbilityContainer:ClearAllPoints()
	ExtraAbilityContainer:SetPoint('CENTER', self)
	ExtraAbilityContainer:SetParent(self)

	local w, h = ExtraAbilityContainer:GetSize()

	if w ==  0 and h == 0 then
		w = 256
		h = 120
	end

	local pW, pH = self:GetPadding()

	self:SetSize(w + pW, h + pH)
end

function ExtraAbilityBar:CreateMenu()
	local menu = Addon:NewMenu()

	self:AddLayoutPanel(menu)
	menu:AddFadingPanel()

	self.menu = menu
end

function ExtraAbilityBar:AddLayoutPanel(menu)
	local l = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")

	local panel = menu:NewPanel(l.Layout)

	panel:NewCheckButton {
		name = l.ExtraBarShowBlizzardTexture,
		get = function()
			return panel.owner:ShowingBlizzardTexture()
		end,
		set = function(_, enable)
			panel.owner:ShowBlizzardTexture(enable)
		end
	}

	panel.scaleSlider = panel:NewScaleSlider()
	panel.paddingSlider = panel:NewPaddingSlider()
end

function ExtraAbilityBar:ShowBlizzardTexture(show)
	self.sets.hideBlizzardTeture = not show

	self:UpdateShowBlizzardTexture()
end

function ExtraAbilityBar:ShowingBlizzardTexture()
	return not self.sets.hideBlizzardTeture
end

function ExtraAbilityBar:UpdateShowBlizzardTexture()
	if self:ShowingBlizzardTexture() then
        ExtraActionBarFrame.button.style:Show()
        ZoneAbilityFrame.Style:Show()
	else
        ExtraActionBarFrame.button.style:Hide()
        ZoneAbilityFrame.Style:Hide()
	end
end

--[[ module ]]--

local ExtraAbilityBarModule = Addon:NewModule('ExtraAbilityBar', "AceEvent-3.0")

function ExtraAbilityBarModule:Load()
	if not self.initialized then
		self.initialized = true

		ExtraAbilityContainer.ignoreFramePositionManager = true

		hooksecurefunc(ExtraAbilityContainer, "Layout", function ()
			self:OnExtraAbilityContainerLayout()
		end)
	end

	self.frame = ExtraAbilityBar:New()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function ExtraAbilityBarModule:Unload()
	self.frame:Free()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function ExtraAbilityBarModule:OnExtraAbilityContainerLayout()
	if InCombatLockdown() then
		self.dirty = true
	else
		self.frame:Layout()
	end
end

function ExtraAbilityBarModule:PLAYER_REGEN_ENABLED()
	if self.dirty then
		self.dirty = nil
		self.frame:Layout()
	end
end