--On Git HUB
local overlays = {}
local buffs = {}
local WarBanner = {}
local tblinsert = table.insert
local tremove = table.remove
local table_sort = table.sort
local substring = string.sub
local strfind = string.find
local bit_band = bit.band
local Ctimer = C_Timer.After

local prioritySpellList = { --The higher on the list, the higher priority the buff has.

--**Class Stealth**-------------------------------------------------------------

"Stealth",
"Prowl",
1784,  --Stealth Rank 1
1785,  --Stealth Rank 2
1786,  --Stealth Rank 3
1787,  --Stealth Rank 4
5215,  --Prowl Rank 1
6783,  --Prowl Rank 2
9913,  --Prowl Rank 3
32612,		 --Invisibility (Mage)

--**DMG/Heal CDs Given**--------------------------------------------------------

53480, --Roar of Sacrifice
"First Aid",

--**Threat Misdirect Given**----------------------------------------------------

57934, --Tricks of the Trade
34477, --Misdirection

--**Class Perm Passive Buffs & DMG CDs**----------------------------------------
--DK

49016, --Unholy Frenzy (talent)
49028,  --Dancing Rune Weapon (talent)
49206, --Summon Garg
61777, --Summon Garg
49796,  --Deathchill (talent)
48265, --Unholy Presence
48266, --Blood Presence

--Druid
5229, --Enrage
"Bear Form",
"Travel Form",
50334, --Berserk
"Tiger's Fury",
"Cat Form",
"Starfall",
48505, 	--Starfall (talent) (rank 1)
53199, -- Starfall (talent) (rank 2)
53200, -- Starfall (talent) (rank 3)
53201, 	--Starfall (talent) (rank 4)
33831, --Fore of Nature
48466, --Hurricane Rank 5
27012, --Hurricane Rank 4
17402, --Hurricane Rank 3
17401, --Hurricane Rank 2
16914, --Hurricane Rank 1
17116, -- Nature's Swiftness"
33891, --"Tree of Life",
"Moonkin Form",

--Hunter
23989, --Readiness
3045,  --Rapid Fire
19574, --Bestial Wrath (talent) (not immuune to spells, only immune to some CC's)
53434, --Call of the Wild
--64494, --Furious Howl
"Aspect of the Monkey",
"Aspect of the Cheetah",
"Aspect of the Hawk",
--"Aspect of the Pack",
"Aspect of the Beast",
"Aspect of the Wild",
"Aspect of the Viper",
"Aspect of the Dragonhawk",

--Mage
12472, --Icy Veins
12042, --Arcane Power
11129, --Combustion
12043, --Presence of Mind
"Ice Barrier",
--31687, --Water Ele
58833, --Mirror Image
58831, --Mirror Image
58834, --Mirror Image
"Mana Shield",
"Fire Ward",
"Frost Ward",
"Frost Armor",
"Ice Armor",
"Molten Armor",
"Mage Armor",

--Pally
20216,  --Divine Favor
31842, --Divine Illumination
54428, --Divine Plea
"Seal of Justice",
"Seal of Righteousness",
"Seal of Wisdom",
"Seal of Light",
"Seal of Corruption",
"Seal of Command",
"Seal Of Vengeance",
"Seal of the Martyr",
"Seal of Blood",

--Priest
14751, --Inner Focus
34433, --Disc Pet Summmon Sfiend
"Shadowform",
"Inner Fire",

--Rogue
14185, --Prep
14177, --Coldblood
51690, --Killing Spree
13750, --Adrenaline Rush
13877, --Blade Flurry


--Shaman
2645,   --Ghost Wolf
51533, --Feral Spirits
16188,  --Nature’s Swiftness
16166,  --Elemental Mastery
"Lightning Shield",
"Water Shield",


--Warlock
"Shadow Ward",
"Soul Link",


--Warrior
1719,  --Recklessness
12292, --Death Wish
12328, --Sweeping Strike
2457,  --Battle Stance
71,    --Defensive Stance
2458,  --Berserker Stance

}

--casted auras needs to appear also in the order to show up
local castedAuraIds = {
	[33831] = 30, --Trees
	[34433] = 15, --Shadowfiend
	[58833] = 30, --Mirror Image
	[58831] = 30, --Mirror Image
	[58834] = 30, --Mirror Image
	--[31687]  = 45, --Water Ele
	[51533] = 45, --Feral Spirits
	[49206] = 30, --Summon Gargoyle


--Casted Spells
	[23989] = 3, --Readiness
	[14185] = 3, --Preparation
	[2457] = 0,  --Battle Stance
	[71] = 0,    --Defensive Stance
	[2458] = 0,  --Berserker Stance


}

local function CompactUnitFrame_UtilSetBuff(buffFrame, icon, duration, expirationTime, count)
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) and icon ~= 135926 then --hides inner fire frame
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(buffFrame.cooldown);
	end
	buffFrame:Show();
end


for k, v in ipairs(prioritySpellList) do
	buffs[v] = k
end

local CLEUAura = {}
local tt = CreateFrame('GameTooltip', 'ObjectExistsTooltip', nil, 'GameTooltipTemplate')

hooksecurefunc("CompactUnitFrame_UpdateAuras", function(self)
	if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
		return
	end

	local unit, index, buff = self.displayedUnit, index, buff
	local sourceGUID, realm = UnitName(unit)
	for i = 1, 32 do --BUFF_MAX_DISPLAY
		local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i,"HELPFUL")

		--[[if spellId == 356968 then
			tt:Hide()
		 	tt:SetUnitBuff(unit, i, "HELPFUL")
			local text1 = ObjectExistsTooltipTextLeft1:GetText()
		 	local text2 = ObjectExistsTooltipTextLeft2:GetText()
			print(text1)
			print(text2)
		end]]

		if spellId then
			if buffs[buffName] then
				buffs[spellId] = buffs[buffName]
			end

			if buffs[spellId] then
				if not buff or buffs[spellId] < buffs[buff] then
					buff = spellId
					index = i
				end
			end
		else
			break
		end
	end
	local sourceGUID = UnitGUID(unit)
	local overlay = overlays[self]
	if not overlay then
		if not index and not CLEUAura[sourceGUID] then
			return
		end
		overlay = CreateFrame("Button", "$parentBuffOverlayRight", self, "CompactAuraTemplate")
		overlay:ClearAllPoints()
		overlay:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -1.5)
		overlay:SetAlpha(1)
		overlay:SetFrameLevel(100)
		overlay:EnableMouse(false)
		overlay:RegisterForClicks()
		overlays[self] = overlay
	end

	local cleu = false

	if index or CLEUAura[sourceGUID] then
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura
			if CLEUAura[sourceGUID] then
					if (buffs[buff] == nil) or (buffs[buff] > buffs[CLEUAura[sourceGUID][1][4]]) then
						icon = CLEUAura[sourceGUID][1][1]
						duration = CLEUAura[sourceGUID][1][2]
						expirationTime = CLEUAura[sourceGUID][1][3]
						spellId = CLEUAura[sourceGUID][1][4]
						cleu = true
						count = 0
					else
					name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index)
				end
			else
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index)
			end

		overlay:SetSize(self.buffFrames[1]:GetSize())
		overlay:SetScale(1.15)
		CompactUnitFrame_UtilSetBuff(overlay, icon, duration, expirationTime, count)
	end

	if cleu then
		local durationTime = CLEUAura[sourceGUID][1][3] - GetTime();
		overlay:SetShown(true)
		if durationTime > 0 then
			Ctimer(durationTime, function()
				overlay:SetShown(false)
			end)
		end
	else
		overlay:SetShown(index and true or false)
	end
end)

local function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local tip = CreateFrame('GameTooltip', 'ObjectExistsTooltip', nil, 'GameTooltipTemplate')
local function ObjectExists(guid, ticker, name, sourceName) --Used for Infrnals and Ele
  tip:SetOwner(WorldFrame, 'ANCHOR_NONE')
  tip:SetHyperlink('unit:' .. guid or '')
	local text1 = ObjectExistsTooltipTextLeft1
	local text2 = ObjectExistsTooltipTextLeft2
	local text3 = ObjectExistsTooltipTextLeft3
	if strfind(tostring(sourceName), "-") then
		local sourceNameTable = Split(sourceName, "-")
		sourceName = sourceNameTable[1]
	end
	--print(sourceName)
	--print(text1:GetText().." text1")
	--print(text2:GetText().." text2")
	--print(text3:GetText().." text3")
	if (text1 and (type(text1:GetText()) == "string")) then
		if strmatch(text1:GetText(), "Corpse") then
			--print(text1:GetText().." text1")
			return "Corpse"
		end
	end
	if (text2 and (type(text2:GetText()) == "string")) then
		if strmatch(text2:GetText(), "Corpse") then
			--print(text2:GetText().." text 2")
			return "Corpse"
		end
	end
	if (text3 and (type(text3:GetText()) == "string")) then
		if strmatch(text3:GetText(), "Corpse") then
			--print(text3:GetText().." text3")
			return "Corpse"
		end
	end
	if (text1 and (type(text1:GetText()) == "string")) then
		if strfind(text1:GetText(), tostring(sourceName)) or strfind(text1:GetText(), "Mirror") or strfind(text1:GetText(), "Image") then
			--print(text1:GetText().." text1")
			return false
		end
	end
	if (text2 and (type(text2:GetText()) == "string")) then
		if strfind(text2:GetText(), tostring(sourceName)) or strfind(text2:GetText(), "Mirror") or strfind(text2:GetText(), "Image") then
			--print(text2:GetText().." text2")
			return false
		end
	end
	if (text3 and (type(text3:GetText()) == "string")) then
		if strfind(text3:GetText(), tostring(sourceName)) or strfind(text3:GetText(), "Mirror") or strfind(text3:GetText(), "Image") then
			--print(text3:GetText().." text3")
			return false
		end
	end
	return "Despawned"
end

local BORCLEU = CreateFrame("Frame")
BORCLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BORCLEU:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		BORCLEU:CLEU()
	end
end)

local function compare(a,b)
  return a[6] < b[6]
end


function BORCLEU:CLEU()
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") then --Summoned CDs
			--print(spellId.." "..GetSpellInfo(spellId).." "..sourceName)
			if castedAuraIds[spellId] and sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				local guid = destGUID
				local duration = castedAuraIds[spellId]
				local namePrint, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + duration

				if spellId == 58833 or spellId == 58831 or spellId == 58834 then
					icon = 135994
				end

				print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOR")
				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert(CLEUAura[sourceGUID], {icon, duration, expirationTime, spellId, destGUID, buffs[spellId], sourceName, namePrint})
				table_sort(CLEUAura[sourceGUID], compare)
				local ticker = 1
				Ctimer(duration, function()
					if CLEUAura[sourceGUID] then
						for k, v in pairs(CLEUAura[sourceGUID]) do
							if v[4] == spellId then
							  print(v[7].." ".."Timed Out".." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Timer")
								tremove(CLEUAura[sourceGUID], k)
								table_sort(CLEUAura[sourceGUID], compare)
								if #CLEUAura[sourceGUID] == 0 then
								CLEUAura[sourceGUID] = nil
								end
							end
						end
					end
				end)
				self.ticker = C_Timer.NewTicker(.25, function()
					if CLEUAura[sourceGUID] then
						for k, v in pairs(CLEUAura[sourceGUID]) do
							if v[5] then
							  if substring(v[5], -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug
	                if ObjectExists(v[5], ticker, v[8], v[7]) then
										print(v[7].." "..ObjectExists(v[5], ticker, v[8], v[7]).." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Ticker")
	            			tremove(CLEUAura[sourceGUID], k)
										table_sort(CLEUAura[sourceGUID], compare)
	           				if #CLEUAura[sourceGUID] == 0 then
										CLEUAura[sourceGUID] = nil
										end
										break
	                end
								end
							end
						end
					end
					ticker = ticker + 1
				end, duration * 4 + 5)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Casted  CDs w/o Aura
		-----------------------------------------------------------------------------------------------------------------
		if (event == "SPELL_CAST_SUCCESS") and ((spellId == 23989) or (spellId == 14185)) then --Prep & Readiness
			if castedAuraIds[spellId] and sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				local duration = castedAuraIds[spellId]
				local namePrint, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + duration
				print(sourceName.." Casted "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOR")
				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert(CLEUAura[sourceGUID], {icon, duration, expirationTime, spellId, destGUID, buffs[spellId], sourceName, namePrint})
				table_sort(CLEUAura[sourceGUID], compare)
				Ctimer(duration, function()
					if CLEUAura[sourceGUID] then
						for k, v in pairs(CLEUAura[sourceGUID]) do
							if v[4] == spellId then
							  print(v[7].." ".."Timed Out".." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Timer")
								tremove(CLEUAura[sourceGUID], k)
								table_sort(CLEUAura[sourceGUID], compare)
								if #CLEUAura[sourceGUID] == 0 then
								CLEUAura[sourceGUID] = nil
								end
							end
						end
					end
				end)
			end
		end
		-----------------------------------------------------------------------------------------------------------------
		--Warrior Stances
		-----------------------------------------------------------------------------------------------------------------
		if (event == "SPELL_CAST_SUCCESS") and ((spellId == 71) or (spellId == 2457) or (spellId == 2458)) then --Warrior Stances
			if castedAuraIds[spellId] and sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				local duration = castedAuraIds[spellId]
				local namePrint, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + 1
				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert(CLEUAura[sourceGUID], {icon, duration, expirationTime, spellId, destGUID, buffs[spellId], sourceName, namePrint})
				table_sort(CLEUAura[sourceGUID], compare)
				if CLEUAura[sourceGUID] then
					for k, v in pairs(CLEUAura[sourceGUID]) do
						if v[4] ~= spellId and (v[4] == 71 or v[4] == 2457 or v[4] ==2458) then
							print(sourceName.." Stance Changed to "..namePrint.." from "..v[8].." BOR")
							tremove(CLEUAura[sourceGUID], k)
							table_sort(CLEUAura[sourceGUID], compare)
							if #CLEUAura[sourceGUID] == 0 then
							CLEUAura[sourceGUID] = nil
							end
						end
					end
				end
			end
		end
	end
