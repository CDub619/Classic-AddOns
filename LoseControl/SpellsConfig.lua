local _, L = ...;

L.SpellsConfig = {}; -- adds SpellsConfig table to addon namespace

local SpellsConfig = L.SpellsConfig;
local UISpellsConfig;
local tooltip = CreateFrame("GameTooltip", "fPBMouseoverTooltip", UIParent, "GameTooltipTemplate")
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitHealth = UnitHealth
local UnitName = UnitName
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetName = GetName
local GetNumGroupMembers = GetNumGroupMembers
local GetNumArenaOpponents = GetNumArenaOpponents
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local SetPortraitToTexture = SetPortraitToTexture
local ipairs = ipairs
local pairs = pairs
local next = next
local type = type
local select = select
local strsplit = strsplit
local strfind = string.find
local strmatch = string.match
local tblinsert = table.insert
local tblremove= table.remove
local mathfloor = math.floor
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local substring = string.sub
local tonumber = tonumber
local unpack = unpack
local SetScript = SetScript
local SetUnitDebuff = SetUnitDebuff
local SetOwner = SetOwner
local OnEvent = OnEvent
local CreateFrame = CreateFrame
local SetTexture = SetTexture
local SetNormalTexture = SetNormalTexture
local SetSwipeTexture = SetSwipeTexture
local SetCooldown = SetCooldown
local SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor, SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor = SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor,  SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor
local SetText = SetText
local SetChecked = SetChecked
local Disable = Disable
local AddLine = AddLine
local AddDoubleLine = AddDoubleLine
local GetVerticalScrollRange = GetVerticalScrollRange
local SetOwner = SetOwner
local getglobal = getglobal
local GetVerticalScroll = GetVerticalScroll
local GetChecked = GetChecked
local SetSpellByID = SetSpellByID
local CreateFontString = CreateFontString
local GetStringWidth = GetStringWidth
local _G = _G
local ClearAllPoints = ClearAllPoints
local GetParent = GetParent
local GetFrameLevel = GetFrameLevel
local GetDrawSwipe = GetDrawSwipe
local GetDrawLayer = GetDrawLayer
local GetAlpha = GetAlpha
local Hide = Hide
local Show = Show
local IsShown = IsShown
local IsVisible = IsVisible
local playerGUID
local print = print
local contents = {};
--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0,
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}


local tabs = {
	"CC",
	"Silence",
	"RootPhyiscal_Special",
	"RootMagic_Special",
	"Root",
	"ImmunePlayer",
	"Disarm_Warning",
	"CC_Warning",
	--"Enemy_Smoke_Bomb",
	"Stealth",
	"Immune",
	"ImmuneSpell",
	"ImmunePhysical",
	"AuraMastery_Cast_Auras",
	"ROP_Vortex",
	"Disarm",
	"Haste_Reduction",
	"Dmg_Hit_Reduction",
	"Interrupt",
	"AOE_DMG_Modifiers",
	"Friendly_Smoke_Bomb",
	"AOE_Spell_Refections",
	"Trees",
	"Speed_Freedoms",
	"Freedoms",
	"Friendly_Defensives",
	"CC_Reduction",
	"Personal_Offensives",
	"Peronsal_Defensives",
	"Mana_Regen",
	"Movable_Cast_Auras",

	"Other", --PVE only
	"PvE", --PVE only

	"SnareSpecial",
	"SnarePhysical70",
	"SnareMagic70",
	"SnarePhysical50",
	"SnarePosion50",
	"SnareMagic50",
	"SnarePhysical30",
	"SnareMagic30",
	"Snare",
}

local tabsIndex = {}
for i = 1, #tabs do
	tabsIndex[tabs[i]] = i
end

local tabsDrop = {}
for i = 1, #tabs + 1 do
	if not tabs[i] then
		tabsDrop[i] = "Delete"
	else
		tabsDrop[i] = tabs[i]
	end
end

local function GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);

	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end

	self:SetVerticalScroll(newValue);
end

local function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Enable();
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Hide();
	getglobal(name.."Middle"):Hide();
	getglobal(name.."Right"):Hide();
	--tab:LockHighlight();
	tab:Disable();
	getglobal(name.."LeftDisabled"):Show();
	getglobal(name.."MiddleDisabled"):Show();
	getglobal(name.."RightDisabled"):Show();

	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

local function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = getglobal(frame:GetName().."Tab"..i);
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

local function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = UISpellsConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local function makeAndShowSpellTTPVE(self)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	if type(self.spellID) == "number" then
	GameTooltip:SetSpellByID(self.spellID)
	else
		GameTooltip:SetText(self.spellID, 1, 1, 1, true)
		GameTooltip:AddLine("This Spell Uses the Name not SpellID.", 1.0, 0.82, 0.0, true);
	end
	if (self:GetChecked()) then
		GameTooltip:AddDoubleLine("|cff66FF00Enabled")
	else
		GameTooltip:AddDoubleLine("|cffFF0000Disabled")
	end
	GameTooltip:Show()
end

local function DeleteSpellFrame(spellID, duration, c)
	if spellID and duration then
		if _G[c:GetName().."spellCheck"..spellID..duration] then
			_G[c:GetName().."spellCheck"..spellID..duration] = nil
		end
	elseif _G[c:GetName().."spellCheck"..spellID] then
			_G[c:GetName().."spellCheck"..spellID] = nil
	end
end

local function GetSpellFrame(spellID, duration, c)
	if spellID and duration then
		if _G[c:GetName().."spellCheck"..spellID..duration] then
			return _G[c:GetName().."spellCheck"..spellID..duration]
		end
	elseif _G[c:GetName().."spellCheck"..spellID] then
		return _G[c:GetName().."spellCheck"..spellID]
	else
		return false
	end
end

local function CustomAddedCompileSpells(spell, prio)
	for k, v in ipairs(_G.LoseControlDB.customSpellIds) do
		if spell == v[1] then
			tblremove(_G.LoseControlDB.customSpellIds, k)
			break
		end
	end
	for i = 1, #L.spells do
		for l = 1, #L.spells[i] do
			for k, v in ipairs(L.spells[i][l]) do
				local spellID, oldPrio, _, _, duration, customname = unpack(v)
				if spell == spellID and (not duration) then
					local priotext = L[oldPrio] or oldPrio
					if i == 1 then L.SpellsConfig:WipeSpellList(l); print("|cff00ccffLoseControl|r : ".."|cff009900Removed |r"..spellID.." |cff009900from : |r"..priotext.." (PVP)") end
					if i ~= 1 then L.SpellsPVEConfig:WipeSpellList(i-1); print("|cff00ccffLoseControl|r : ".."|cff009900Removed |r"..spellID.." |cff009900from : |r"..L.spellsTable[i][1].." (PVE)") end
					tblremove(L.spells[i][l], k)
					if i == 1 then L.SpellsConfig:UpdateSpellList(l) end
					if i ~= 1 then L.SpellsPVEConfig:UpdateSpellList(i-1) end
					break
				end
			end
		end
	end
	L.spellIds[spell] = prio
	_G.LoseControlDB.spellEnabled[spell]= true
	L.SpellsConfig:WipeSpellList(tabsIndex[prio])
	tblinsert(_G.LoseControlDB.customSpellIds, {spell, prio, nil, nil, nil, "Custom Spell", 1})
	tblinsert(L.spells[1][tabsIndex[prio]], 1, {spell, prio, nil, nil, nil, "Custom Spell", 1})
	L.SpellsConfig:UpdateSpellList(tabsIndex[prio])
	local priotext = L[prio] or prio
	print("|cff00ccffLoseControl|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..priotext.." (PVP)")
end

local function CustomPVPDropDownCompileSpells(spell , newPrio, oldPrio, c, duration)
	for k, v in ipairs(_G.LoseControlDB.customSpellIds) do
		if spell == v[1] then
			tblremove(_G.LoseControlDB.customSpellIds, k)
			break
		end
	end
	for k, v in ipairs(L.spells[1][tabsIndex[oldPrio]]) do
		local spellID, _, _, _, duration, customname = unpack(v)
		if spell == spellID and (not duration) then
			SpellsConfig:WipeSpellList(tabsIndex[oldPrio])
			tblremove(L.spells[1][tabsIndex[oldPrio]], k)
			local priotext = L[oldPrio] or oldPrio
			print("|cff00ccffLoseControl|r : ".."|cff009900Removed |r"..spellID.." |cff009900from list: |r"..priotext.." (PVP)")
			if newPrio == "Delete" then
			 	L.spellIds[spell] = nil
				_G.LoseControlDB.spellEnabled[spell]= nil
				if L.spellsLua[spell] then
				tblinsert(_G.LoseControlDB.customSpellIds, {spell, newPrio, nil, nil, nil, customname, 1})  --v[7]: Category Tab to enter spell
				end
				DeleteSpellFrame(spell, duration, c)
				SpellsConfig:UpdateSpellList(tabsIndex[oldPrio])
			else
				L.spellIds[spell] = newPrio
				tblinsert(_G.LoseControlDB.customSpellIds, {spell, newPrio, nil, nil, nil, "Custom Priority", 1})
				tblinsert(L.spells[1][tabsIndex[newPrio]], 1, {spell, newPrio, nil, nil, nil, "Custom Priority", 1})
				local priotext = L[newPrio] or newPrio
				print("|cff00ccffLoseControl|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..priotext.." (PVP)")
				SpellsConfig:UpdateSpellList(tabsIndex[oldPrio]);SpellsConfig:UpdateTab(tabsIndex[newPrio]);
			end
			break
		end
	end
end

local function createDropdown(opts)
	    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
	    local menu_items = opts['items'] or {}
	    local title_text = opts['title'] or ''
	    local dropdown_width = 0
	    local default_val = opts['defaultVal'] or ''
	    local change_func = opts['changeFunc'] or function (dropdown_val) end

	    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
	    dd_title:SetPoint("TOPLEFT", 20, 10)

	    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
	        dd_title:SetText(item)
	        local text_width = dd_title:GetStringWidth() + 20
	        if text_width > dropdown_width then
	            dropdown_width = text_width
	        end
	    end

	    UIDropDownMenu_SetWidth(dropdown, 1)
	    UIDropDownMenu_SetText(dropdown, 1)
	    dd_title:SetText(title_text)

	    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
	        local info = UIDropDownMenu_CreateInfo()
	        for key, val in pairs(menu_items) do
						if L[val] then val = L[val] end
	            info.text = val;
	            info.checked = false
							if val == default_val then
								info.checked = true
							end
	            info.menuList= key
	            info.hasArrow = false
	            info.func = function(b)
	                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
	                UIDropDownMenu_SetText(dropdown, b.value)
	                b.checked = true
	                change_func(dropdown, b.value)
	            end
	            UIDropDownMenu_AddButton(info)
	        end
	    end)

	    return dropdown
		end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local frameName = frame:GetName();
	local width = {}
	local rows = 1
	local rowCount = 1

	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetFrameLevel(2)

		if L[select(i, ...)] then
			tab:SetText(L[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);
		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
		tab.content.spellstext  =	tab.content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	--tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

		if tabs[i] == "Interrupt" then
			else
			tab.content.input = CreateFrame("EditBox", tab:GetName()..'CustomSpells', 	tab.content, 'InputBoxTemplate')
	  	tab.content.input:SetSize(150,22)
	  	tab.content.input:SetAutoFocus(false)
	    tab.content.input:SetMaxLetters(30)
	    tab.content.input:SetPoint("TOPLEFT", tab.content, "TOPRIGHT", 45, -14)
	    tab.content.input:SetScript('OnChar', function(self, customspelltext)
	    			  	tab.content.input.customspelltext = self:GetText()
	    end)
	    --
	  	tab.content.add = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content.input, "UIPanelButtonTemplate")
	  	tab.content.add:SetSize(50,22)
	    tab.content.add:SetPoint("TOPLEFT",	tab.content.input, "TOPRIGHT", 2, 0)
	    tab.content.add:SetText("Add")
	  	tab.content.add:SetScript("OnClick", function(self, addenemy)
				if tab.content.input.customspelltext then
				local spell = GetSpellInfo(tonumber(tab.content.input.customspelltext))
				if spell then spell = tonumber(tab.content.input.customspelltext) else spell = tab.content.input.customspelltext end
				CustomAddedCompileSpells(spell, tabs[i])
				else
					print("|cff00ccffLoseControl|r : Please Enter a spellId or Name")
				end
	    end)
		end

		tab.content.reset = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content, "UIPanelButtonTemplate")
		tab.content.reset:SetSize(70,22)
		tab.content.reset:SetScale(.7)
			if tabs[i] == "Interrupt" then
				tab.content.reset:SetPoint("CENTER", tab.content,  "CENTER", 860, 245 )
			else
				tab.content.reset:SetPoint("CENTER", tab.content,  "CENTER", 860, 197 )
			end
		tab.content.reset:SetText("Enable All")
		tab.content.reset:SetScript("OnClick", function(self, enable)
		SpellsConfig:EnableAll(i)
		end)


		tab.content.disable = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content, "UIPanelButtonTemplate")
		tab.content.disable:SetSize(70,22)
		tab.content.disable:SetScale(.7)
		tab.content.disable:SetPoint("CENTER",	tab.content.reset,  "CENTER", 0, -20)
		tab.content.disable:SetText("Disable All")
		tab.content.disable:SetScript("OnClick", function(self, disable)
		SpellsConfig:DisableAll(i)
		end)


		if (i == 1) then
		tab:SetPoint("TOPLEFT", UISpellsConfig, "BOTTOMLEFT", 5, 7);
		rowCount = 1
		else
				if rowCount <= 9 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					rowCount = rowCount + 1
	    	else
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpellsConfig, "BOTTOMLEFT", 5, y);
					rows = rows + 1
					rowCount = 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function CreateMenu()
	UISpellsConfig = CreateFrame("Frame", "LoseControlSpellsConfig", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, GetThemeColor());
	local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
	UISpellsConfig.Title:SetText('LoseControl PVP Spells Config '..BambiTag)
	UISpellsConfig:SetFrameStrata("DIALOG");
	UISpellsConfig:SetFrameLevel(2);
	UISpellsConfig:EnableMouse(true);
	UISpellsConfig:SetMovable(true)
	UISpellsConfig:RegisterForDrag("LeftButton")
	UISpellsConfig:SetScript("OnDragStart", UISpellsConfig.StartMoving)
	UISpellsConfig:SetScript("OnDragStop", UISpellsConfig.StopMovingOrSizing)

	UISpellsConfig:SetSize(1050, 400);
	UISpellsConfig:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


	UISpellsConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UISpellsConfig, "UIPanelScrollFrameTemplate");
	UISpellsConfig.ScrollFrame:SetPoint("TOPLEFT", LoseControlSpellsConfigDialogBG, "TOPLEFT", 4, -8);
	UISpellsConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", LoseControlSpellsConfigDialogBG, "BOTTOMRIGHT", -3, 4);
	UISpellsConfig.ScrollFrame:SetClipsChildren(true);
	UISpellsConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

	UISpellsConfig.ScrollFrame.ScrollBar:ClearAllPoints();
  UISpellsConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UISpellsConfig.ScrollFrame, "TOPRIGHT", -12, -18);
  UISpellsConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UISpellsConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);

	local allContents = SetTabs(UISpellsConfig, #tabs, unpack(tabs));

	UISpellsConfig:Hide();
	return UISpellsConfig;
end

--------------------------------------
-- SpellsConfig functions
--------------------------------------
function SpellsConfig:Addon_Load()
if not UISpellsConfig then CreateMenu(); SpellsConfig:UpdateAllSpellList() end
end

function SpellsConfig:Toggle() --Builds the Table
	if not UISpellsConfig then CreateMenu(); SpellsConfig:UpdateAllSpellList() end
	local menu = UISpellsConfig
	menu:SetShown(not menu:IsShown());
end

function SpellsConfig:UpdateTab(i)
	if not UISpellsConfig then return end
	SpellsConfig:WipeSpellList(i)
	SpellsConfig:UpdateSpellList(i);
end

function SpellsConfig:WipeAll()
if not UISpellsConfig then return end
	SpellsConfig:WipeAllSpellList()
end

function SpellsConfig:UpdateAll()
if not UISpellsConfig then return end
	SpellsConfig:UpdateAllSpellList()
end

function SpellsConfig:WipeAllSpellList()
	for i = 1, #tabs do
	SpellsConfig:WipeSpellList(i)
	end
end

function SpellsConfig:UpdateAllSpellList()
	for i = 1, #tabs do
	SpellsConfig:UpdateSpellList(i)
	end
end

function SpellsConfig:ResetAllSpellList()
	for i = 1, #tabs do
	SpellsConfig:EnableAll(i)
	end
end

function SpellsConfig:EnableAll(i)
	local c = contents[i]
	for l = 1, (#L.spells[1][i]) do
		local spellID, _, _, _, duration = unpack(L.spells[1][i][l])
		local spellCheck = GetSpellFrame(spellID, duration, c)
		spellCheck.icon = _G[spellCheck:GetName().."Icon"]
		spellCheck.icon.check = spellCheck
		spellID = spellCheck.spellID
		_G.LoseControlDB.spellEnabled[spellID] = true
		spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);
		end
	end

function SpellsConfig:DisableAll(i)
	local c = contents[i]
	for l = 1, (#L.spells[1][i]) do
	local spellID, _, _, _, duration = unpack(L.spells[1][i][l])
	local spellCheck = GetSpellFrame(spellID, duration, c)
		spellCheck.icon = _G[spellCheck:GetName().."Icon"]
		spellCheck.icon.check = spellCheck
		spellID = spellCheck.spellID
		_G.LoseControlDB.spellEnabled[spellID] = false
		spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);
	end
end

function SpellsConfig:WipeSpellList(i)
local c = contents[i]
 	for l = 1, (#L.spells[1][i]) do
		local spellID, _, _, _, duration = unpack(L.spells[1][i][l])
		local spellCheck = GetSpellFrame(spellID, duration, c)
		if not  spellCheck then return end
		spellCheck:Hide()
		end
	end

function SpellsConfig:UpdateSpellList(i)
local numberOfSpellChecksPerRow = 5
	if i == nil then return end
		local c = contents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = 1

		c.spellstext:SetText("|cff00ccffSpells|r : "..#L.spells[1][i])
		c.spellstext:SetPoint("TOPLEFT", c, "TOPLEFT", 5, 0);

		for l = 1, #L.spells[1][i] do
		local spellID, prio, _, _, duration, customname, _, cleuEvent = unpack(L.spells[1][i][l])
		 if (spellID) then
			local spellCheck = GetSpellFrame(spellID, duration, c)
			if spellCheck then
				if (previousSpellID) then
					if (spellCount % numberOfSpellChecksPerRow == 0) then
						Y = Y-40
						X = 30
					end
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
					X = X+200
				else
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
				end
				spellCheck:Show()
			else
				if not duration then
					spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
				else
					spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID..duration, c, "UICheckButtonTemplate");
				end
				if (previousSpellID) then
					if (spellCount % numberOfSpellChecksPerRow == 0) then
						Y = Y-40
						X = 30
					end
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
					X = X+200
				else
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
				end
				spellCheck:Show()

				spellCheck.icon = CreateFrame("Button", spellCheck:GetName().."Icon", spellCheck, "ActionButtonTemplate")
				spellCheck.icon:Disable()
				spellCheck.icon:SetPoint("CENTER", spellCheck, "CENTER", -90, 0)
				spellCheck.icon:SetScale(0.3)
				spellCheck.icon:Show()
				spellCheck.icon.check = spellCheck
				local aString = spellID
				if type(spellID) == "number" then
					if duration then
					aString = GetSpellInfo(spellID)..": "..duration or "SPELL REMOVED: "..spellID
					else
					aString = GetSpellInfo(spellID) or "SPELL REMOVED: "..spellID
					end
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
				else
				spellCheck.icon:SetNormalTexture(4006481)
				end
				local cutString = substring(aString, 0, 23);
				if customname then
					spellCheck.text:SetText(cutString.."\n".."("..customname..")");
				else
					spellCheck.text:SetText(cutString);
				end

				if cleuEvent then spellID = customname end
				spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);   --Error on 1st ADDON_LOADED
				spellCheck.spellID = spellID
				prio = L[prio] or prio
				local drop_opts = {
				    ['name']='raid',
				    ['parent']=spellCheck,
				    ['title']='',
				    ['items']= tabsDrop,
				    ['defaultVal']=prio,
				    ['changeFunc']=function(dropdown_frame, dropdown_val)
							local spell = GetSpellInfo(tonumber(spellID))
							if spell then spell = tonumber(spellID) else spell = spellID end
								for k, v in ipairs(tabs) do
									if dropdown_val == L[v] then
										dropdown_val = v
									end
								end
							 CustomPVPDropDownCompileSpells(spell, dropdown_val, tabs[i], c, duration)
							 spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false)
							end
				}

				if not duration then
				local dropdown = createDropdown(drop_opts)
				dropdown:SetPoint("LEFT", spellCheck.text, "RIGHT", -10,0)
				dropdown:SetScale(.55)
				end

				spellCheck:SetScript("OnClick",
					function()
					 GameTooltip:Hide()
					 _G.LoseControlDB.spellEnabled[spellCheck.spellID] = spellCheck:GetChecked()
					 makeAndShowSpellTTPVE(spellCheck)
					end
				);
				spellCheck:SetScript("OnEnter", function(self)
						makeAndShowSpellTTPVE(self)
				end)
				spellCheck:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
			end
			previousSpellID = spellID
			spellCount = spellCount + 1
		end
	end
end
