--On Git HUB
local overlays = {}
local buffs = {}
local tblinsert = table.insert
local tremove = table.remove
local substring = string.sub
local prioritySpellList = { --The higher on the list, the higher priority the buff has.

--**Drinking**------------------------------------------------------------------

"Food",
"Drink",
"Food & Drink",
"Refreshment",

--**Healer CDs or Externals Given**----------------------------------------------------------

10278, --Blessing Of Protection Rank 3
5599,  --Blessing Of Protection Rank 2
1022,  --Blessing Of Protection Rank 1

47788, --Guardian Spirit (talent) (prevent the target from dying)
33206, --Pain Suppression

6940, --Hand of Sacrifice
64205, --Divine Sacrifice
31821, --Aura Mastery

16689, --Nature's Grasp Rank 1
16810, --Nature's Grasp Rank 2
16811, --Nature's Grasp Rank 3
16812, --Nature's Grasp Rank 4
16813, --Nature's Grasp Rank 5
17329, --Nature's Grasp Rank 6
27009, --Nature's Grasp Rank 7
53312, --Nature's Grasp Rank 8


50461, --AMZ
64843, --Divine Hymn
64844, --Divine Hymn 10% Buff
"Tranquility",


--**Class Healing & DMG CDs Given**---------------------------------------------------------

552,   --Abolish Disease
2893,  --Abolish Poison

57933, --Tricks of the Trade (Dmg)

"Power Infusion",
2825,   --Bloodlust
32182,  --Heroism

29166, --Innervate
6346,  --Fear Ward

467,   --Thorns Rank 1
782,   --Thorns Rank 2
1075,  --Thorns Rank 3
8914,  --Thorns Rank 4
9756,  --Thorns Rank 5
9910,  --Thorns Rank 6
26992, --Thorns Rank 7
53307, --Thorns Rank 8


--** Healer CDs Given w/ Short CD**---------------------------------------------

"Earth Shield",
"Lifebloom",
53601, --Sacred Shield

--**Passive Buffs Given**-------------------------------------------------------

"Focus Magic",
--"Amplify Magic",
--"Dampen Magic",
132, --Detect Invisibility

131159, --Aspect of the Pack

--[["Greater Blessing of Wisdom",
"Greater Blessing of Kings",
"Greater Blessing of Might",
"Greater Blessing of Sanctuary",
"Greater Bleiing of Light",
"Greater Blessing of Salvation",
"Mark of the Wild",
"Gift of the Wild",
"Commanding Shout",]]





}


local function CompactUnitFrame_UtilSetBuff(buffFrame, icon, duration, expirationTime, count)
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
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


hooksecurefunc("CompactUnitFrame_UpdateAuras", function(self)
	if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
		return
	end

	local unit, index, buff = self.displayedUnit, index, buff
	local sourceGUID, realm = UnitName(unit)
	for i = 1, 32 do --BUFF_MAX_DISPLAY
		local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i,"HELPFUL")

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
		overlay = CreateFrame("Button", "$parentBuffOverlayLeft", self, "CompactAuraTemplate")
		overlay:ClearAllPoints()
		overlay:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -1.5)
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
					if (buffs[buff] == nil and CLEUAura[sourceGUID]) or (CLEUAura[sourceGUID] and buffs[buff] > buffs[CLEUAura[sourceGUID][1][4]]) then
						icon = CLEUAura[sourceGUID][1][1]
						duration = CLEUAura[sourceGUID][1][2]
						expirationTime = CLEUAura[sourceGUID][1][3]
						spellId = CLEUAura[sourceGUID][1][4]
						cleu = true
						if spellId == 321686 or 248280 then
							count = #CLEUAura[sourceGUID]
						else
							count = 0
						end
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
			C_Timer.After(durationTime, function()
				overlay:SetShown(false)
			end)
		end
	else
		overlay:SetShown(index and true or false)
	end
end)


local castedAuraIds = {


}

local tip = CreateFrame('GameTooltip', 'GuardianOwnerTooltip', nil, 'GameTooltipTemplate')
local function GetGuardianOwner(guid)
  tip:SetOwner(WorldFrame, 'ANCHOR_NONE')
  tip:SetHyperlink('unit:' .. guid or '')
  local text = GuardianOwnerTooltipTextLeft2
	local text1 = GuardianOwnerTooltipTextLeft3
	if text1 and type(text1:GetText()) == "string" then
		if strmatch(text1:GetText(), "Corpse") then
			return "Corpse" --Only need for Earth Ele and Infernals
		else
			return strmatch(text and text:GetText() or '', "^([^%s-]+)")
		end
	else
		return strmatch(text and text:GetText() or '', "^([^%s-]+)")
	end
end

local BORCLEU = CreateFrame("Frame")
BORCLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BORCLEU:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		BORCLEU:CLEU()
	end
end)


function BORCLEU:CLEU()
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") then --Summoned CDs
			if castedAuraIds[spellId] then
				local duration = castedAuraIds[spellId]
				local namePrint, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + duration


				print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOL")

				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert (CLEUAura[sourceGUID], {icon, duration, expirationTime, spellId, destGUID})
				C_Timer.After(duration, function()
					if CLEUAura[sourceGUID] then
						CLEUAura[sourceGUID] = nil
					end
				end)
				self.ticker = C_Timer.NewTicker(0.5, function()
					local name = GetSpellInfo(spellId)
					if CLEUAura[sourceGUID] then
						for k, v in pairs(CLEUAura[sourceGUID]) do
							if CLEUAura[sourceGUID][k] then
								if v[5] then
	                if substring(v[5], -5) == substring(destGUID, -5) then --string.sub is to help witj Mirror Images bug
	                  if strmatch(GetGuardianOwner(v[5]), 'Corpse') or strmatch(GetGuardianOwner(v[5]), 'Level') then
	                		CLEUAura[sourceGUID][k] = nil
											tremove(CLEUAura[sourceGUID], k)
	                    print(sourceName.." "..GetGuardianOwner(v[5]).." "..namePrint.." "..substring(v[5], -7).." left w/ "..string.format("%.2f", expirationTime-GetTime()).." BOR")
	                    self.ticker:Cancel()
											if #CLEUAura[sourceGUID] == 0 then
											CLEUAura[sourceGUID] = nil
											end
											break
	                  end
	                end
								end
							end
						end
					end
				end, duration * 2)
			end
		end
	end
