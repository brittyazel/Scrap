--[[
Copyright 2008-2023 João Cardoso
All Rights Reserved
--]]

local Sushi = LibStub('Sushi-3.2')
local BasePanel = Sushi.OptionsGroup:NewClass()
local Options = Scrap:NewModule('Options', BasePanel('|Tinterface/addons/scrap/art/scrap-enabled:12:12:4:0|t  Scrap'))
local L = LibStub('AceLocale-3.0'):GetLocale('Scrap')

local PATRONS = {{title='Jenkins',people={'Gnare','Adcantu','Justin Hall','Debora S Ogormanw','Johnny Rabbit','Francesco Rollo'}},{title='Ambassador',people={'Julia F','Lolari ','Dodgen','Kopernikus ','Ptsdthegamer','Burt Humburg','Adam Mann','Christie Hopkins','Bc Spear','Jury ','Tigran Andrew','Jeffrey Jones','Swallow@area52','Peter Hollaubek','Michael Kinasz','Sam Ramji','Kelly Wolf','Syed Hamdani','Thinkdesigner ','Charles Howarth','Harry J Hightower'}}} -- generated patron list
local PATREON_ICON = '  |TInterface/Addons/Scrap/art/patreon:12:12|t'
local HELP_ICON = '  |T516770:13:13:0:0:64:64:14:50:14:50|t'
local FOOTER = 'Copyright 2012-2023 João Cardoso'


--[[ Startup ]]--

function Options:OnEnable()
	self.Filters = BasePanel(self, L.JunkList .. ' ' .. CreateAtlasMarkup('poi-workorders'))
		:SetSubtitle(L.ListDescription):SetFooter(FOOTER):SetChildren(self.OnFilters)
	self.Help = Sushi.OptionsGroup(self, HELP_LABEL .. HELP_ICON)
		:SetSubtitle(L.HelpDescription):SetFooter(FOOTER):SetChildren(self.OnHelp)
	self.Credits = Sushi.OptionsGroup(self, 'Patrons' .. PATREON_ICON)
		:SetSubtitle(L.PatronsDescription):SetFooter(FOOTER):SetOrientation('HORIZONTAL'):SetChildren(self.OnCredits)

	self:SetFooter(FOOTER)
	self:SetSubtitle(L.GeneralDescription)
	self:SetCall('OnChildren', self.OnMain)
end

function Options:OnMain()
	self:AddHeader(L.Behaviour)
	self:AddCheck {set = 'sell', text = 'AutoSell'}
	self:AddCheck {set = 'repair', text = 'AutoRepair'}
	self:AddCheck {set = 'guild', text = 'GuildRepair', parent = 'repair'}
	self:AddCheck {set = 'safe', text = 'SafeMode'}
	self:AddCheck {set = 'destroy', text = 'DestroyWorthless'}

	self:AddHeader(L.Visuals)
	self:AddCheck {set = 'icons', text = 'Icons'}
	self:AddCheck {set = 'glow', text = 'Glow'}

	if LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CLASSIC then
		self:AddCheck {set = 'prices', text = 'SellPrices'}
	end
end

function Options:OnFilters()
	self:Add('Check', L.CharSpecific):SetChecked(not Scrap_CharSets.share):SetCall('OnInput', function(share, v)
		Scrap_CharSets.share = not v
		self:SendSignal('SETS_CHANGED')
	end)
	self:AddCheck {set = 'learn', text = 'Learning'}

	self:AddHeader(CALENDAR_FILTERS)
	self:AddCheck {set = 'unusable', text = 'Unusable', char = true}
	self:AddCheck {set = 'equip', text = 'LowEquip', char = true}
	self:AddCheck {set = 'consumable', text = 'LowConsume', char = true}
end

function Options:OnHelp()
	for i = 1, #L.FAQ, 2 do
		self:Add('ExpandHeader', L.FAQ[i], GameFontHighlightSmall):SetExpanded(self[i]):SetCall('OnClick', function() self[i] = not self[i] end)

		if self[i] then
			local answer = self:Add('Header', L.FAQ[i+1], GameFontHighlightSmall)
			answer.left, answer.right, answer.bottom = 16, 16, 16
		end
	end

	self:Add('RedButton', 'Show Tutorial'):SetWidth(200):SetCall('OnClick', function() Scrap.Tutorials:Reset() end).top = 10
	self:Add('RedButton', 'Ask Community'):SetWidth(200):SetCall('OnClick', function()
		Sushi.Popup:External('bit.ly/discord-jaliborc')
		SettingsPanel:Close(true)
	end)
end

function Options:OnCredits()
	for i, rank in ipairs(PATRONS) do
		if rank.people then
			self:Add('Header', rank.title, GameFontHighlight, true).top = i > 1 and 20 or 0

			for j, name in ipairs(rank.people) do
				self:Add('Header', name, i > 1 and GameFontHighlight or GameFontHighlightLarge):SetWidth(180)
			end
		end
	end

	self:AddBreak()
	self:Add('RedButton', 'Join Us'):SetWidth(200):SetCall('OnClick', function()
		Sushi.Popup:External('patreon.com/jaliborc')
		SettingsPanel:Close(true)
	end).top = 20
end


--[[ API ]]--

function BasePanel:AddHeader(text)
	self:Add('Header', text, GameFontHighlight, true)
end

function BasePanel:AddCheck(info)
	local sets = info.char and Scrap_CharSets or Scrap_Sets
	local b = self:Add('Check', L[info.text])
	b.left = b.left + (info.parent and 10 or 0)
	b:SetEnabled(not info.parent or sets[info.parent])
	b:SetTip(L[info.text], L[info.text .. 'Tip'])
	b:SetChecked(sets[info.set])
	b:SetSmall(info.parent)
	b:SetCall('OnInput', function(b, v)
		sets[info.set] = v
		Options:SendSignal('LIST_CHANGED')
	end)
end

function BasePanel:SetDefaults()
	Scrap_Sets, Scrap_CharSets = nil
	self:SendSignal('SETS_CHANGED')
	self:Update()
end
