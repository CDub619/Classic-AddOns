local addonName, AB = ...; 
local _
local buttons = {}

local ArenaBinds_EventFrame = CreateFrame("Frame")
ArenaBinds_EventFrame:RegisterEvent("ADDON_LOADED")
ArenaBinds_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaBinds_EventFrame:SetScript("OnEvent", function(self,event,...) self[event](self,event,...);end)


function ArenaBinds_EventFrame:ADDON_LOADED(self, addon)
	if addon == addonName then
		print("ArenaBinds Loaded.")

		-- locale
		_G["BINDING_HEADER_ARENABINDS"] = 'Arena Targeting'

		for i = 1,5 do
			_G["BINDING_NAME_CLICK TargetArena"..i.."Btn:LeftButton"] = "Target Arena "..i
			_G["BINDING_NAME_CLICK FocusArena"..i.."Btn:LeftButton"] = "Focus Arena "..i
		end
	end
end

function ArenaBinds_EventFrame:PLAYER_ENTERING_WORLD()
	-- set up all macros so they're ready to be called by the bindings set in the keybindings menu
	-----------------------------
	--------target
	-----------------------------

	for i = 1,5 do
		buttons['TargetArena'..i] = CreateFrame("Button", "TargetArena"..i.."Btn", ArenaBinds_EventFrame, "SecureActionButtonTemplate")
		buttons['TargetArena'..i]:SetAttribute("type", "macro")
		buttons['TargetArena'..i]:RegisterForClicks("AnyDown")
		buttons['TargetArena'..i]:SetAttribute("macrotext", "/tar [@arena"..i..", exists] arena"..i)
	end


	-----------------------------
	--------focus
	-----------------------------

	for i = 1,5 do
		buttons['FocusArena'..i] = CreateFrame("Button", "FocusArena"..i.."Btn", ArenaBinds_EventFrame, "SecureActionButtonTemplate")
		buttons['FocusArena'..i]:SetAttribute("type", "macro")
		buttons['FocusArena'..i]:RegisterForClicks("AnyDown")
		buttons['FocusArena'..i]:SetAttribute("macrotext", "/focus  [@arena"..i..", exists] arena"..i)
	end
end


-- Blizz won't let us do this FeelsBadMan
-- function ArenaBinds_TargetArena(i)
-- 	local button = buttons['TargetArena'..i]
-- 	SecureActionButton_OnClick(button, "LeftButton")
-- end

-- function ArenaBinds_FocusArena(i)
-- 	local button = buttons['FocusArena'..i]
-- 	SecureActionButton_OnClick(button, 'LeftButton')
-- end





-- <Bindings>
-- 	<Binding name="TARGETARENA1" runOnUp="true" header="ARENABINDS" category="Targeting">
-- 		--Target Arena 1
-- 		if (keystate == "down") then 
-- 			ArenaBinds_TargetArena(1)
-- 		end
-- 	</Binding>
-- 	<Binding name="TARGETARENA2" runOnUp="true" category="Targeting">
-- 		--Target Arena 2
-- 		if (keystate == "down") then 
-- 			ArenaBinds_TargetArena(2)
-- 		end
-- 	</Binding>
-- 	<Binding name="TARGETARENA3" runOnUp="true" category="Targeting">
-- 		--Target Arena 3
-- 		if (keystate == "down") then 
-- 			ArenaBinds_TargetArena(3)
-- 		end
-- 	</Binding>
-- 	<Binding name="TARGETARENA4" category="Targeting">
-- 		--Target Arena 4
-- 		if (keystate == "down") then 
-- 			ArenaBinds_TargetArena(4)
-- 		end
-- 	</Binding>
-- 	<Binding name="TARGETARENA5" category="Targeting">
-- 		--Target Arena 5
-- 		if (keystate == "down") then 
-- 			ArenaBinds_TargetArena(5)
-- 		end
-- 	</Binding>


-- 	<Binding name="FOCUSARENA1" category="Targeting">
-- 		--Focus Arena 1
-- 		if (keystate == "down") then 
-- 			ArenaBinds_FocusArena(1)
-- 		end
-- 	</Binding>
-- 	<Binding name="FOCUSARENA2" category="Targeting">
-- 		--Focus Arena 2
-- 		if (keystate == "down") then 
-- 			ArenaBinds_FocusArena(2)
-- 		end
-- 	</Binding>
-- 	<Binding name="FOCUSARENA3" category="Targeting">
-- 		--Focus Arena 3
-- 		if (keystate == "down") then 
-- 			ArenaBinds_FocusArena(3)
-- 		end
-- 	</Binding>
-- 	<Binding name="FOCUSARENA4" category="Targeting">
-- 		--Focus Arena 4
-- 		if (keystate == "down") then 
-- 			ArenaBinds_FocusArena(4)
-- 		end
-- 	</Binding>
-- 	<Binding name="FOCUSARENA5" category="Targeting">
-- 		--Focus Arena 5
-- 		if (keystate == "down") then 
-- 			ArenaBinds_FocusArena(5)
-- 		end
-- 	</Binding>
-- </Bindings>