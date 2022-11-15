-- This file is loaded from "SoloRaidFrame.toc"

CompactRaidFrameManager:Show()
CompactRaidFrameManager.Hide = function() end
CompactRaidFrameContainer:Show()
CompactRaidFrameContainer.Hide = function() end

-- Override this global function so that 'party' and nil values return 'raid'
local getDAF = GetDisplayedAllyFrames
function GetDisplayedAllyFrames()
  local daf = getDAF()
  if daf == 'party' or not daf then
    return 'raid'
  else
    return daf
  end
end

local CRFC_OnEvent = CompactRaidFrameContainer_OnEvent
function CompactRaidFrameContainer_OnEvent(self, event, ...)
  -- Call original to perform its default behavior, also helps future protect this hook
  CRFC_OnEvent(self, event, ...)
  -- If all these are true, then the above call already did the TryUpdate
   local unit = ... or ""
  if ( unit == "player" or strsub(unit, 1, 4) == "raid" or strsub(unit, 1, 5) == "party" ) then
    return
  end
  -- Always update the RaidFrame
  if ( event == "UNIT_PET" ) and ( self.displayPets ) then
    CompactRaidFrameContainer_TryUpdate(self)
  end
end

