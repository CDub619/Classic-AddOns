SLASH_RELOADUI1 = '/rl'
SlashCmdList.RELOADUI = ReloadUI

SLASH_FRAMESTKUI1 = '/fs'
SlashCmdList.FRAMESTKUI = function()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

for i = 1, NUM_CHAT_WINDOWS do
    _G['ChatFrame'..i..'EditBox']:SetAltArrowKeyMode(false)
end
