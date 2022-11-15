local frame = CreateFrame('Frame')

frame:RegisterEvent('PLAYER_REGEN_DISABLED')
frame:RegisterEvent('PLAYER_REGEN_ENABLED')
frame:RegisterEvent("ADDON_LOADED")

local soundsPath = 'Interface\\AddOns\\CombatIndicator\\Sounds\\'

frame:SetScript('OnEvent', function(self, event, arg1)

    if event == 'PLAYER_REGEN_DISABLED' then

        if (Preferences.notifyViaSound) then
            PlaySoundFile(soundsPath .. 'combat_enter.ogg', 'Master')
        end
        if (Preferences.notifyViaIcon) then
            VisualIndicator:Show()
        end

    elseif event == 'PLAYER_REGEN_ENABLED' then

        if (Preferences.notifyViaSound) then
            PlaySoundFile(soundsPath .. 'combat_exit.ogg', 'Master')
        end
        VisualIndicator:Hide()

    elseif event == "ADDON_LOADED" and arg1 == 'CombatIndicator' then

        if Preferences == nil then
            Preferences = {
                notifyViaIcon = true,
                notifyViaSound = true
            }
        end
    end
end)
