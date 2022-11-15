--added to github

local target
local targetExpirationTime = 0
local player
local playertExpirationTime = 0

local targetAnchor = ActionButton4
local playerAnchor = MultiBarBottomLeftButton4
local alpha = .8
local hieght = 40
local width = 40


local spellIds = {
		[6788] = "True", -- Weakened Soul
	}


local PWS = CreateFrame('Frame')
PWS:SetScript("OnEvent", function(frame, event, unit, arg1)
			if event == "PLAYER_TARGET_CHANGED" then
				PWS:UpdateShield("target")
      elseif event == "PLAYER_ENTERING_WORLD" then
        PWS:UpdateShield("target")
			--PWS:BodyAndSoulUpdateShield("player")
      elseif event == "PLAYER_LOGIN" then
        PWS:UpdateShield("target")
				--PWS:BodyAndSoulUpdateShield("player")
      elseif event == "UNIT_AURA" and unit == "target" then --or unit =="player" then
				PWS:UpdateShield("target")
				--PWS:BodyAndSoulUpdateShield("player")
      end
    end)
  PWS:RegisterUnitEvent('UNIT_AURA', "target", "player")
  PWS:RegisterEvent("PLAYER_ENTERING_WORLD")
  PWS:RegisterEvent("PLAYER_LOGIN")
  PWS:RegisterEvent("PLAYER_TARGET_CHANGED")

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Power Word: Shield Target
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

function PWS:UpdateShield(unit)
	local Shield, ExpirationTime, Duration, CD
	local start, durationCd, _ = GetSpellCooldown("Power Word: Shield");
	local cd = start + durationCd - GetTime()
	for i = 1, 40 do
		local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura(unit, i,  "HARMFUL")
		if not spellId then break end -- no more debuffs, terminate the loop
		if spellIds[spellId] then -- and source == "player" then
			Shield = true
			ExpirationTime = expirationTime
			Duration = duration
			CD = expirationTime - GetTime()
		end
	end
	if Shield and CD > cd then
		if targetExpirationTime ~= ExpirationTime then
			PWS:ShowShield(ExpirationTime, Duration)
		end
	elseif start > 0 and UnitIsFriend(unit,"player") then
		PWS:ShowShield(start + durationCd, durationCd)
	else
		if target then
			target:ClearAllPoints()
			target:Hide()
			target.cooldown:Hide()
			target = nil
			targetExpirationTime = 0
		end
	end
end

function PWS:ShowShield(expirationTime, duration)
	if target then
		target:ClearAllPoints()
		target:Hide()
		target.cooldown:Hide()
		target = nil
	end
	target = CreateFrame("Frame", "PWStarget")
	target:SetHeight(hieght)
	target:SetWidth(width)
	target.texture = target:CreateTexture(target, 'BACKGROUND')
	target.cooldown = CreateFrame("Cooldown", nil, target, 'CooldownFrameTemplate')
	target.cooldown:SetCooldown( expirationTime - duration, duration)
	target.cooldown:SetAllPoints(target)
	target.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
	target.cooldown:SetDrawSwipe(true)
	target.cooldown:SetDrawEdge(false)
	target.cooldown:SetSwipeColor(0, 0, 0, alpha)
	target.cooldown:SetReverse(false) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
	target.cooldown:SetDrawBling(false)
	target:ClearAllPoints()
	target:SetParent(targetAnchor)
	target:SetPoint("CENTER", targetAnchor, "CENTER", 0, 0)
 	targetExpirationTime = expirationTime
end

function PWS:BodyAndSoulUpdateShield(unit)
	local Shield, ExpirationTime, Duration, CD
	local start, durationCd, _ = GetSpellCooldown("Power Word: Shield");
	local cd = start + durationCd - GetTime()
	for i = 1, 40 do
		local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura("player", i,  "HARMFUL")
		if not spellId then break end -- no more debuffs, terminate the loop
		if spellIds[spellId] and source == "player" then
			Shield = true
			ExpirationTime = expirationTime
			Duration = duration
			CD = expirationTime - GetTime()
		end
	end
	if Shield and CD > cd then
		if playerExpirationTime ~= ExpirationTime then
			PWS:BodyAndSoulShowShield(ExpirationTime, Duration)
		end
	elseif start > 0 then
		PWS:BodyAndSoulShowShield(start + durationCd, durationCd)
	else
		if player then
			player:ClearAllPoints()
			player:Hide()
			player.cooldown:Hide()
			player = nil
			playerExpirationTime = 0
		end
	end
end

function PWS:BodyAndSoulShowShield(expirationTime, duration)
	if player then
		player:ClearAllPoints()
		player:Hide()
		player.cooldown:Hide()
		player = nil
	end
	player = CreateFrame("Frame", "PWSplayer")
	player:SetHeight(hieght)
	player:SetWidth(width)
	player.texture = player:CreateTexture(player, 'BACKGROUND')
	player.cooldown = CreateFrame("Cooldown", nil, player, 'CooldownFrameTemplate')
	player.cooldown:SetCooldown( expirationTime - duration, duration)
	player.cooldown:SetAllPoints(player)
	player.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
	player.cooldown:SetDrawSwipe(true)
	player.cooldown:SetDrawEdge(false)
	player.cooldown:SetSwipeColor(0, 0, 0, alpha)
	player.cooldown:SetReverse(false) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
	player.cooldown:SetDrawBling(false)
	player:ClearAllPoints()
	player:SetParent(playerAnchor)
	player:SetPoint("CENTER", playerAnchor, "CENTER", 0, 0)
	playerExpirationTime = expirationTime
end
