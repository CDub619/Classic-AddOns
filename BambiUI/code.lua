--------------------------------------------------------------------------------------------------------------------------------
--Blizzard SPell Alert sizeScale
--------------------------------------------------------------------------------------------------------------------------------
--[[hooksecurefunc("SpellActivationOverlay_ShowOverlay", function(self, spellID, texturePath, position, scale, r, g, b, vFlip, hFlip)
local sizeScale = 0.8;
local longSide = 256 * sizeScale;
local shortSide = 128 * sizeScale;
local width, height;
local overlay = SpellActivationOverlay_GetOverlay(self, spellID, position);

	if ( position == "CENTER" ) then
			width, height = longSide, longSide;
			overlay:SetPoint("CENTER", self, "CENTER", 0, 0);
		elseif ( position == "LEFT" ) then
			width, height = shortSide, longSide;
			overlay:SetPoint("RIGHT", self, "LEFT", 177.5, -42.5);
		elseif ( position == "RIGHT" ) then
			width, height = shortSide, longSide;
			overlay:SetPoint("LEFT", self, "RIGHT", -177.5, -42.5);
		elseif ( position == "TOP" ) then
			width, height = longSide, shortSide;
			overlay:SetPoint("BOTTOM", self, "TOP");
		elseif ( position == "BOTTOM" ) then
			width, height = longSide, shortSide;
			overlay:SetPoint("TOP", self, "BOTTOM");
		elseif ( position == "TOPRIGHT" ) then
			width, height = shortSide, shortSide;
			overlay:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
		elseif ( position == "TOPLEFT" ) then
			width, height = shortSide, shortSide;
			overlay:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
		elseif ( position == "BOTTOMRIGHT" ) then
			width, height = shortSide, shortSide;
			overlay:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
		elseif ( position == "BOTTOMLEFT" ) then
			width, height = shortSide, shortSide;
			overlay:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 0, 0);
		else
		--GMError("Unknown SpellActivationOverlay position: "..tostring(position));
		return;
	end
	overlay:SetScale(.35);
end]]

local BottomBar = CreateFrame("Frame", nil, UIParent)
BottomBar:SetSize(2500, 40)
BottomBar:SetPoint("CENTER", 0, -590)
BottomBar.texture = BottomBar:CreateTexture(nil, "BACKGROUND")
BottomBar.texture:SetAllPoints(true)
BottomBar.texture:SetColorTexture(0.0, 0.0, 0.0, 1)
BottomBar:SetFrameStrata("BACKGROUND")

--[[
local Anchors = CreateFrame("Frame", "PlayerAnchor", UIParent)
Anchors:SetSize(48, 48)
Anchors:SetPoint("CENTER", 53.5, -22.5)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

local Anchors = CreateFrame("Frame", "Party1Anchor", CompactRaidFrameContainer)
Anchors:SetSize(64, 64)
Anchors:SetPoint("TOPLEFT", -65, -2)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

local Anchors = CreateFrame("Frame", "Party2Anchor", CompactRaidFrameContainer)
Anchors:SetSize(64, 64)
Anchors:SetPoint("TOPLEFT", -65., -77)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

local Anchors = CreateFrame("Frame", "Party3Anchor", CompactRaidFrameContainer)
Anchors:SetSize(64, 64)
Anchors:SetPoint("TOPLEFT", -65, -152)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

local Anchors = CreateFrame("Frame", "Party4Anchor", CompactRaidFrameContainer)
Anchors:SetSize(64, 64)
Anchors:SetPoint("TOPLEFT", -65, -227)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

local Anchors = CreateFrame("Frame", "Party5Anchor", CompactRaidFrameContainer)
Anchors:SetSize(64, 64)
Anchors:SetPoint("TOPLEFT", -65, -302)
Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
Anchors.texture:SetAllPoints(true)
Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
]]

-- Frames require a numeric value at the end. Using party5 for player since party5 never exists.
local AnchorFrames = {}
local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=_G[n.."HeightSlider"],_G[n.."WidthSlider"]
h,w=
_G[n.."HeightSlider"],
_G[n.."WidthSlider"]
h:SetMinMaxValues(75,75)
w:SetMinMaxValues(150,150)

local hieght = {-2, -77, -152, -227, -302}

for i = 1, 5 do
	local frameName = "PartyAnchor" .. i
	local Anchors = CreateFrame("Frame", frameName, UIParent)
	if i == 5 then
		Anchors:SetPoint("CENTER", 53.5, -22.5)
		Anchors:SetSize(48, 48)
	else
		Anchors:SetParent(CompactRaidFrameContainer)
		Anchors:SetPoint("TOPLEFT", -65, hieght[i])
		Anchors:SetSize(64, 64)
	end

	-- this is needed for the addon to identify your frame-to-unit association
--	Anchors.yourUnitKey = i == 5 and "player" or "party" .. i
	Anchors.texture = Anchors:CreateTexture(nil, "BACKGROUND")
	Anchors.texture:SetAllPoints(true)
	--Anchors.texture:SetColorTexture(1.0, 1.0, 1.0, 0)

	AnchorFrames[i] = Anchors
end

FramerateLabel:ClearAllPoints()
FramerateLabel:SetPoint("RIGHT",UIParent,"CENTER", 0, -220)
FramerateLabel.SetPoint = function()
end

local PF = CreateFrame("Frame","PF",CompactRaidFrameContainer)
hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
		PF:UpdateBars()
end)
local OmniCD1 = CreateFrame("Frame","OmniCD1",CompactRaidFrameContainer)
hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
		PF:OmniCD1()
end)
local OmniCD2 = CreateFrame("Frame","OmniCD2",CompactRaidFrameContainer)
hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
		PF:OmniCD2()
end)

function PF:UpdateBars()
  --  print (GetNumGroupMembers())
				if (GetNumGroupMembers() == 0) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65, -2)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end
				  if (GetNumGroupMembers() == 2) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65., -77)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end
			  if (GetNumGroupMembers() == 3) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65, -152)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end
			  if (GetNumGroupMembers() == 4) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65, -227)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end
			  if (GetNumGroupMembers() == 5) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65, -302)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end
			  if (GetNumGroupMembers() > 5) then
				PF:ClearAllPoints()
				PF:SetSize(64, 64)
				PF:SetPoint("TOPLEFT", -65, -302)
				PF.texture = PF:CreateTexture(nil, "BACKGROUND")
				PF.texture:SetAllPoints(true)
				PF.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
			  end

				if InCombatLockdown() then
				else
		  	end
end
local x = 1 --Changes spacing from bottom of raid frame
local y = 0 --Changes spacing on row 2 from row 1
function PF:OmniCD1()
		    OmniCD1:ClearAllPoints()
				OmniCD1:SetSize(64, 64)
				OmniCD1.texture = OmniCD1:CreateTexture(nil, "BACKGROUND")
				OmniCD1.texture:SetAllPoints(true)
				OmniCD1.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
				if (GetNumGroupMembers() == 0) then
				OmniCD1:SetPoint("TOPLEFT", -67, -77 - x )
			  end
			  if UnitExists("party1") and not UnitExists("party2") then
				OmniCD1:SetPoint("TOPLEFT", -67., -152 - x)
			  end
			  if UnitExists("party1") and UnitExists("party2") then
				OmniCD1:SetPoint("TOPLEFT", -67, -227 - x)
			  end
			  if (UnitExists("partypet1") or UnitExists("partypet2")) and UnitExists("party1") and not UnitExists("party2") then --Party one w/ one pet
				OmniCD1:SetPoint("TOPLEFT", -67, -152 - 37.5 - x)
			  end
				if (UnitExists("partypet1") and UnitExists("partypet2")) and UnitExists("party1") and not UnitExists("party2") then --Party one w/ two pets
				OmniCD1:SetPoint("TOPLEFT", -67, -152 - 37.5 - 37.5 - x)
				end
			  if (UnitExists("partypet1") or UnitExists("partypet2")) and UnitExists("party1") and UnitExists("party2") then --Party one & Party two  w/ one pet
				OmniCD1:SetPoint("TOPLEFT", -67, -227 - 37.5 - x)
			  end
				if (UnitExists("partypet1") and UnitExists("partypet2")) and UnitExists("party1") and UnitExists("party2") then --Party one & Party two  w/ one pet
				OmniCD1:SetPoint("TOPLEFT", -67, -227 - 37.5 - 37.5 - x)
			  end
				OmniCD1.yourUnitKey = "party1"
				AnchorFrames[1] = OmniCD1
end
function PF:OmniCD2()
		    OmniCD2:ClearAllPoints()
				OmniCD2:SetSize(64, 64)
				OmniCD2.texture = OmniCD2:CreateTexture(nil, "BACKGROUND")
				OmniCD2.texture:SetAllPoints(true)
				OmniCD2.texture:SetColorTexture(1.0, 1.0, 1.0, 0)
				if (GetNumGroupMembers() == 0) then
				OmniCD2:SetPoint("TOPLEFT", -67, -77 - 31.5 - y)
			  end
			  if not UnitExists("party1") and UnitExists("party2") then
				OmniCD2:SetPoint("TOPLEFT", -67., -152 - 31.5 - y)
			  end
			  if UnitExists("party1") and UnitExists("party2") then
				OmniCD2:SetPoint("TOPLEFT", -67, -227 - 31.5 - y)
			  end
			  if UnitExists("partypet1") or UnitExists("partypet2") and UnitExists("party1") and UnitExists("party2") then
				OmniCD2:SetPoint("TOPLEFT", -67, -227 - 37.5 - 31.5 -y)
			  end
				if UnitExists("partypet1") and UnitExists("partypet2") and UnitExists("party1") and UnitExists("party2") then
				OmniCD2:SetPoint("TOPLEFT", -67, -227 - 37.5 - 37.5 - 31.5 - y)
			  end
				OmniCD2.yourUnitKey = "party2"
				AnchorFrames[2] = OmniCD2
end

hooksecurefunc("CompactUnitFrame_UpdateAggroHighlight", function(frame)
	local inInstance, instanceType = IsInInstance()
	if (instanceType == "arena" or instanceType == "pvp") or (instanceType ~= "raid" or  instanceType ~= "party") then
		frame.optionTable.displayAggroHighlight = false
		frame.optionTable.playLoseAggroHighlight = false
	end
end)

function PF:GROUP_ROSTER_UPDATE()
	PF:UpdateBars()
	PF:OmniCD1()
	PF:OmniCD2()
end

function PF:UNIT_PET()
	PF:OmniCD1()
	PF:OmniCD2()
end

function PF:ADDON_LOADED(arg1)
	if arg1 == "BambiUI" or arg1 == "OmniCD" then
		if OmniCD then
			OmniCD.AddUnitFrameData("BambiUI", "OmniCD", "yourUnitKey", 1)
		end
	end
	C_Timer.After(8, function()	-- delay checking to make sure all variables of the other addons are loaded
		self:ADDON_LOADED()
	end)
end

PF:RegisterEvent("ADDON_LOADED")
PF:RegisterEvent("GROUP_ROSTER_UPDATE")
PF:RegisterEvent("PLAYER_ENTERING_WORLD")
PF:RegisterEvent("UNIT_PET")
PF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
PF:SetScript("OnEvent",function(self,event,...) if self[event] then self[event](self,...) end end)
