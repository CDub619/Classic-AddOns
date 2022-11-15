SLASH_PREFERENCESUI1 = '/ci'
SlashCmdList.PREFERENCESUI = function()

    IconCheckButton:SetChecked(Preferences.notifyViaIcon)
    SoundCheckButton:SetChecked(Preferences.notifyViaSound)

    PreferencesScreen:Show()
end

SaveButton:SetScript("OnClick", function(self, ...)

    local isIconChecked = IconCheckButton:GetChecked()
    local isSoundChecked = SoundCheckButton:GetChecked()

    Preferences = {
        notifyViaIcon = isIconChecked,
        notifyViaSound = isSoundChecked
    }

    PreferencesScreen:Hide()
end)
