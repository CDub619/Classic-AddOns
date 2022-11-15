
--[[
-------------------------------------------
-- Addon: LoseControl
-- Version: 6.11
-- Authors: Kouri, millanzarreta
-------------------------------------------

-- Changelog:

No more changelogs in this file. To consult the last changes check https://www.curseforge.com/wow/addons/losecontrol/changes

Updated for 8.0.1
- Added more PvE spells (Uldir Raid, BfA Mythics and BfA Island Expeditions)
- Added ImmunePhysical category
- Added Interrupt category
- Fixed some minor bugs

Updated for 7.3.0 by millanzarreta
- Added Antorus Raid spells
- Added The Seat of the Triumvirate spells

Updated for 7.2.5 by millanzarreta
- Updated the spellID list to reflect the class changes
- Added more PvE spells (ToS Raid, Chromie Scenario)

Updated for 7.2.0 by millanzarreta
- Updated the spell ID list to reflect the class changes
- Added a large amount of PvE spells (EN Raid, ToV Raid, NH Raid and Legions Mythics) to spell ID list
- Added new option to allows hide party frames when the player is in raid group (never in arena)
- Improved the code to detect automatically the debuffs without defined duration (before, we had to add manually the spellId to the list)
- Fixed an error that could cause the icon to not display properly when the effect have not a defined time

Updated for 7.1.0 by millanzarreta
- Added most spells to spell ID list and corrected others (a lot of work, really...)
- Fixed the problem with spells that were not showing correctly (spells without duration, such as Solar Beam, Grounding Totem, Smoke Bomb, ...)
- Added new option to allows manage the blizzard cooldown countdown
- Added new option to allows remove the cooldown on bars for CC effects (tested for default Bars and Bartender4 Bars)
- Fixed a bug: now type /lc opens directly the LoseControl panel instead of Interface panel

Updated for 7.0.3 (Legion) by Hid@Emeriss and Wardz
- Added a large amount of spells, hopefully I didn't miss anything (important)
- Removed spell IDs that no longer exists.
- Added Ice Nova (mage) and Rake (druid) to spell ID list
- Fixed cooldown spiral

-- Code Credits - to the people whose code I borrowed and learned from:

Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

--Anchor to Gladius and Stealth/Alpha w/Gloss Option  Added
--Player LOCBliz Add All New CC  Added
----Add CC/Silence/Disarm/Root/Interrupt/Other Added
----Add Snare from string check “Movement”  Added
--Selected Priorities Show Newest Duration Remaining Aura Added
--Selected Priorities Show Highest Duration Remaining Aura Added
--Target/Focus/ToT/ToF Will Obey/Show Icons for Arena 123 Priorities if Arena 123 Added
--Arena Priorities vs Player, Party Priorities  Added
--Interupts Penance or Channel Casts Added
--Stealth Module  Added
--Mass Invis (Hack) Added
--Add stealth check and aura filters
--[[Duel (2 icons Red Layered Hue) test
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--[[SmokeBomb (2 icons Red Layered Hue)
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--cleu SpellCastSucess Timer (treated as buff in options for categoriesEnabled)
--2 Aura check Root Beam test
--Prio Change on Same SpellId per Spec : Ret/Holy Avenging Wrath test
--Stacks Only Icon: Tiger Eye Brew Inevitable Demise

local addonName, L = ...
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
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetInspectSpecialization = GetInspectSpecialization
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
local Ctimer = C_Timer.After
local substring = string.sub
local strformat = string.format
local CLocData = C_LossOfControl.GetActiveLossOfControlData
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
local debug = false -- type "/lc debug on" if you want to see UnitAura info logged to the console
local LCframes = {}
local LCframeplayer2
local Masque
if Masque then
Masque = LibStub("Masque", true)
end

local InterruptAuras = { }
local SmokeBombAuras = { }
local Earthen = { }
local Grounding = { }
local WarBanner = { }
local SanctifiedGrounds = { }
local Barrier = { }
local SGrounds = { }
local BeamAura = { }
local DuelAura = { }
local Arenastealth = { }

local spellIds = { }
local spellIdsArena = { }
local interruptsIds = { }
local cleuPrioCastedSpells = { }

local string = { }
local colorTypes = {
  Magic 	= {0.20,0.60,1.00},
  Curse 	= {0.60,0.00,1.00},
  Disease = {0.60,0.40,0},
  Poison 	= {0.00,0.60,0},
  none 	= {0.80,0,   0},
  Buff 	= {0.00,1.00,0},
  CLEU 	= {0.60,0.60,0.60},
}

-- Thanks to all the people on the Curse.com and WoWInterface forums who help keep this list up to date :)
local cleuSpells = { -- nil = Do Not Show
  {33831, 30, "PvE",  "Small_Offenisive_CDs", "Trees", "Trees"}, --Druid Trees
  {34433, 15, nil,  "Small_Offenisive_CDs", "Shadowfiend", "Shadowfiend"}, --Disc Pet Summmon
  {58833, 30, nil,  "Snares_Casted_Melee", "Mirror Image", "Mirror Image"}, --Mirror Image
  {58831, 30, nil,  "Snares_Casted_Melee", "Mirror Image", "Mirror Image"}, --Mirror Image
  {58834, 30, nil,  "Snares_Casted_Melee", "Mirror Image", "Mirror Image"}, --Mirror Image
  --{31687, 45, nil,  "Snares_Casted_Melee", "Water Elemental", "Water Elemental"}, --Water Elemental
  {51533, 45, nil,  "Small_Offenisive_CDs", "Feral Spirits", "Feral Spirits"}, --Feral Spirits

  {23989, 3, nil,  "Ranged_Major_OffenisiveCDs", "Readiness", "Readiness"}, --Readiness
  {14185, 3, nil,  "Ranged_Major_OffenisiveCDs", "Preparation", "Preparation"}, --Preparation

 --{spellId, duration. prio, prioArena, name, nameArena} --must have both names
}

local interrupts = {


  {72, 6},		-- Shield Bash (Warrior)
  {13491, 5},		-- Pummel (Iron Knuckles Item)
  {6552, 4},		-- Pummel (Warrior)
  {19647, 6},		-- Spell Lock (felhunter) (rank 2) (Warlock)
  {19244, 5},		-- Spell Lock (felhunter) (rank 1) (Warlock)
  {57994, 2},		-- Wind Shear (Shaman)
  {51680, 3},		-- Throwing Specialization (Rogue)
  {1766,5},		-- Kick (Rogue)
  {29443, 10},		-- Counterspell (Clutch of Foresight)
  {2139, 8},		-- Counterspell (Mage)
  {26090, 2},		-- Pummel (gorilla) (Hunter)
  {19675, 4},		-- Feral Charge (Druid)
  {47528, 4},		-- Mind Freeze (Death Knight)

}

local spellsArenaTable = {

  ----------------
  -- Death Knight
  ----------------
  {48707  , "Immune_Arena"},		-- Anti-Magic Shell
	{51209 , "CC_Arena"}, -- Hungering Cold (talent)
	{47476  , "Silence_Arena"},			-- Strangulate
	{49016  , "Melee_Major_OffenisiveCDs"},		-- Unholy Frenzy (talent)
	{49028  , "Melee_Major_OffenisiveCDs"},				-- Dancing Rune Weapon (talent)
  {49796  , "Melee_Major_OffenisiveCDs"},				-- Deathchill)
  {49206, "Player_Party_OffensiveCDs"}, --Summon Garg
	{48792  , "Big_Defensive_CDs"},				-- Icebound Fortitude
	{49039  , "Big_Defensive_CDs"},				-- Lichborne (talent)
  {50461  , "Big_Defensive_CDs"},		-- Anti-Magic Zone (talent)
	{55233  , "Small_Defensive_CDs"},				-- Vampiric Blood
	{51271  , "Small_Defensive_CDs"},				-- Unbreakable Armor (talent)
  {42650 , "Small_Defensive_CDs"}, -- Army of the Dead (not immune, the Death Knight takes less damage equal to his Dodge plus Parry chance)
  {45524  , "Snares_Ranged_Spamable"},				-- Chains of Ice
  {49222  , "Snares_Casted_Melee"},		-- Bone Shield
  {48263 , "Snares_Casted_Melee"}, --Frost Presence
  {48265 , "Snares_Casted_Melee"}, --Unholy Presence
  {48266 , "Snares_Casted_Melee"}, --Blood Presence

  ----------------
  -- Death Knight Ghoul
  ----------------
	{47481  , "CC_Arena"},				-- Gnaw
  {47484  , "Big_Defensive_CDs"},		-- -- Huddle (not immune, damage taken reduced 50%) (Turtle)

  ----------------
	--Druid
	----------------
	{17116 , "Drink_Purge"}, --Nature's Swiftness
  {16975 , "Drink_Purge"}, --Predatory Swiftness
  {9005   , "CC_Arena"},				-- Pounce (rank 1)
	{9823   , "CC_Arena"},				-- Pounce (rank 2)
	{9827   , "CC_Arena"},				-- Pounce (rank 3)
	{27006  , "CC_Arena"},				-- Pounce (rank 4)
	{49803  , "CC_Arena"},				-- Pounce (rank 5)
	{5211   , "CC_Arena"},				-- Bash (rank 1)
	{6798   , "CC_Arena"},				-- Bash (rank 2)
	{8983   , "CC_Arena"},				-- Bash (rank 3)
	{2637   , "CC_Arena"},				-- Hibernate (rank 1)
	{18657  , "CC_Arena"},				-- Hibernate (rank 2)
	{18658  , "CC_Arena"},				-- Hibernate (rank 3)
	{33786  , "CC_Arena"},				-- Cyclone
  {22570  , "CC_Arena"},				-- Maim (rank 1)
  {49802  , "CC_Arena"},				-- Maim (rank 2)
	{5215 , "Special_High"}, --Prowl Rank 1
	{6783 , "Special_High"}, --Prowl Rank 2
	{9913 , "Special_High"}, --Prowl Rank 3
  {48505  , "Ranged_Major_OffenisiveCDs"},				-- Starfall (talent) (rank 1)
	{53199  , "Ranged_Major_OffenisiveCDs"},				-- Starfall (talent) (rank 2)
	{53200  , "Ranged_Major_OffenisiveCDs"},				-- Starfall (talent) (rank 3)
	{53201  , "Ranged_Major_OffenisiveCDs"},				-- Starfall (talent) (rank 4)
	{50334 , "Ranged_Major_OffenisiveCDs"}, --Berserk (Feral)
  {339    , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 1)
	{1062   , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 2)
	{5195   , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 3)
	{5196   , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 4)
	{9852   , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 5)
	{9853   , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 6)
	{26989  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 7)
	{53308  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 8)
  {19975  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 1) (Nature's Grasp spell)
	{19974  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 2) (Nature's Grasp spell)
	{19973  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 3) (Nature's Grasp spell)
	{19972  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 4) (Nature's Grasp spell)
	{19971  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 5) (Nature's Grasp spell)
	{19970  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 6) (Nature's Grasp spell)
	{27010  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 7) (Nature's Grasp spell)
	{53313  , "Roots_90_Snares"},				-- Entangling Roots_90_Snaress (rank 8) (Nature's Grasp spell)
  {19675  , "Roots_90_Snares"},				-- Feral Charge Effect (Feral Charge talent)
  {45334  , "Roots_90_Snares"},				-- Feral Charge Effect (Feral Charge talent)
	{22812 , "Big_Defensive_CDs"}, --Barkskin
	{61336 , "Big_Defensive_CDs"}, --Survival Instincts
	{22842 , "Big_Defensive_CDs"}, --Frenzied Regeneration
	{29166 , "Big_Defensive_CDs"}, --Innervate
  {16689  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 1)
  {16810  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 2)
  {16811  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 3)
  {16812  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 4)
  {16813  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 5)
  {17329  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 6)
  {27009  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 7)
  {53312  , "Big_Defensive_CDs"},				-- Nature's Grasp (rank 8)
  {5217 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 1
  {6793 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 2
  {9845 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 3
  {9846 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 4
  {50212 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 5
  {50213 , "Small_Offenisive_CDs"}, --Tiger's Fury Rank 6w
  {48466, "Small_Offenisive_CDs"}, --Hurricane Rank 5
  {27012, "Small_Offenisive_CDs"}, --Hurricane Rank 4
  {17402, "Small_Offenisive_CDs"}, --Hurricane Rank 3
  {17401, "Small_Offenisive_CDs"}, --Hurricane Rank 2
  {16914, "Small_Offenisive_CDs"}, --Hurricane Rank 1
  {33357 , "Freedoms_Speed"}, --Dash Rank 3
  {9821 , "Freedoms_Speed"}, --Dash Rank 2
  {1850 , "Freedoms_Speed"}, --Dash Rank
	{768 , "Special_Low"}, --Cat Forn
	{5487 , "Special_Low"}, --Bear Form
	{24858 , "Special_Low"}, --Moonkin Form
  {13424 , "Special_Low"}, --Faerie Fire Rank 1
  {13752 , "Special_Low"}, --Faerie Fire Rank 2
  {770 , "Special_Low"}, --Faerie Fire Rank 3
  {33600 , "Special_Low"}, --Improved Faerie Fire Rank 1
  {33601 , "Special_Low"}, --Improved Faerie Fire Rank 2
  {33602 , "Special_Low"}, --Improved Faerie Fire Rank 3
  {16857 , "Special_Low"}, --Faerie Fire (Feral)
  {60089 , "Special_Low"}, --Faerie Fire (Feral)

	----------------
	-- Hunter
	----------------
	{26064 , "Immune_Arena"},  --Deterrence
	{53476 , "Immune_Arena"},  --Intervene
  {1513   , "CC_Arena"},				-- Scare Beast (rank 1)
	{14326  , "CC_Arena"},				-- Scare Beast (rank 2)
	{14327  , "CC_Arena"},				-- Scare Beast (rank 3)
	{3355   , "CC_Arena"},				-- Freezing Trap (rank 1)
	{14308  , "CC_Arena"},				-- Freezing Trap (rank 2)
	{14309  , "CC_Arena"},				-- Freezing Trap (rank 3)
	{60210  , "CC_Arena"},				-- Freezing Arrow Effect
	{19386  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 1)
	{24132  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 2)
	{24133  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 3)
	{27068  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 4)
	{49011  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 5)
	{49012  , "CC_Arena"},				-- Wyvern Sting (talent) (rank 6)
	{19503  , "CC_Arena"},				-- Scatter Shot (talent)
	{34490 , "Silence_Arena"},  --Silencing Shot
	{5384 , "Special_High"}, --Fiegn Death
	{34471 , "Special_High"}, --The Beast Within (talent) (not immuune to spells, only immune to some CC's)
	{19574 , "Ranged_Major_OffenisiveCDs"}, --Bestial Wrath (talent)
	{3045 , "Ranged_Major_OffenisiveCDs"}, --Rapid Fire
	{53434 , "Ranged_Major_OffenisiveCDs"}, --Call of the Wild
  {19306  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 1)
	{20909  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 2)
	{20910  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 3)
	{27067  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 4)
	{48998  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 5)
	{48999  , "Roots_90_Snares"},				-- Counterattack (talent) (rank 6)
	{19185  , "Roots_90_Snares"},				-- Entrapment (talent) (rank 1)
	{64803  , "Roots_90_Snares"},				-- Entrapment (talent) (rank 2)
	{64804  , "Roots_90_Snares"},				-- Entrapment (talent) (rank 3)
  {53359  , "Disarms"},			-- Chimera Shot - Scorpid (talent)
  {3034 , "Player_Party_OffensiveCDs"}, --Viper Sting Rank
  {54216 , "Freedoms_Speed"},		-- Master's Call
	{13810 , "Snares_WithCDs"}, --Frost Trap Aura
	--{13809, "Snares_WithCDs"}, --Frost Trap
  {5116 , "Snares_WithCDs"}, --Concussive Shot
  {35101 , "Snares_WithCDs"}, --Concussive Barrage (talent)
  {2974, "Snares_Casted_Melee"}, --Wing Clip
  {13163, "Snares_Casted_Melee"}, --Aspect of the Monkey
  {5118, "Snares_Casted_Melee"}, --Aspect of the Cheetah
  {13165, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 1
  {14318, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 2
  {14319, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 3
  {14320, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 4
  {14321, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 5
  {14322, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 6
  {25296, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 7
  {27044, "Snares_Casted_Melee"}, --Aspect of the Hawk Rank 8
  {13159, "Snares_Casted_Melee"}, --Aspect of the Pack
  {13161, "Snares_Casted_Melee"}, --Aspect of the Beast
  {20043, "Snares_Casted_Melee"}, --Aspect of the Wild Rank 1
  {20190, "Snares_Casted_Melee"}, --Aspect of the Wild Rank 2
  {27045, "Snares_Casted_Melee"}, --Aspect of the Wild Rank 3
  {49071, "Snares_Casted_Melee"}, --Aspect of the Wild Rank 4
  {34074, "Snares_Casted_Melee"}, --Aspect of the Viper
  {61846, "Snares_Casted_Melee"}, --Aspect of the Dragonhawk Rank 1
  {61847, "Snares_Casted_Melee"}, --Aspect of the Dragonhawk Rank 2

  ----------------
		-- Hunter Pets
	----------------
  {24394  , "CC_Arena"},				-- Intimidation (talent)
  {50519  , "CC_Arena"},				-- Sonic Blast (rank 1) (Bat)
  {53564  , "CC_Arena"},				-- Sonic Blast (rank 2) (Bat)
  {53565  , "CC_Arena"},				-- Sonic Blast (rank 3) (Bat)
  {53566  , "CC_Arena"},				-- Sonic Blast (rank 4) (Bat)
  {53567  , "CC_Arena"},				-- Sonic Blast (rank 5) (Bat)
  {53568  , "CC_Arena"},				-- Sonic Blast (rank 6) (Bat)
  {50518  , "CC_Arena"},				-- Ravage (rank 1) (Ravager)
  {53558  , "CC_Arena"},				-- Ravage (rank 2) (Ravager)
  {53559  , "CC_Arena"},				-- Ravage (rank 3) (Ravager)wwwwwwwwwww
  {53560  , "CC_Arena"},				-- Ravage (rank 4) (Ravager)
  {53561  , "CC_Arena"},				-- Ravage (rank 5) (Ravager)
  {53562  , "CC_Arena"},				-- Ravage (rank 6) (Ravager)
  {4167   , "Roots_90_Snares"},				-- Web (rank 1) (Spider)
  {4168   , "Roots_90_Snares"},				-- Web II
  {4169   , "Roots_90_Snares"},				-- Web III
  {54706  , "Roots_90_Snares"},				-- Venom Web Spray (rank 1) (Silithid)
  {55505  , "Roots_90_Snares"},				-- Venom Web Spray (rank 2) (Silithid)
  {55506  , "Roots_90_Snares"},				-- Venom Web Spray (rank 3) (Silithid)
  {55507  , "Roots_90_Snares"},				-- Venom Web Spray (rank 4) (Silithid)
  {55508  , "Roots_90_Snares"},				-- Venom Web Spray (rank 5) (Silithid)
  {55509  , "Roots_90_Snares"},				-- Venom Web Spray (rank 6) (Silithid)
  {50245  , "Roots_90_Snares"},				-- Pin (rank 1) (Crab)
  {53544  , "Roots_90_Snares"},				-- Pin (rank 2) (Crab)
  {53545  , "Roots_90_Snares"},				-- Pin (rank 3) (Crab)
  {53546  , "Roots_90_Snares"},				-- Pin (rank 4) (Crab)
  {53547  , "Roots_90_Snares"},				-- Pin (rank 5) (Crab)
  {53548  , "Roots_90_Snares"},				-- Pin (rank 6) (Crab)
  {53148  , "Roots_90_Snares"},				-- Charge (Bear and Carrion Bird)
  {25999  , "Roots_90_Snares"},				-- Boar Charge (Boar)
  {54404  , "Disarms"},				-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
  {50541  , "Disarms"},			-- Snatch (rank 1) (Bird of Prey)
  {53537  , "Disarms"},			-- Snatch (rank 2) (Bird of Prey)
  {53538  , "Disarms"},			-- Snatch (rank 3) (Bird of Prey)
  {53540  , "Disarms"},			-- Snatch (rank 4) (Bird of Prey)
  {53542  , "Disarms"},			-- Snatch (rank 5) (Bird of Prey)
  {53543  , "Disarms"},			-- Snatch (rank 6) (Bird of Prey)
	{19263 , "Big_Defensive_CDs"},  --Shell Shield (damage taken reduced 50%) (Turtle)
	{1742 , "Big_Defensive_CDs"},  --Cower (damage taken reduced 40%)

	----------------
	-- Mage
	----------------
	{45438 , "Immune_Arena"}, --Ice Block
  {118    , "CC_Arena"},				-- Polymorph (rank 1)
	{12824  , "CC_Arena"},				-- Polymorph (rank 2)
	{12825  , "CC_Arena"},				-- Polymorph (rank 3)
	{12826  , "CC_Arena"},				-- Polymorph (rank 4)
	{28271  , "CC_Arena"},				-- Polymorph: Turtle
	{28272  , "CC_Arena"},				-- Polymorph: Pig
	{61305  , "CC_Arena"},				-- Polymorph: Black Cat
	{61721  , "CC_Arena"},				-- Polymorph: Rabbit
	{61780  , "CC_Arena"},				-- Polymorph: Turkey
	{71319  , "CC_Arena"},				-- Polymorph: Turkey
	{61025  , "CC_Arena"},				-- Polymorph: Serpent
	{59634  , "CC_Arena"},				-- Polymorph - Penguin (Glyph)
	{12355  , "CC_Arena"},				-- Impact (talent)
	{31661  , "CC_Arena"},				-- Dragon's Breath (rank 1) (talent)
	{33041  , "CC_Arena"},				-- Dragon's Breath (rank 2) (talent)
	{33042  , "CC_Arena"},				-- Dragon's Breath (rank 3) (talent)
	{33043  , "CC_Arena"},				-- Dragon's Breath (rank 4) (talent)
	{42949  , "CC_Arena"},				-- Dragon's Breath (rank 5) (talent)
	{42950  , "CC_Arena"},				-- Dragon's Breath (rank 6) (talent)
	{44572  , "CC_Arena"},				-- Deep Freeze (talent)
  {18469  , "Silence_Arena"},			-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	{55021  , "Silence_Arena"},			-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	{66 , "Special_High"}, --Invisibility
	{32612 , "Special_High"}, --Invisibility
  {11129, "Ranged_Major_OffenisiveCDs"}, --Combustion
  {54160, "Ranged_Major_OffenisiveCDs"}, --Arcane Power
  {12472, "Ranged_Major_OffenisiveCDs"}, --Icy Veins
  {12043 , "Ranged_Major_OffenisiveCDs"}, --Presence of Mind
  {122    , "Roots_90_Snares"},				-- Frost Nova (rank 1)
  {865    , "Roots_90_Snares"},				-- Frost Nova (rank 2)
  {6131   , "Roots_90_Snares"},				-- Frost Nova (rank 3)
  {10230  , "Roots_90_Snares"},				-- Frost Nova (rank 4)
  {27088  , "Roots_90_Snares"},				-- Frost Nova (rank 5)
  {42917  , "Roots_90_Snares"},				-- Frost Nova (rank 6)
  {12494  , "Roots_90_Snares"},				-- Frostbite (talent)
  {55080  , "Roots_90_Snares"},				-- Shattered Barrier (talent)
  {33395  , "Roots_90_Snares"},				-- Freeze
	{64346  , "Disarms"},			-- Fiery Payback (talent)
  {12051, "Small_Defensive_CDs"},      --Evocation
  {120    , "Snares_WithCDs"},				-- Cone of Cold (rank 1)
  {8492   , "Snares_WithCDs"},				-- Cone of Cold (rank 2)
  {10159  , "Snares_WithCDs"},				-- Cone of Cold (rank 3)
  {10160  , "Snares_WithCDs"},				-- Cone of Cold (rank 4)
  {10161  , "Snares_WithCDs"},				-- Cone of Cold (rank 5)
  {27087  , "Snares_WithCDs"},				-- Cone of Cold (rank 6)
  {42930  , "Snares_WithCDs"},				-- Cone of Cold (rank 7)
  {42931  , "Snares_WithCDs"},				-- Cone of Cold (rank 8)
  {11426, "Special_Low"}, --Ice Barrier  Rank 1
  {13031, "Special_Low"}, --Ice Barrier  Rank 2
  {13032, "Special_Low"}, --Ice Barrier  Rank 3
  {13033, "Special_Low"}, --Ice Barrier  Rank 4
  {27134, "Special_Low"}, --Ice Barrier  Rank 5
  {33405, "Special_Low"}, --Ice Barrier  Rank 6
  {43038, "Special_Low"}, --Ice Barrier  Rank 7
  {43039, "Special_Low"}, --Ice Barrier  Rank 8
  {31589 , "Snares_Ranged_Spamable"}, --Slow
  {11113  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 1)
  {13018  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 2)
  {13019  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 3)
  {13020  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 4)
  {13021  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 5)
  {27133  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 6)
  {33933  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 7)
  {42944  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 8)
  {42945  , "Snares_Ranged_Spamable"},				-- Blast Wave (talent) (rank 9)
  {12484  , "Snares_Ranged_Spamable"},				-- Chilled (rank 1) (Improved Blizzard talent)
	{12485  , "Snares_Ranged_Spamable"},				-- Chilled (rank 2) (Improved Blizzard talent)
	{12486  , "Snares_Ranged_Spamable"},				-- Chilled (rank 3) (Improved Blizzard talent)

	----------------
	-- Palladin
	----------------
	{20216 , "Drink_Purge"}, --Divine Favor
	{642 , "Immune_Arena"}, --Divine Shield
	{19753 , "Immune_Arena"}, --Divine Intervention
  {853    , "CC_Arena"},				-- Hammer of Justice (rank 1)
	{5588   , "CC_Arena"},				-- Hammer of Justice (rank 2)
	{5589   , "CC_Arena"},				-- Hammer of Justice (rank 3)
	{10308  , "CC_Arena"},				-- Hammer of Justice (rank 4)
	{2812   , "CC_Arena"},				-- Holy Wrath (rank 1)
	{10318  , "CC_Arena"},				-- Holy Wrath (rank 2)
	{27139  , "CC_Arena"},				-- Holy Wrath (rank 3)
	{48816  , "CC_Arena"},				-- Holy Wrath (rank 4)
	{48817  , "CC_Arena"},				-- Holy Wrath (rank 5)
	{20170  , "CC_Arena"},				-- Stun (Seal of Justice)
	{10326  , "CC_Arena"},				-- Turn Evil
	{20066  , "CC_Arena"},				-- Repentance (talent)
	{63529 , "Silence_Arena"}, --Silenced - Shield of the Templar (talent)
  {31821 , "Special_High"},			-- Aura Mastery
  {31884, "Big_Defensive_CDs"}, --Avenging Wrath
  {1022   , "Big_Defensive_CDs"},	-- Hand of Protection (rank 1)
	{5599   , "Big_Defensive_CDs"},	-- Hand of Protection (rank 2)
	{10278  , "Big_Defensive_CDs"},	-- Hand of Protection (rank 3)
  {6940 , "Big_Defensive_CDs"}, --Blessing of Sacrifice
  {64205 , "Big_Defensive_CDs"}, --Divine Sacrifice
  {498 , "Big_Defensive_CDs"}, --Divine Protection
  {31852 , "Big_Defensive_CDs"}, --Ardent Defender
  {31842, "Small_Offenisive_CDs"},--Divine Illumination
  {54428, "Small_Offenisive_CDs"},--Divine Plea
  {1044 , "Freedoms_Speed"}, --Blessing of Freedom
  {25771 , "Special_Low"}, --Forbearance
  {20164, "Snares_Casted_Melee"}, --Seal of Justice
  {20165, "Snares_Casted_Melee"}, --Seal of Light
  {21084, "Snares_Casted_Melee"}, --Seal of Righteousness
  {31801, "Snares_Casted_Melee"}, --Seal of Vengance
  {348700, "Snares_Casted_Melee"}, --Seal of Martyr
  {31892, "Snares_Casted_Melee"}, --Seal of Blood
  {20375, "Snares_Casted_Melee"}, --Seal of Command
  {348704, "Snares_Casted_Melee"}, --Seal of Corruption

	----------------
	-- Priest
	----------------
	{47585 , "Immune_Arena"}, --Dispersion
	{27827 , "Immune_Arena"}, --Spirit of Redemption
  {605    , "CC_Arena"},				-- Mind Control
	{8122   , "CC_Arena"},				-- Psychic Scream (rank 1)
	{8124   , "CC_Arena"},				-- Psychic Scream (rank 2)
	{10888  , "CC_Arena"},				-- Psychic Scream (rank 3)
	{10890  , "CC_Arena"},				-- Psychic Scream (rank 4)
	{9484   , "CC_Arena"},				-- Shackle Undead (rank 1)
	{9485   , "CC_Arena"},				-- Shackle Undead (rank 2)
	{10955  , "CC_Arena"},				-- Shackle Undead (rank 3)
	{64044  , "CC_Arena"},				-- Psychic Horror (talent)
	{64058  , "Disarms"},			-- Psychic Horror (talent)
	{15487 , "Silence_Arena"}, --Silence_Arena
  {33206 , "Big_Defensive_CDs"}, --Pain Suprresion
  {47788 , "Big_Defensive_CDs"}, --Guardian Spirit
  {10060, "Big_Defensive_CDs"}, --Power Infusion
  {14751 , "Small_Offenisive_CDs"}, --Inner Focus
  {64901 , "Special_Low"}, --Hymn of Hope
  {6346, "Special_Low"}, --Fear Ward
  {15473, "Snares_Casted_Melee"}, --Shadowform

	----------------
	-- Rogue
	----------------
	{45182 , "Immune_Arena"}, --Cheating Death
  {2094   , "CC_Arena"},				-- Blind
	{408    , "CC_Arena"},				-- Kidney Shot (rank 1)
	{8643   , "CC_Arena"},				-- Kidney Shot (rank 2)
	{1833   , "CC_Arena"},				-- Cheap Shot
	{6770   , "CC_Arena"},				-- Sap (rank 1)
	{2070   , "CC_Arena"},				-- Sap (rank 2)
	{11297  , "CC_Arena"},				-- Sap (rank 3)
	{51724  , "CC_Arena"},				-- Sap (rank 4)
	{1776   , "CC_Arena"},				-- Gouge
	{1330 , "Silence_Arena"}, --Garrote - Silence_Arena
	{18425  , "Silence_Arena"},			-- Kick - Silenced (talent)
	{26889 , "Special_High"}, --Vanish
	{26888 , "Special_High"}, --Vanish
  {11327 , "Special_High"}, --Vanish
  {1857 , "Special_High"}, --Vanish
  {27617 , "Special_High"}, --Vanish
  {11329 , "Special_High"}, --Vanish
  {44290 , "Special_High"}, --Vanish
	{1784 , "Special_High"}, --Stealth
  {51722 , "Disarms"}, --Dismantle
  {13750 , "Melee_Major_OffenisiveCDs"}, --Adrenaline Rush
  {51690, "Melee_Major_OffenisiveCDs"}, --Killing Spree (talent)
  {51713 , "Melee_Major_OffenisiveCDs"}, --Shadow Dance
  {51713 , "Melee_Major_OffenisiveCDs"}, --Shadow Dance
  {31224 , "Big_Defensive_CDs"}, --Cloak of Shadows
  {5277, "Big_Defensive_CDs"}, --Evasion
  {26669, "Big_Defensive_CDs"}, --Evasion
  {57933 , "Small_Offenisive_CDs"}, --Tricks of the Trade (PvP)
  {13877 , "Small_Offenisive_CDs"}, --Blade Flurry
  {14177 , "Small_Offenisive_CDs"}, --Cold Blood
  {14278, "Small_Defensive_CDs"}, --Ghostly Strike
  {2983 , "Freedoms_Speed"}, --Sprint Rank 1
  {8696 , "Freedoms_Speed"}, --Sprint Rank 3
  {11305 , "Freedoms_Speed"}, --Sprint Rank 3
  {36554 , "Freedoms_Speed"}, --Shadowstep
  {14251 , "Special_Low"}, --Rioste (20% Attack Slow)
  {51693 , "Special_Low"}, -- Waylay
  {31125  , "Snares_WithCDs"},				-- Dazed (Blade Twisting) (rank 1) (talent)
  {51585  , "Snares_WithCDs"},				-- Dazed (Blade Twisting) (rank 2) (talent)
  {26679  , "Snares_Ranged_Spamable"},				-- Deadly Throw (rank 1)
  {48673  , "Snares_Ranged_Spamable"},				-- Deadly Throw (rank 2)
  {48674  , "Snares_Ranged_Spamable"},				-- Deadly Throw (rank 3)
  {3409 , "Snares_Casted_Melee"}, --Crippling Poison

  ----------------
  -- Shaman
  ----------------
  {16188 , "Drink_Purge"}, --Nature's Swiftness (talent)
  {8178 ,  "Immune_Arena"}, --Grounding Totem Effect
  {39796 , "CC_Arena"}, --Stoneclaw Stun (Stoneclaw Totem)
  {51514  , "CC_Arena"},				-- Hex
  {58861  , "CC_Arena"},				-- Bash (Spirit Wolf)
  {16166, "Ranged_Major_OffenisiveCDs"}, --Elemental Mastery (talent)
  {2825 , "Ranged_Major_OffenisiveCDs"}, --Bloodlust
  {32182 , "Ranged_Major_OffenisiveCDs"}, --Heroism
  {64695  , "Roots_90_Snares"},				-- Earthgrab (Storm, Earth and Fire talent)
  {63685  , "Roots_90_Snares"},				-- Freeze (Frozen Power talent)
  {30823, "Big_Defensive_CDs"}, --Shamanistic Rage (talent) (damage taken reduced by 30%)
  {2645 , "Freedoms_Speed"}, --Ghost Wolf
  {8056   , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 1)
	{8058   , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 2)
	{10472  , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 3)
	{10473  , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 4)
	{25464  , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 5)
	{49235  , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 6)
	{49236  , "Snares_Ranged_Spamable"},				-- Frost Shock (rank 7)
  {3600   , "Snares_Ranged_Spamable"},    --Earthbind (Earthbind Totem)
  {8034   , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 1)
  {8037   , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 2)
  {10458  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 3)
  {16352  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 4)
  {16353  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 5)
  {25501  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 6)
  {58797  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 7)
  {58798  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 8)
  {58799  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 9)
  {64186  , "Snares_Casted_Melee"},				-- Frostbrand Attack (rank 9)
  {3600   , "Snares_Casted_Melee"},				-- Earthbind (Earthbind Totem)

	----------------
	-- Warlock
	----------------
  {710    , "CC_Arena"},				-- Banish (rank 1)
	{18647  , "CC_Arena"},				-- Banish (rank 2)
	{5782   , "CC_Arena"},				-- Fear (rank 1)
	{6213   , "CC_Arena"},				-- Fear (rank 2)
	{6215   , "CC_Arena"},				-- Fear (rank 3)
	{5484   , "CC_Arena"},				-- Howl of Terror (rank 1)
	{17928  , "CC_Arena"},				-- Howl of Terror (rank 2)
	{6789   , "CC_Arena"},				-- Death Coil (rank 1)
	{17925  , "CC_Arena"},				-- Death Coil (rank 2)
	{17926  , "CC_Arena"},				-- Death Coil (rank 3)
	{27223  , "CC_Arena"},				-- Death Coil (rank 4)
	{47859  , "CC_Arena"},				-- Death Coil (rank 5)
	{47860  , "CC_Arena"},				-- Death Coil (rank 6)
	{22703  , "CC_Arena"},				-- Inferno Effect
	{30283  , "CC_Arena"},				-- Shadowfury (rank 1) (talent)
	{30413  , "CC_Arena"},				-- Shadowfury (rank 2) (talent)
	{30414  , "CC_Arena"},				-- Shadowfury (rank 3) (talent)
	{47846  , "CC_Arena"},				-- Shadowfury (rank 4) (talent)
	{47847  , "CC_Arena"},				-- Shadowfury (rank 5) (talent)
	{60995  , "CC_Arena"},				-- Demon Charge (metamorphosis talent)
	{54786  , "CC_Arena"},				-- Demon Leap (metamorphosis talent)
	{24259 , "Silence_Arena"}, --Unstable Affliction
	{31117 , "Silence_Arena"}, --Spell Lock
  {7812 , "Small_Defensive_CDs"}, --Sacrifice Rank 1
  {19438 , "Small_Defensive_CDs"}, --Sacrifice Rank 2
  {19444 , "Small_Defensive_CDs"}, --Sacrifice Rank 3
  {19445 , "Small_Defensive_CDs"}, --Sacrifice Rank 4
  {19446 , "Small_Defensive_CDs"}, --Sacrifice Rank 5
  {19447 , "Small_Defensive_CDs"}, --Sacrifice Rank 6
  {27492 , "Small_Defensive_CDs"}, --Sacrifice Rank 8
  {47986 , "Small_Defensive_CDs"}, --Sacrifice Rank 9
  --{702 , "Special_Low"}, --Curse of Weakness
  {6229 , "Special_Low"}, --Shadow Ward Rank 1
  {11739 , "Special_Low"}, --Shadow Ward Rank 2
  {11740 , "Special_Low"}, --Shadow Ward Rank 3
  {28610 , "Special_Low"}, --Shadow Ward Rank 4
  {47890 , "Special_Low"}, --Shadow Ward Rank 5
  {47891 , "Special_Low"}, --Shadow Ward Rank 6
  {63311  , "Snares_WithCDs"},				-- Glyph of Shadowflame
  {18118   , "Snares_WithCDs"},				-- AfterMath
  --{18223 , "Snares_Ranged_Spamable"}, --Curse of Exhaustion (talent)
  {132, "Snares_Casted_Melee"}, --Detec Invisibility

    ----------------
    -- Warlock Pets
    ----------------
  	{4511   , "Immune_Arena"},		-- Phase Shift (Imp)
    {32752  , "CC_Arena"},			-- Summoning Disorientation
    {6358   , "CC_Arena"},			-- Seduction (SuCC_Arenaubus)
    {19482  , "CC_Arena"},			-- War Stomp (Doomguard)
    {30153  , "CC_Arena"},			-- Intercept Stun (rank 1) (Felguard)
    {30195  , "CC_Arena"},			-- Intercept Stun (rank 2) (Felguard)
    {30197  , "CC_Arena"},			-- Intercept Stun (rank 3) (Felguard)
    {47995  , "CC_Arena"},			-- Intercept Stun (rank 4) (Felguard)
    {89  , "Snares_WithCDs"},				-- Cripple (Doomguard)


	----------------
	-- Warrior
	----------------
	{46924  , "Immune_Arena"}, -- Bladestorm (not immune to dmg}, only to LoC)
  {7922   , "CC_Arena"},				-- Charge (rank 1/2/3)
	{20253  , "CC_Arena"},				-- Intercept
	{5246   , "CC_Arena"},				-- Intimidating Shout
	{20511  , "CC_Arena"},				-- Intimidating Shout
	{12809  , "CC_Arena"},				-- Concussion Blow (talent)
	{46968  , "CC_Arena"},				-- Shockwave (talent)
  {74347  , "Silence_Arena"},			-- Silenced - Gag Order (Improved Shield Bash talent)
  {18498  , "Silence_Arena"},			-- Silenced - Gag Order (Improved Shield Bash talent)
  {23920 , "Special_High"}, -- Spell Reflection
  {59725 , "Special_High"}, -- Spell Reflection
  {3411 , "Special_High"}, -- Intervene
  {23694  , "Roots_90_Snares"},				-- Improved Hwamstring (talent)
  {58373  , "Roots_90_Snares"},				-- Glyph of Hamstring
  {676  , "Disarms"}, --Disarm
  {1719 , "Melee_Major_OffenisiveCDs"}, -- Recklessness
  {12292 , "Melee_Major_OffenisiveCDs"}, -- Death Wish
  {871 , "Big_Defensive_CDs"}, -- Shield Wall
  {55694 , "Big_Defensive_CDs"}, -- Enraged Regeneration
  {20230 , "Big_Defensive_CDs"}, -- Retaliation
  {12976 , "Big_Defensive_CDs"}, -- Last Stand
  {18499 , "Big_Defensive_CDs"}, -- Berserker Rage
  {12328 , "Small_Offenisive_CDs"}, -- Sweeping Strikes
  {2565 , "Small_Defensive_CDs"}, -- Shield Block
  {12323 , "Snares_WithCDs"}, -- Piercing Howl
  --{197690 , "Special_Low"}, -- Defensive Stance
  --{2457 , "Special_Low"}, -- Battle Stance
  --{2458 , "Special_Low"}, -- Berserker Stance
  {12323   , "Snares_Casted_Melee"},				-- Piercing Howl (talent)
  {1715, "Snares_Casted_Melee"}, --Hamstring



	----------------
	-- Misc.
	----------------

  {"Food", "Drink_Purge"},
  {"Drink", "Drink_Purge"},
  {"Food & Drink", "Drink_Purge"},
  {"Refreshment", "Drink_Purge"},
	[20549]  = "CC_Arena",				-- War Stomp (tauren racial)
  {25046  , "Silence_Arena"},		-- Arcane Torrent (blood elf racial)
  {28730  , "Silence_Arena"},		-- Arcane Torrent (blood elf racial)
  {58984, "Special_High"}, -- Shadowmeld
  {59543, "Small_Defensive_CDs"}, -- Gift of the Naaru



	}

local spellsTable = {

{"PVP", --TAB
	{51209  , "CC"},				-- Hungering Cold (talent)
	{47481  , "CC"},				-- Gnaw

  {9005   , "CC"},				-- Pounce (rank 1)
	{9823   , "CC"},				-- Pounce (rank 2)
	{9827   , "CC"},				-- Pounce (rank 3)
	{27006  , "CC"},				-- Pounce (rank 4)
	{49803  , "CC"},				-- Pounce (rank 5)
	{5211   , "CC"},				-- Bash (rank 1)
	{6798   , "CC"},				-- Bash (rank 2)
	{8983   , "CC"},				-- Bash (rank 3)
	{2637   , "CC"},				-- Hibernate (rank 1)
	{18657  , "CC"},				-- Hibernate (rank 2)
	{18658  , "CC"},				-- Hibernate (rank 3)
	{33786  , "CC"},				-- Cyclone
  {22570  , "CC"},				-- Maim (rank 1)
  {49802  , "CC"},				-- Maim (rank 2)

  {1513   , "CC"},				-- Scare Beast (rank 1)
	{14326  , "CC"},				-- Scare Beast (rank 2)
	{14327  , "CC"},				-- Scare Beast (rank 3)
	{3355   , "CC"},				-- Freezing Trap (rank 1)
	{14308  , "CC"},				-- Freezing Trap (rank 2)
	{14309  , "CC"},				-- Freezing Trap (rank 3)
	{60210  , "CC"},				-- Freezing Arrow Effect
	{19386  , "CC"},				-- Wyvern Sting (talent) (rank 1)
	{24132  , "CC"},				-- Wyvern Sting (talent) (rank 2)
	{24133  , "CC"},				-- Wyvern Sting (talent) (rank 3)
	{27068  , "CC"},				-- Wyvern Sting (talent) (rank 4)
	{49011  , "CC"},				-- Wyvern Sting (talent) (rank 5)
	{49012  , "CC"},				-- Wyvern Sting (talent) (rank 6)
	{19503  , "CC"},				-- Scatter Shot (talent)

  {24394  , "CC"},				-- Intimidation (talent)
  {50519  , "CC"},				-- Sonic Blast (rank 1) (Bat)
  {53564  , "CC"},				-- Sonic Blast (rank 2) (Bat)
  {53565  , "CC"},				-- Sonic Blast (rank 3) (Bat)
  {53566  , "CC"},				-- Sonic Blast (rank 4) (Bat)
  {53567  , "CC"},				-- Sonic Blast (rank 5) (Bat)
  {53568  , "CC"},				-- Sonic Blast (rank 6) (Bat)
  {50518  , "CC"},				-- Ravage (rank 1) (Ravager)
  {53558  , "CC"},				-- Ravage (rank 2) (Ravager)
  {53559  , "CC"},				-- Ravage (rank 3) (Ravager)
  {53560  , "CC"},				-- Ravage (rank 4) (Ravager)
  {53561  , "CC"},				-- Ravage (rank 5) (Ravager)
  {53562  , "CC"},				-- Ravage (rank 6) (Ravager)

  {118    , "CC"},				-- Polymorph (rank 1)
	{12824  , "CC"},				-- Polymorph (rank 2)
	{12825  , "CC"},				-- Polymorph (rank 3)
	{12826  , "CC"},				-- Polymorph (rank 4)
	{28271  , "CC"},				-- Polymorph: Turtle
	{28272  , "CC"},				-- Polymorph: Pig
	{61305  , "CC"},				-- Polymorph: Black Cat
	{61721  , "CC"},				-- Polymorph: Rabbit
	{61780  , "CC"},				-- Polymorph: Turkey
	{71319  , "CC"},				-- Polymorph: Turkey
	{61025  , "CC"},				-- Polymorph: Serpent
	{59634  , "CC"},				-- Polymorph - Penguin (Glyph)
	{12355  , "CC"},				-- Impact (talent)
	{31661  , "CC"},				-- Dragon's Breath (rank 1) (talent)
	{33041  , "CC"},				-- Dragon's Breath (rank 2) (talent)
	{33042  , "CC"},				-- Dragon's Breath (rank 3) (talent)
	{33043  , "CC"},				-- Dragon's Breath (rank 4) (talent)
	{42949  , "CC"},				-- Dragon's Breath (rank 5) (talent)
	{42950  , "CC"},				-- Dragon's Breath (rank 6) (talent)
	{44572  , "CC"},				-- Deep Freeze (talent)

  {853    , "CC"},				-- Hammer of Justice (rank 1)
	{5588   , "CC"},				-- Hammer of Justice (rank 2)
	{5589   , "CC"},				-- Hammer of Justice (rank 3)
	{10308  , "CC"},				-- Hammer of Justice (rank 4)
	{2812   , "CC"},				-- Holy Wrath (rank 1)
	{10318  , "CC"},				-- Holy Wrath (rank 2)
	{27139  , "CC"},				-- Holy Wrath (rank 3)
	{48816  , "CC"},				-- Holy Wrath (rank 4)
	{48817  , "CC"},				-- Holy Wrath (rank 5)
	{20170  , "CC"},				-- Stun (Seal of Justice)
	{10326  , "CC"},				-- Turn Evil
	{20066  , "CC"},				-- Repentance (talent)

  {605    , "CC"},				-- Mind Control
	{8122   , "CC"},				-- Psychic Scream (rank 1)
	{8124   , "CC"},				-- Psychic Scream (rank 2)
	{10888  , "CC"},				-- Psychic Scream (rank 3)
	{10890  , "CC"},				-- Psychic Scream (rank 4)
	{9484   , "CC"},				-- Shackle Undead (rank 1)
	{9485   , "CC"},				-- Shackle Undead (rank 2)
	{10955  , "CC"},				-- Shackle Undead (rank 3)
	{64044  , "CC"},				-- Psychic Horror (talent)

  {2094   , "CC"},				-- Blind
	{408    , "CC"},				-- Kidney Shot (rank 1)
	{8643   , "CC"},				-- Kidney Shot (rank 2)
	{1833   , "CC"},				-- Cheap Shot
	{6770   , "CC"},				-- Sap (rank 1)
	{2070   , "CC"},				-- Sap (rank 2)
	{11297  , "CC"},				-- Sap (rank 3)
	{51724  , "CC"},				-- Sap (rank 4)
	{1776   , "CC"},				-- Gouge

  {39796  , "CC"},				-- Stoneclaw Stun (Stoneclaw Totem)
	{51514  , "CC"},				-- Hex
	{58861  , "CC"},				-- Bash (Spirit Wolf)

  {710    , "CC"},				-- Banish (rank 1)
	{18647  , "CC"},				-- Banish (rank 2)
	{5782   , "CC"},				-- Fear (rank 1)
	{6213   , "CC"},				-- Fear (rank 2)
	{6215   , "CC"},				-- Fear (rank 3)
	{5484   , "CC"},				-- Howl of Terror (rank 1)
	{17928  , "CC"},				-- Howl of Terror (rank 2)
	{6789   , "CC"},				-- Death Coil (rank 1)
	{17925  , "CC"},				-- Death Coil (rank 2)
	{17926  , "CC"},				-- Death Coil (rank 3)
	{27223  , "CC"},				-- Death Coil (rank 4)
	{47859  , "CC"},				-- Death Coil (rank 5)
	{47860  , "CC"},				-- Death Coil (rank 6)
	{22703  , "CC"},				-- Inferno Effect
	{30283  , "CC"},				-- Shadowfury (rank 1) (talent)
	{30413  , "CC"},				-- Shadowfury (rank 2) (talent)
	{30414  , "CC"},				-- Shadowfury (rank 3) (talent)
	{47846  , "CC"},				-- Shadowfury (rank 4) (talent)
	{47847  , "CC"},				-- Shadowfury (rank 5) (talent)
	{60995  , "CC"},				-- Demon Charge (metamorphosis talent)
	{54786  , "CC"},				-- Demon Leap (metamorphosis talent)

  {32752  , "CC"},			-- Summoning Disorientation
  {6358   , "CC"},			-- Seduction (Succubus)
  {19482  , "CC"},			-- War Stomp (Doomguard)
  {30153  , "CC"},			-- Intercept Stun (rank 1) (Felguard)
  {30195  , "CC"},			-- Intercept Stun (rank 2) (Felguard)
  {30197  , "CC"},			-- Intercept Stun (rank 3) (Felguard)
  {47995  , "CC"},			-- Intercept Stun (rank 4) (Felguard)

  {7922   , "CC"},				-- Charge (rank 1/2/3)
	{20253  , "CC"},				-- Intercept
	{5246   , "CC"},				-- Intimidating Shout
	{20511  , "CC"},				-- Intimidating Shout
	{12809  , "CC"},				-- Concussion Blow (talent)
	{46968  , "CC"},				-- Shockwave (talent)

  {20549  , "CC"},				-- War Stomp (tauren racial)

  {47476  , "Silence"},		-- Strangulate
  {34490  , "Silence"},		-- Silencing Shot
  {18469  , "Silence"},			-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	{55021  , "Silence"},			-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	{63529  , "Silence"},			-- Silenced - Shield of the Templar (talent)
	{15487  , "Silence"},			-- Silence (talent)
  {1330   , "Silence"},		-- Garrote - Silence
	{18425  , "Silence"},			-- Kick - Silenced (talent)
  {31117  , "Silence"},		-- Unstable Affliction
  {24259  , "Silence"},		-- Spell Lock (Felhunter)
  {74347  , "Silence"},			-- Silenced - Gag Order (Improved Shield Bash talent)
	{18498  , "Silence"},			-- Silenced - Gag Order (Improved Shield Bash talent)
  {25046  , "Silence"},		-- Arcane Torrent (blood elf racial)
  {28730  , "Silence"},		-- Arcane Torrent (blood elf racial)

  {339    , "Root"},				-- Entangling Roots (rank 1)
	{1062   , "Root"},				-- Entangling Roots (rank 2)
	{5195   , "Root"},				-- Entangling Roots (rank 3)
	{5196   , "Root"},				-- Entangling Roots (rank 4)
	{9852   , "Root"},				-- Entangling Roots (rank 5)
	{9853   , "Root"},				-- Entangling Roots (rank 6)
	{26989  , "Root"},				-- Entangling Roots (rank 7)
	{53308  , "Root"},				-- Entangling Roots (rank 8)
  {19975  , "Root"},				-- Entangling Roots (rank 1) (Nature's Grasp spell)
	{19974  , "Root"},				-- Entangling Roots (rank 2) (Nature's Grasp spell)
	{19973  , "Root"},				-- Entangling Roots (rank 3) (Nature's Grasp spell)
	{19972  , "Root"},				-- Entangling Roots (rank 4) (Nature's Grasp spell)
	{19971  , "Root"},				-- Entangling Roots (rank 5) (Nature's Grasp spell)
	{19970  , "Root"},				-- Entangling Roots (rank 6) (Nature's Grasp spell)
	{27010  , "Root"},				-- Entangling Roots (rank 7) (Nature's Grasp spell)
	{53313  , "Root"},				-- Entangling Roots (rank 8) (Nature's Grasp spell)
  {19675  , "Root"},				-- Feral Charge Effect (Feral Charge talent)
  {45334  , "Root"},				-- Feral Charge Effect (Feral Charge talent)

  {19306  , "Root"},				-- Counterattack (talent) (rank 1)
	{20909  , "Root"},				-- Counterattack (talent) (rank 2)
	{20910  , "Root"},				-- Counterattack (talent) (rank 3)
	{27067  , "Root"},				-- Counterattack (talent) (rank 4)
	{48998  , "Root"},				-- Counterattack (talent) (rank 5)
	{48999  , "Root"},				-- Counterattack (talent) (rank 6)
	{19185  , "Root"},				-- Entrapment (talent) (rank 1)
	{64803  , "Root"},				-- Entrapment (talent) (rank 2)
	{64804  , "Root"},				-- Entrapment (talent) (rank 3)

  {4167   , "Root"},				-- Web
  {4168   , "Root"},				-- Web II
  {4169   , "Root"},				-- Web III
  {54706  , "Root"},				-- Venom Web Spray (rank 1) (Silithid)
  {55505  , "Root"},				-- Venom Web Spray (rank 2) (Silithid)
  {55506  , "Root"},				-- Venom Web Spray (rank 3) (Silithid)
  {55507  , "Root"},				-- Venom Web Spray (rank 4) (Silithid)
  {55508  , "Root"},				-- Venom Web Spray (rank 5) (Silithid)
  {55509  , "Root"},				-- Venom Web Spray (rank 6) (Silithid)
  {50245  , "Root"},				-- Pin (rank 1) (Crab)
  {53544  , "Root"},				-- Pin (rank 2) (Crab)
  {53545  , "Root"},				-- Pin (rank 3) (Crab)
  {53546  , "Root"},				-- Pin (rank 4) (Crab)
  {53547  , "Root"},				-- Pin (rank 5) (Crab)
  {53548  , "Root"},				-- Pin (rank 6) (Crab)
  {53148  , "Root"},				-- Charge (Bear and Carrion Bird)
  {25999   , "Root"},				-- Boar Charge

  {122    , "Root"},				-- Frost Nova (rank 1)
	{865    , "Root"},				-- Frost Nova (rank 2)
	{6131   , "Root"},				-- Frost Nova (rank 3)
	{10230  , "Root"},				-- Frost Nova (rank 4)
	{27088  , "Root"},				-- Frost Nova (rank 5)
	{42917  , "Root"},				-- Frost Nova (rank 6)
	{12494  , "Root"},				-- Frostbite (talent)
	{55080  , "Root"},				-- Shattered Barrier (talent)
	{33395  , "Root"},				-- Freeze

  {64695  , "Root"},				-- Earthgrab (Storm, Earth and Fire talent)
	{63685  , "Root"},				-- Freeze (Frozen Power talent)

  {23694  , "Root"},				-- Improved Hwamstring (talent)
	{58373  , "Root"},				-- Glyph of Hamstring

  --{642    , "ImmunePlayer"},			-- Divine Shield
	{47585  , "ImmunePlayer", "Dispersion"},			-- Dispersion
  {27827  , "ImmunePlayer", "Spirit of".."\n".."Redemption"},			-- Spirit of Redemption

	--{3034 , "Disarm_Warning"},   -- Viper Sting Mana Drain

--  {182387 , "CC_Warning"},      -- Earthquake

  --[[{5215   , "Stealth"}, --Prowl Rank 1
	{6783   , "Stealth"}, --Prowl Rank 2
	{9913   , "Stealth"}, --Prowl Rank 3
  {5384   , "Stealth"},     -- Fiegn Death
  {66     , "Stealth"},     -- Invis
  {32612  , "Stealth"},     -- Invis
  {1784   , "Stealth"},     -- Stealth]]


  {19753 , "Immune", "Divine".."\n".."Intervention"},	-- Divine Intervention
  {1022   , "Immune", "Hand of".."\n".."Protection"},	-- Hand of Protection (rank 1)
  {5599   , "Immune", "Hand of".."\n".."Protection"},	-- Hand of Protection (rank 2)
  {10278  , "Immune", "Hand of".."\n".."Protection"},	-- Hand of Protection (rank 3)

--  "ImmuneSpell",
--	"ImmunePhysical",

  {31821 , "AuraMastery_Cast_Auras", "Aura".."\n".."Mastery"},			-- Aura Mastery

	--{127797 , "ROP_Vortex"},				-- Ursol's Vortex
	--{102793 , "ROP_Vortex"},				-- Ursol's Vortex

  {53359  , "Disarm"},			-- Chimera Shot - Scorpid (talent)
  {50541  , "Disarm"},			-- Snatch (rank 1) (Bird of Prey)
  {53537  , "Disarm"},			-- Snatch (rank 2) (Bird of Prey)
  {53538  , "Disarm"},			-- Snatch (rank 3) (Bird of Prey)
  {53540  , "Disarm"},			-- Snatch (rank 4) (Bird of Prey)
  {53542  , "Disarm"},			-- Snatch (rank 5) (Bird of Prey)
  {53543  , "Disarm"},			-- Snatch (rank 6) (Bird of Prey)
	{64346  , "Disarm"},			-- Fiery Payback (talent)
	{64058  , "Disarm"},			-- Psychic Horror (talent)
	{51722  , "Disarm"},			-- Dismantle

  --{5760 , "Haste_Reduction"},			-- Mind-numbing Poison
  --{25810 , "Haste_Reduction"},			-- Mind-numbing Poison
  --{199890 , "Haste_Reduction"},			-- Curse of Tongues

  {54404  , "Dmg_Hit_Reduction", "Dust".."\n".."Cloud"},			-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
  --{199892 , "Dmg_Hit_Reduction"},   -- Curse of Weakness

  {2825 , "AOE_DMG_Modifiers", "Bloodlust"},				-- Bloodlust (Shamanism pvp talent)
  {32182 , "AOE_DMG_Modifiers", "Heroism"},				-- Heroism (Shamanism pvp talent
  {57933  , "AOE_DMG_Modifiers", "Tricks of The".."\n".."Trade"},				-- Tricks of the Trade

  --212183 , "Friendly_Smoke_Bomb"},			-- Smoke Bomb

	{8178   , "AOE_Spell_Refections", "Grounding".."\n".."Totem"},		-- Grounding Totem Effect (Grounding Totem)

  --{260881 , "Speed_Freedoms"}, --Spirit Wolf
  --{204262 , "Speed_Freedoms"}, --Spectral Recovery
  --{2645 , "Speed_Freedoms"}, --Ghost Wolf

  {54216 , "Speed_Freedoms", "Master's".."\n".."Call"},		-- Master's Call
  {1044 , "Speed_Freedoms", "Blessing of".."\n".."Freedom"},		-- Blessing of Freedom

  {33357 , "Freedoms"}, --Dash Rank 3
  {9821 , "Freedoms"}, --Dash Rank 2
  {1850 , "Freedoms"}, --Dash Rank 1
  {2983 , "Freedoms"}, --Sprint Rank 1
  {8696 , "Freedoms"}, --Sprint Rank 3
  {11305 , "Freedoms"}, --Sprint Rank 3
  {36554 , "Freedoms"}, --Shadowstep
  {54861 , "Freedoms", "Nitro".."\n".."Boots"},		-- Nitro Boots


	{53476 , "Friendly_Defensives", "Intervene"},  --Intervene
  {6940 , "Friendly_Defensives", "Blessing of".."\n".."Sacrifice"}, --Blessing of Sacrifice
  {3411 , "Friendly_Defensives", "Intervene"}, --Intervene

  {29166, "Mana_Regen", "Innervate"},		-- Innervate
  {64901, "Mana_Regen", "Hymn".."\n".."Hope"},		-- Symbol of Hope

  --{6346, "CC_Reduction"},		--Fear Ward

  --{200183, "Personal_Offensives"},		-- Apotheosis
  --{319952, "Personal_Offensives"},		-- Surrender to Madness
  --{117679, "Personal_Offensives"},		-- Incarnation
  --{22842, "Peronsal_Defensives"},		-- Frenzied Regeneration
  --{22812, "Peronsal_Defensives"},		-- Barkskin


  {10060, "Movable_Cast_Auras", "Power".."\n".."Infusion"},		-- Power Infusion


  --"Other", --
	--"PvE", --PVE onlys

  --{51693, "SnareSpecial", "Waylay"},		-- Waylay
  {45524,  "SnareSpecial", "Chains"},		-- Chains of Ice

  {15571  , "SnarePhysical70", "Aspect".."\n".."Dazed"},				-- Dazed (Aspect of the Cheetah and Aspect of the Pack)
  {31125  , "SnarePhysical70"},				-- Dazed (Blade Twisting) (rank 1) (talent)
  {51585  , "SnarePhysical70"},				-- Dazed (Blade Twisting) (rank 2) (talent)
  {3409   , "SnarePhysical70"},		       -- Crippling Poison (Poison)
	{63311  , "SnarePhysical70"},				--	-- Glyph of Shadowflame

  {31589  , "SnareMagic70", "Slow"},				-- Slow (talent)
	{18118  , "SnareMagic70"},				-- Aftermath (talent)

  {58617  , "SnarePhysical50"}, --Glyph of Heart Strike
  {68766  , "SnarePhysical50"}, --Desecration (talent)
  {50436  , "SnarePhysical50"}, --Icy Clutch (talent)
  {50259  , "SnarePhysical50", "Dazed"}, --Dazed
  {61391  , "SnarePhysical50", "Typhoon"},			-- Typhoon (talent) (rank 1)
  {61390  , "SnarePhysical50", "Typhoon"},				-- Typhoon (talent) (rank 2)
  {61388  , "SnarePhysical50", "Typhoon"},				-- Typhoon (talent) (rank 3)
  {61387  , "SnarePhysical50", "Typhoon"},			-- Typhoon (talent) (rank 4)
  {53227  , "SnarePhysical50", "Typhoon"},			-- Typhoon (talent) (rank 5)
  {2974   , "SnarePhysical50"},       --Wing Clip
  {5116   , "SnarePhysical50"},       --Concussive Shot
  {13809  , "SnarePhysical50"},				-- Frost Trap
  {13810  , "SnarePhysical50"},				-- Frost Trap Aura
  {35101  , "SnarePhysical50"},				-- Concussive Barrage (talent)
  {50271  , "SnarePhysical50"},				-- Tendon Rip (rank 1) (Hyena)
  {53571  , "SnarePhysical50"},				-- Tendon Rip (rank 2) (Hyena)
  {53572  , "SnarePhysical50"},				-- Tendon Rip (rank 3) (Hyena)
  {53573  , "SnarePhysical50"},				-- Tendon Rip (rank 4) (Hyena)
  {53574  , "SnarePhysical50"},				-- Tendon Rip (rank 5) (Hyena)
  {53575  , "SnarePhysical50"},				-- Tendon Rip (rank 6) (Hyena)
  {54644  , "SnarePhysical50"},				-- Froststorm Breath (rank 1) (Chimaera)
  {55488  , "SnarePhysical50"},				-- Froststorm Breath (rank 2) (Chimaera)
  {55489  , "SnarePhysical50"},				-- Froststorm Breath (rank 3) (Chimaera)
  {55490  , "SnarePhysical50"},				-- Froststorm Breath (rank 4) (Chimaera)
  {55491  , "SnarePhysical50"},				-- Froststorm Breath (rank 5) (Chimaera)
  {55492  , "SnarePhysical50"},				-- Froststorm Breath (rank 6) (Chimaera)
  {11113  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 1)
  {13018  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 2)
  {13019  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 3)
  {13020  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 4)
  {13021  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 5)
  {27133  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 6)
  {33933  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 7)
  {42944  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 8)
  {42945  , "SnarePhysical50"},				-- Blast Wave (talent) (rank 9)
  {15407  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 1)
  {17311  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 2)
  {17312  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 3)
  {17313  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 4)
  {17314  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 5)
  {18807  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 6)
  {25387  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 7)
  {48155  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 8)
  {48156  , "SnarePhysical50"},				-- Mind Flay (talent) (rank 9)
  {51693  , "SnarePhysical50", "Waylay"},		-- Waylay
  {26679  , "SnarePhysical50"},				-- Deadly Throw (rank 1)
  {48673  , "SnarePhysical50"},				-- Deadly Throw (rank 2)
  {48674  , "SnarePhysical50"},				-- Deadly Throw (rank 3)
  {8034   , "SnarePhysical50"},				-- Frostbrand Attack (rank 1)
  {8037   , "SnarePhysical50"},				-- Frostbrand Attack (rank 2)
  {10458  , "SnarePhysical50"},				-- Frostbrand Attack (rank 3)
  {16352  , "SnarePhysical50"},				-- Frostbrand Attack (rank 4)
  {16353  , "SnarePhysical50"},				-- Frostbrand Attack (rank 5)
  {25501  , "SnarePhysical50"},				-- Frostbrand Attack (rank 6)
  {58797  , "SnarePhysical50"},				-- Frostbrand Attack (rank 7)
  {58798  , "SnarePhysical50"},				-- Frostbrand Attack (rank 8)
  {58799  , "SnarePhysical50"},				-- Frostbrand Attack (rank 9)
  {64186  , "SnarePhysical50"},				-- Frostbrand Attack (rank 9)
  {29703  , "SnarePhysical50"},				-- Dazed (Shield Bash)
  {1715   , "SnarePhysical50"},				-- Hamstring
  {12323  , "SnarePhysical50"},				-- Piercing Howl (talent)

  --{3409, "SnarePosion50"},		-- Crippling Poison

  {58179, "SnareMagic50"},		-- Infected Wounds) (talent) (rank 1)
  {58180, "SnareMagic50"},		-- Infected Wounds) (talent) (rank 2)
  {58181, "SnareMagic50"},		-- Infected Wounds) (talent) (rank 3)
  {120    , "SnareMagic50"},				-- Cone of Cold (rank 1)
  {8492   , "SnareMagic50"},				-- Cone of Cold (rank 2)
  {10159  , "SnareMagic50"},				-- Cone of Cold (rank 3)
  {10160  , "SnareMagic50"},				-- Cone of Cold (rank 4)
  {10161  , "SnareMagic50"},				-- Cone of Cold (rank 5)
  {27087  , "SnareMagic50"},				-- Cone of Cold (rank 6)
  {42930  , "SnareMagic50"},				-- Cone of Cold (rank 7)
  {42931  , "SnareMagic50"},				-- Cone of Cold (rank 8)
  {116    , "SnareMagic50"},				-- Frostbolt (rank 1)
	{205    , "SnareMagic50"},				-- Frostbolt (rank 2)
	{837    , "SnareMagic50"},				-- Frostbolt (rank 3)
	{7322   , "SnareMagic50"},				-- Frostbolt (rank 4)
	{8406   , "SnareMagic50"},				-- Frostbolt (rank 5)
	{8407   , "SnareMagic50"},				-- Frostbolt (rank 6)
	{8408   , "SnareMagic50"},				-- Frostbolt (rank 7)
	{10179  , "SnareMagic50"},				-- Frostbolt (rank 8)
	{10180  , "SnareMagic50"},				-- Frostbolt (rank 9)
	{10181  , "SnareMagic50"},				-- Frostbolt (rank 10)
	{25304  , "SnareMagic50"},				-- Frostbolt (rank 11)
	{27071  , "SnareMagic50"},				-- Frostbolt (rank 12)
	{27072  , "SnareMagic50"},				-- Frostbolt (rank 13)
	{38697  , "SnareMagic50"},				-- Frostbolt (rank 14)
	{42841  , "SnareMagic50"},				-- Frostbolt (rank 15)
	{42842  , "SnareMagic50"},				-- Frostbolt (rank 16)
  {59638  , "SnareMagic50"},				-- Frostbolt (Mirror Images)
  {44614  , "SnareMagic50"},				-- Frostfire Bolt (rank 1)
  {47610  , "SnareMagic50"},				-- Frostfire Bolt (rank 2)
  {31935  , "SnareMagic50"},				-- Avenger's Shield (rank 1) (talent)
  {32699  , "SnareMagic50"},				-- Avenger's Shield (rank 2) (talent)
  {32700  , "SnareMagic50"},				-- Avenger's Shield (rank 3) (talent)
  {48826  , "SnareMagic50"},				-- Avenger's Shield (rank 4) (talent)
  {48827  , "SnareMagic50"},				-- Avenger's Shield (rank 5) (talent)
  {8056   , "SnareMagic50"},				-- Frost Shock (rank 1)
  {8058   , "SnareMagic50"},				-- Frost Shock (rank 2)
  {10472  , "SnareMagic50"},				-- Frost Shock (rank 3)
  {10473  , "SnareMagic50"},				-- Frost Shock (rank 4)
  {25464  , "SnareMagic50"},				-- Frost Shock (rank 5)
  {49235  , "SnareMagic50"},				-- Frost Shock (rank 6)
  {49236  , "SnareMagic50"},				-- Frost Shock (rank 7)
  {3600   , "SnareMagic50"},				-- Earthbind (Earthbind Totem)
  {89  , "SnareMagic50"},				-- Earthbind (Earthbind Totem)


  {12484  , "SnarePhysical30"},				-- Chilled (rank 1) (Improved Blizzard talent)
	{12485  , "SnarePhysical30"},				-- Chilled (rank 2) (Improved Blizzard talent)
	{12486  , "SnarePhysical30"},				-- Chilled (rank 3) (Improved Blizzard talent)

  {18223  , "SnareMagic30"},				-- Curse of Exhaustion (talent)


	--Other

},

	----------------
	-- Other
	----------------


------------------------
---- PVE WOTLK
------------------------
{"Vault of Archavon Raid",
-- -- Archavon the Stone Watcher
{58965    , "CC"},				-- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
{61672    , "CC"},				-- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
{58663    , "CC"},				-- Stomp
{60880    , "CC"},				-- Stomp
-- -- Emalon the Storm Watcher
{63080    , "CC"},				-- Stoned (!)
-- -- Toravon the Ice Watcher
{72090    , "Root"},				-- Freezing Ground
},
------------------------
{"Naxxramas (WotLK) Raid",
-- -- Trash
{56427    , "CC"},				-- War Stomp
{55314    , "Silence"},			-- Strangulate
{55334    , "Silence"},			-- Strangulate
{54722    , "Immune"},			-- Stoneskin (not immune, big health regeneration)
{53803    , "Other"},				-- Veil of Shadow
{55315    , "Other"},				-- Bone Armor
{55336    , "Other"},				-- Bone Armor
{55848    , "Other"},				-- Invisibility
{54769    , "Snare"},				-- Slime Burst
{54339    , "Snare"},				-- Mind Flay
{29407    , "Snare"},				-- Mind Flay
{54805    , "Snare"},				-- Mind Flay
-- -- Anub'Rekhan
{54022    , "CC"},				-- Locust Swarm
-- -- Grand Widow Faerlina
{54093    , "Silence"},			-- Silence
-- -- Maexxna
{54125    , "CC"},				-- Web Spray
{54121    , "Other"},				-- Necrotic Poison (healing taken reduced by 75%)
-- -- Noth the Plaguebringer
{54814    , "Snare"},				-- Cripple
-- -- Heigan the Unclean
{29310    , "Other"},				-- Spell Disruption (casting speed decreased by 300%)
-- -- Loatheb
{55593    , "Other"},				-- Necrotic Aura (healing taken reduced by 100%)
-- -- Sapphiron
{55699    , "Snare"},				-- Chill
-- -- Kel'Thuzad
{55802    , "Snare"},				-- Frostbolt
{55807    , "Snare"},				-- Frostbolt
------------------------
-- The Obsidian Sanctum Raid
-- -- Trash
{57835    , "Immune"},			-- Gift of Twilight
{39647    , "Other"},				-- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
{58948    , "Other"},				-- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
{57728    , "CC"},				-- Shockwave
{58947    , "CC"},				-- Shockwave
-- -- Sartharion
{56910    , "CC"},				-- Tail Lash
{58957    , "CC"},				-- Tail Lash
{58766    , "Immune"},			-- Gift of Twilight
{61632    , "Other"},				-- Berserk
{57491    , "Snare"},				-- Flame Tsunami
------------------------
-- The Eye of Eternity Raid
-- -- Malygos
{57108    , "Immune"},			-- Flame Shield (not immune, damage taken decreased by 80%)
{55853    , "Root"},				-- Vortex
{56263    , "Root"},				-- Vortex
{56264    , "Root"},				-- Vortex
{56265    , "Root"},				-- Vortex
{56266    , "Root"},				-- Vortex
{61071    , "Root"},				-- Vortex
{61072    , "Root"},				-- Vortex
{61073    , "Root"},				-- Vortex
{61074    , "Root"},				-- Vortex
{61075    , "Root"},				-- Vortex
{56438    , "Other"},				-- Arcane Overload (reduces magic damage taken by 50%)
{55849    , "Other"},				-- Power Spark
{56152    , "Other"},				-- Power Spark
{57060    , "Other"},				-- Haste
{47008    , "Other"},				-- Berserk
},

------------------------
{"Ulduar Raid",
-- -- Trash
{64010    , "CC"},				-- Nondescript
{64013    , "CC"},				-- Nondescript
{64781    , "CC"},				-- Charged Leap
{64819    , "CC"},				-- Devastating Leap
{64942    , "CC"},				-- Devastating Leap
{64649    , "CC"},				-- Freezing Breath
{62310    , "CC"},				-- Impale
{62928    , "CC"},				-- Impale
{63713    , "CC"},				-- Dominate Mind
{64918    , "CC"},				-- Electro Shock
{64971    , "CC"},				-- Electro Shock
{64647    , "CC"},				-- Snow Blindness
{64654    , "CC"},				-- Snow Blindness
{65078    , "CC"},				-- Compacted
{65105    , "CC"},				-- Compacted
{64697    , "Silence"},			-- Earthquake
{64663    , "Silence"},			-- Arcane Burst
{63710    , "Immune"},			-- Void Barrier
{63784    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{63006    , "Immune"},			-- Aggregation Pheromones (not immune, damage taken reduced by 90%)
{65070    , "Immune"},			-- Defense Matrix (not immune, damage taken reduced by 90%)
{64903    , "Root"},				-- Fuse Lightning
{64970    , "Root"},				-- Fuse Lightning
{64877    , "Root"},				-- Harden Fists
{63912    , "Root"},				-- Frost Nova
{63272    , "Other"},				-- Hurricane (slow attacks and spells by 67%)
{63557    , "Other"},				-- Hurricane (slow attacks and spells by 67%)
{64644    , "Other"},				-- Shield of the Winter Revenant (damage taken from AoE attacks reduced by 90%)
{63136    , "Other"},				-- Winter's Embrace
{63564    , "Other"},				-- Winter's Embrace
{63539    , "Other"},				-- Separation Anxiety
{63630    , "Other"},				-- Vengeful Surge
{62845    , "Snare"},				-- Hamstring
{63913    , "Snare"},				-- Frostbolt
{64645    , "Snare"},				-- Cone of Cold
{64655    , "Snare"},				-- Cone of Cold
{62287    , "Snare"},				-- Tar
-- -- Flame Leviathan
{62297    , "CC"},				-- Hodir's Fury
{62475    , "CC"},				-- Systems Shutdown
-- -- Ignis the Furnace Master
{62717    , "CC"},				-- Slag Pot
{65722    , "CC"},				-- Slag Pot
{63477    , "CC"},				-- Slag Pot
{65720    , "CC"},				-- Slag Pot
{65723    , "CC"},				-- Slag Pot
{62382    , "CC"},				-- Brittle
-- -- Razorscale
{62794    , "CC"},				-- Stun Self
{64774    , "CC"},				-- Fused Armor
-- -- XT-002 Deconstructor
{63849    , "Other"},				-- Exposed Heart
{62775    , "Snare"},				-- Tympanic Tantrum
-- -- Assembly of Iron
{61878    , "CC"},				-- Overload
{63480    , "CC"},				-- Overload
--{64320    , "Other"},				-- Rune of Power
{63489    , "Other"},				-- Shield of Runes
{62274    , "Other"},				-- Shield of Runes
{63967    , "Other"},				-- Shield of Runes
{62277    , "Other"},				-- Shield of Runes
{61888    , "Other"},				-- Overwhelming Power
{64637    , "Other"},				-- Overwhelming Power
-- -- Kologarn
{64238    , "Other"},				-- Berserk
{62056    , "CC"},				-- Stone Grip
{63985    , "CC"},				-- Stone Grip
{64290    , "CC"},				-- Stone Grip
{64292    , "CC"},				-- Stone Grip
-- -- Auriaya
{64386    , "CC"},				-- Terrifying Screech
{64478    , "CC"},				-- Feral Pounce
{64669    , "CC"},				-- Feral Pounce
-- -- Freya
{62532    , "CC"},				-- Conservator's Grip
{62467    , "CC"},				-- Drained of Power
{62283    , "Root"},				-- Iron Roots
{62438    , "Root"},				-- Iron Roots
{62861    , "Root"},				-- Iron Roots
{62930    , "Root"},				-- Iron Roots
-- -- Hodir
{61968    , "CC"},				-- Flash Freeze
{61969    , "CC"},				-- Flash Freeze
{61170    , "CC"},				-- Flash Freeze
{61990    , "CC"},				-- Flash Freeze
{62469    , "Root"},				-- Freeze
-- -- Mimiron
{64436    , "CC"},				-- Magnetic Core
{64616    , "Silence"},			-- Deafening Siren
{64668    , "Root"},				-- Magnetic Field
{64570    , "Other"},				-- Flame Suppressant (casting speed slowed by 50%)
{65192    , "Other"},				-- Flame Suppressant (casting speed slowed by 50%)
-- -- Thorim
{62241    , "CC"},				-- Paralytic Field
{63540    , "CC"},				-- Paralytic Field
{62042    , "CC"},				-- Stormhammer
{62332    , "CC"},				-- Shield Smash
{62420    , "CC"},				-- Shield Smash
{64151    , "CC"},				-- Whirling Trip
{62316    , "CC"},				-- Sweep
{62417    , "CC"},				-- Sweep
{62276    , "Immune"},			-- Sheath of Lightning (not immune, damage taken reduced by 99%)
{62338    , "Immune"},			-- Runic Barrier (not immune, damage taken reduced by 50%)
{62321    , "Immune"},			-- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
{62529    , "Immune"},			-- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
{62470    , "Other"},				-- Deafening Thunder (spell casting times increased by 75%)
{62555    , "Other"},				-- Berserk
{62560    , "Other"},				-- Berserk
{62526    , "Root"},				-- Rune Detonation
{62605    , "Root"},				-- Frost Nova
{62576    , "Snare"},				-- Blizzard
{62602    , "Snare"},				-- Blizzard
{62601    , "Snare"},				-- Frostbolt
{62580    , "Snare"},				-- Frostbolt Volley
{62604    , "Snare"},				-- Frostbolt Volley
-- -- General Vezax
{63364    , "Immune"},			-- Saronite Barrier (not immune, damage taken reduced by 99%)
{63276    , "Other"},				-- Mark of the Faceless
{62662    , "Snare"},				-- Surge of Darkness
-- -- Yogg-Saron
{64189    , "CC"},				-- Deafening Roar
{64173    , "CC"},				-- Shattered Illusion
{64155    , "CC"},				-- Black Plague
{63830    , "CC"},				-- Malady of the Mind
{63881    , "CC"},				-- Malady of the Mind
{63042    , "CC"},				-- Dominate Mind
{63120    , "CC"},				-- Insane
{63894    , "Immune"},			-- Shadowy Barrier
{64775    , "Immune"},			-- Shadowy Barrier
{64175    , "Immune"},			-- Flash Freeze
{64156    , "Snare"},				-- Apathy
},
------------------------
{"Trial of the Crusader Raid",
-- -- Northrend Beasts
{66407    , "CC"},				-- Head Crack
{66689    , "CC"},				-- Arctic Breath
{72848    , "CC"},				-- Arctic Breath
{66770    , "CC"},				-- Ferocious Butt
{66683    , "CC"},				-- Massive Crash
{66758    , "CC"},				-- Staggered Daze
{66830    , "CC"},				-- Paralysis
{66759    , "Other"},				-- Frothing Rage
{66823    , "Snare"},				-- Paralytic Toxin
-- -- Lord Jaraxxus
{66237    , "CC"},				-- Incinerate Flesh (reduces damage dealt by 50%)
{66283    , "CC"},				-- Spinning Pain Spike (!)
{66334    , "Other"},				-- Mistress' Kiss
{66336    , "Other"},				-- Mistress' Kiss
-- -- Faction Champions
{65930    , "CC"},				-- Intimidating Shout
{65931    , "CC"},				-- Intimidating Shout
{65929    , "CC"},				-- Charge Stun
{65809    , "CC"},				-- Fear
{65820    , "CC"},				-- Death Coil
{66054    , "CC"},				-- Hex
{65960    , "CC"},				-- Blind
{65545    , "CC"},				-- Psychic Horror
{65543    , "CC"},				-- Psychic Scream
{66008    , "CC"},				-- Repentance
{66007    , "CC"},				-- Hammer of Justice
{66613    , "CC"},				-- Hammer of Justice
{65801    , "CC"},				-- Polymorph
{65877    , "CC"},				-- Wyvern Sting
{65859    , "CC"},				-- Cyclone
{65935    , "Disarm"},			-- Disarm
{65542    , "Silence"},			-- Silence
{65813    , "Silence"},			-- Unstable Affliction
{66018    , "Silence"},			-- Strangulate
{65857    , "Root"},				-- Entangling Roots
{66070    , "Root"},				-- Entangling Roots (Nature's Grasp)
{66010    , "Immune"},			-- Divine Shield
{65871    , "Immune"},			-- Deterrence
{66023    , "Immune"},			-- Icebound Fortitude (not immune, damage taken reduced by 45%)
{65544    , "Immune"},			-- Dispersion (not immune, damage taken reduced by 90%)
{65947    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{66009    , "Immune"},	-- Hand of Protection
{65961    , "Immune"},		-- Cloak of Shadows
{66071    , "Other"},				-- Nature's Grasp
{65883    , "Other"},				-- Aimed Shot (healing effects reduced by 50%)
{65926    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{65962    , "Other"},				-- Wound Poison (healing effects reduced by 50%)
{66011    , "Other"},				-- Avenging Wrath
{65932    , "Other"},				-- Retaliation
--{65983    , "Other"},				-- Heroism
--{65980    , "Other"},				-- Bloodlust
{66020    , "Snare"},				-- Chains of Ice
{66207    , "Snare"},				-- Wing Clip
{65488    , "Snare"},				-- Mind Flay
{65815    , "Snare"},				-- Curse of Exhaustion
{65807    , "Snare"},				-- Frostbolt
-- -- Twin Val'kyr
{65724    , "Other"},				-- Empowered Darkness
{65748    , "Other"},				-- Empowered Light
{65874    , "Other"},				-- Shield of Darkness
{65858    , "Other"},				-- Shield of Lights
-- -- Anub'arak
{66012    , "CC"},				-- Freezing Slash
{66193    , "Snare"},				-- Permafrost
},
------------------------
{"Icecrown Citadel Raid",
-- -- Trash
{71784    , "CC"},				-- Hammer of Betrayal
{71785    , "CC"},				-- Conflagration
{71592    , "CC"},				-- Fel Iron Bomb
{71787    , "CC"},				-- Fel Iron Bomb
{70410    , "CC"},				-- Polymorph: Spider
{70645    , "CC"},				-- Chains of Shadow
{70432    , "CC"},				-- Blood Sap
{71010    , "CC"},				-- Web Wrap
{71330    , "CC"},				-- Ice Tomb
{69903    , "CC"},				-- Shield Slam
{71123    , "CC"},				-- Decimate
{71163    , "CC"},				-- Devour Humanoid
{71298    , "CC"},				-- Banish
{71443    , "CC"},				-- Impaling Spear
{71847    , "CC"},				-- Critter-Killer Attack
{71955    , "CC"},				-- Focused Attacks
{70781    , "CC"},				-- Light's Hammer Teleport
{70856    , "CC"},				-- Oratory of the Damned Teleport
{70857    , "CC"},				-- Rampart of Skulls Teleport
{70858    , "CC"},				-- Deathbringer's Rise Teleport
{70859    , "CC"},				-- Upper Spire Teleport
{70861    , "CC"},				-- Sindragosa's Lair Teleport
{70860    , "CC"},				-- Frozen Throne Teleport
{72106    , "Disarm"},			-- Polymorph: Spider
{71325    , "Disarm"},			-- Frostblade
{70714    , "Immune"},			-- Icebound Armor
{71550    , "Immune"},			-- Divine Shield
{71463    , "Immune"},			-- Aether Shield
{69910    , "Immune"},			-- Pain Suppression (not immune, damage taken reduced by 40%)
{69634    , "Immune"},			-- Taste of Blood (not immune, damage taken reduced by 50%)
{72065    , "Immune"},	-- Shroud of Protection
{72066    , "Immune"},		-- Shroud of Spell Warding
{69901    , "Immune"},		-- Spell Reflect
{70299    , "Root"},				-- Siphon Essence
{70431    , "Root"},				-- Shadowstep
{71320    , "Root"},				-- Frost Nova
{70980    , "Root"},				-- Web Wrap
{71327    , "Root"},				-- Web
{71647    , "Root"},				-- Ice Trap
{69483    , "Other"},				-- Dark Reckoning
{71552    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{70711    , "Other"},				-- Empowered Blood
{69871    , "Other"},				-- Plague Stream
{70407    , "Snare"},				-- Blast Wave
{69405    , "Snare"},				-- Consuming Shadows
{71318    , "Snare"},				-- Frostbolt
{61747    , "Snare"},				-- Frostbolt
{69869    , "Snare"},				-- Frostfire Bolt
{69927    , "Snare"},				-- Avenger's Shield
{70536    , "Snare"},				-- Spirit Alarm
{70545    , "Snare"},				-- Spirit Alarm
{70546    , "Snare"},				-- Spirit Alarm
{70547    , "Snare"},				-- Spirit Alarm
{70739    , "Snare"},				-- Geist Alarm
{70740    , "Snare"},				-- Geist Alarm
-- -- Lord Marrowgar
{69065    , "CC"},				-- Impaled
-- -- Lady Deathwhisper
{71289    , "CC"},				-- Dominate Mind
{70768    , "Immune"},		-- Shroud of the Occult (reflects harmful spells)
{71234    , "Immune"},		-- Adherent's Determination (not immune, magic damage taken reduced by 99%)
{71235    , "Immune"},	-- Adherent's Determination (not immune, physical damage taken reduced by 99%)
{71237    , "Other"},				-- Curse of Torpor (ability cooldowns increased by 15 seconds)
{70674    , "Other"},				-- Vampiric Might
{71420    , "Snare"},				-- Frostbolt
-- -- Gunship Battle
{69705    , "CC"},				-- Below Zero
{69651    , "Other"},				-- Wounding Strike (healing effects reduced by 40%)
-- -- Deathbringer Saurfang
{70572    , "CC"},				-- Grip of Agony
{72771    , "Other"},				-- Scent of Blood (physical damage done increased by 300%)
{72769    , "Snare"},				-- Scent of Blood
-- -- Festergut
{72297    , "CC"},				-- Malleable Goo (casting and attack speed reduced by 250%)
{69240    , "CC"},				-- Vile Gas
{69248    , "CC"},				-- Vile Gas
-- -- Rotface
{72272    , "CC"},				-- Vile Gas	(!)
{72274    , "CC"},				-- Vile Gas
{69244    , "Root"},				-- Vile Gas
{72276    , "Root"},				-- Vile Gas
{69674    , "Other"},				-- Mutated Infection (healing received reduced by 75%/-50%)
{69778    , "Snare"},				-- Sticky Ooze
{69789    , "Snare"},				-- Ooze Flood
-- -- Professor Putricide
{70853    , "CC"},				-- Malleable Goo (casting and attack speed reduced by 250%)
{71615    , "CC"},				-- Tear Gas
{71618    , "CC"},				-- Tear Gas
{71278    , "CC"},				-- Choking Gas (reduces chance to hit by 75%/100%)
{71279    , "CC"},				-- Choking Gas Explosion (reduces chance to hit by 75%/100%)
{70447    , "Root"},				-- Volatile Ooze Adhesive
{70539    , "Snare"},				-- Regurgitated Ooze
-- -- Blood Prince Council
{71807    , "Snare"},				-- Glittering Sparks
-- -- Blood-Queen Lana'thel
{70923    , "CC"},				-- Uncontrollable Frenzy
{73070    , "CC"},				-- Incite Terror
-- -- Valithria Dreamwalker
--{70904    , "CC"},				-- Corruption
{70588    , "Other"},				-- Suppression (healing taken reduced)
{70759    , "Snare"},				-- Frostbolt Volley
-- -- Sindragosa
{70157    , "CC"},				-- Ice Tomb
-- -- The Lich King
{71614    , "CC"},				-- Ice Lock
{73654    , "CC"},				-- Harvest Souls
{69242    , "Silence"},			-- Soul Shriek
{72143    , "Other"},				-- Enrage
{72679    , "Other"},				-- Harvested Soul (increases all damage dealt by 200%/500%)
{73028    , "Other"},				-- Harvested Soul (increases all damage dealt by 200%/500%)
},
------------------------
{"The Ruby Sanctum Raid",
-- -- Trash
{74509    , "CC"},				-- Repelling Wave
{74384    , "CC"},				-- Intimidating Roar
{75417    , "CC"},				-- Shockwave
{74456    , "CC"},				-- Conflagration
{78722    , "Other"},				-- Enrage
{75413    , "Snare"},				-- Flame Wave
-- -- Halion
{74531    , "CC"},				-- Tail Lash
{74834    , "Immune"},			-- Corporeality (not immune, damage taken reduced by 50%, damage dealt reduced by 30%)
{74835    , "Immune"},			-- Corporeality (not immune, damage taken reduced by 80%, damage dealt reduced by 50%)
{74836    , "Immune"},			-- Corporeality (damage taken reduced by 100%, damage dealt reduced by 70%)
{74830    , "Other"},				-- Corporeality (damage taken increased by 200%, damage dealt increased by 100%)
{74831    , "Other"},				-- Corporeality (damage taken increased by 400%, damage dealt increased by 200%)
},
------------------------
-- WotLK Dungeons
{"The Culling of Stratholme",
{52696    , "CC"},				-- Constricting Chains
{58823    , "CC"},				-- Constricting Chains
{52711    , "CC"},				-- Steal Flesh (damage dealt decreased by 75%)
{58848    , "CC"},				-- Time Stop
{52721    , "CC"},				-- Sleep
{58849    , "CC"},				-- Sleep
{60451    , "CC"},				-- Corruption of Time
{52634    , "Immune"},			-- Void Shield (not immune, reduces damage taken by 50%)
{58813    , "Immune"},			-- Void Shield (not immune, reduces damage taken by 75%)
{52317    , "Immune"},	-- Defend (not immune, reduces physical damage taken by 50%)
{52491    , "Root"},				-- Web Explosion
{52766    , "Snare"},				-- Time Warp
{52657    , "Snare"},				-- Temporal Vortex
{58816    , "Snare"},				-- Temporal Vortex
{52498    , "Snare"},				-- Cripple
{20828    , "Snare"},				-- Cone of Cold
},
{"The Violet Hold",
{52719    , "CC"},				-- Concussion Blow
{58526    , "CC"},				-- Azure Bindings
{58537    , "CC"},				-- Polymorph
{58534    , "CC"},				-- Deep Freeze
{59820    , "Immune"},			-- Drained
{54306    , "Immune"},			-- Protective Bubble (not immune, reduces damage taken by 99%)
{60158    , "Immune"},		-- Magic Reflection
{58458    , "Root"},				-- Frost Nova
{59253    , "Root"},				-- Frost Nova
{54462    , "Snare"},				-- Howling Screech
{58693    , "Snare"},				-- Blizzard
{59369    , "Snare"},				-- Blizzard
{58463    , "Snare"},				-- Cone of Cold
{58532    , "Snare"},				-- Frostbolt Volley
{61594    , "Snare"},				-- Frostbolt Volley
{58457    , "Snare"},				-- Frostbolt
{58535    , "Snare"},				-- Frostbolt
{59251    , "Snare"},				-- Frostbolt
{61590    , "Snare"},				-- Frostbolt
{20822    , "Snare"},				-- Frostbolt
},
{"Azjol-Nerub",
{52087    , "CC"},				-- Web Wrap
{52524    , "CC"},				-- Blinding Webs
{59365    , "CC"},				-- Blinding Webs
{53472    , "CC"},				-- Pound
{59433    , "CC"},				-- Pound
{52086    , "Root"},				-- Web Wrap
{53322    , "Root"},				-- Crushing Webs
{59347    , "Root"},				-- Crushing Webs
{52586    , "Snare"},				-- Mind Flay
{59367    , "Snare"},				-- Mind Flay
{52592    , "Snare"},				-- Curse of Fatigue
{59368    , "Snare"},				-- Curse of Fatigue
},
{"Ahn'kahet: The Old Kingdom",
{55959    , "CC"},				-- Embrace of the Vampyr
{59513    , "CC"},				-- Embrace of the Vampyr
{57055    , "CC"},				-- Mini (damage dealt reduced by 75%)
{61491    , "CC"},				-- Intercept
{56153    , "Immune"},			-- Guardian Aura
{55964    , "Immune"},			-- Vanish
{57095    , "Root"},				-- Entangling Roots
{56632    , "Root"},				-- Tangled Webs
{56219    , "Other"},				-- Gift of the Herald (damage dealt increased by 200%)
{57789    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{59995    , "Root"},				-- Frost Nova
{61462    , "Root"},				-- Frost Nova
{57629    , "Root"},				-- Frost Nova
{57941    , "Snare"},				-- Mind Flay
{59974    , "Snare"},				-- Mind Flay
{57799    , "Snare"},				-- Avenger's Shield
{59999    , "Snare"},				-- Avenger's Shield
{57825    , "Snare"},				-- Frostbolt
{61461    , "Snare"},				-- Frostbolt
{57779    , "Snare"},				-- Mind Flay
{60006    , "Snare"},				-- Mind Flay
},
{"Utgarde Keep",
{42672    , "CC"},				-- Frost Tomb
{48400    , "CC"},				-- Frost Tomb
{43651    , "CC"},				-- Charge
{35570    , "CC"},				-- Charge
{59611    , "CC"},				-- Charge
{42723    , "CC"},				-- Dark Smash
{59709    , "CC"},				-- Dark Smash
{43936    , "CC"},				-- Knockdown Spin
{42972    , "CC"},				-- Blind
{37578    , "CC"},				-- Debilitating Strike (physical damage done reduced by 75%)
{42740    , "Immune"},			-- Njord's Rune of Protection (not immune, big absorb)
{59616    , "Immune"},			-- Njord's Rune of Protection (not immune, big absorb)
{43650    , "Other"},				-- Debilitate
{59577    , "Other"},				-- Debilitate
},
{"Utgarde Pinnacle",
{48267    , "CC"},				-- Ritual Preparation
{48278    , "CC"},				-- Paralyze
{50234    , "CC"},				-- Crush
{59330    , "CC"},				-- Crush
{51750    , "CC"},				-- Screams of the Dead
{48131    , "CC"},				-- Stomp
{48144    , "CC"},				-- Terrifying Roar
{49106    , "CC"},				-- Terrify
{49170    , "CC"},				-- Lycanthropy
{49172    , "Other"},				-- Wolf Spirit
{49173    , "Other"},				-- Wolf Spirit
{48703    , "CC"},				-- Fervor
{48702    , "Other"},				-- Fervor
{48871    , "Other"},				-- Aimed Shot (decreases healing received by 50%)
{59243    , "Other"},				-- Aimed Shot (decreases healing received by 50%)
{49092    , "Root"},				-- Net
{48639    , "Snare"},				-- Hamstring
},
{"The Nexus",
{47736    , "CC"},				-- Time Stop
{47731    , "CC"},				-- Critter
{47772    , "CC"},				-- Ice Nova
{56935    , "CC"},				-- Ice Nova
{60067    , "CC"},				-- Charge
{47700    , "CC"},				-- Crystal Freeze
{55041    , "CC"},				-- Freezing Trap Effect
{47781    , "CC"},				-- Spellbreaker (damage from magical spells and effects reduced by 75%)
{47854    , "CC"},				-- Frozen Prison
{47543    , "CC"},				-- Frozen Prison
{47779    , "Silence"},			-- Arcane Torrent
{56777    , "Silence"},			-- Silence
{47748    , "Immune"},			-- Rift Shield
{48082    , "Immune"},			-- Seed Pod
{47981    , "Immune"},		-- Spell Reflection
{47698    , "Root"},				-- Crystal Chains
{50997    , "Root"},				-- Crystal Chains
{57050    , "Root"},				-- Crystal Chains
{48179    , "Root"},				-- Crystallize
{61556    , "Root"},				-- Tangle
{48053    , "Snare"},				-- Ensnare
{56775    , "Snare"},				-- Frostbolt
{56837    , "Snare"},				-- Frostbolt
{12737    , "Snare"},				-- Frostbolt
},
{"The Oculus",
{49838    , "CC"},				-- Stop Time
{50731    , "CC"},				-- Mace Smash
{50053    , "Immune"},			-- Centrifuge Shield
{53813    , "Immune"},			-- Arcane Shield
{50240    , "Immune"},			-- Evasive Maneuvers
{51162    , "Immune"},		-- Planar Shift
{50690    , "Root"},				-- Immobilizing Field
{59260    , "Root"},				-- Hooked Net
{51170    , "Other"},				-- Enraged Assault
{50253    , "Other"},				-- Martyr (harmful spells redirected to you)
{59370    , "Snare"},				-- Thundering Stomp
{49549    , "Snare"},				-- Ice Beam
{59211    , "Snare"},				-- Ice Beam
{59217    , "Snare"},				-- Thunderclap
{59261    , "Snare"},				-- Water Tomb
{50721    , "Snare"},				-- Frostbolt
{59280    , "Snare"},				-- Frostbolt
},
{"Drak Tharon Keep",
{49356    , "CC"},				-- Decay Flesh
{53463    , "CC"},				-- Return Flesh
{51240    , "CC"},				-- Fear
{49704    , "Root"},				-- Encasing Webs
{49711    , "Root"},				-- Hooked Net
{49721    , "Silence"},			-- Deafening Roar
{59010    , "Silence"},			-- Deafening Roar
{47346    , "Snare"},				-- Arcane Field
{49037    , "Snare"},				-- Frostbolt
{50378    , "Snare"},				-- Frostbolt
{59017    , "Snare"},				-- Frostbolt
{59855    , "Snare"},				-- Frostbolt
{50379    , "Snare"},				-- Cripple
},
{"Gundrak",
{55142    , "CC"},				-- Ground Tremor
{55101    , "CC"},				-- Quake
{55636    , "CC"},				-- Shockwave
{58977    , "CC"},				-- Shockwave
{55099    , "CC"},				-- Snake Wrap
{61475    , "CC"},				-- Snake Wrap
{55126    , "CC"},				-- Snake Wrap
{61476    , "CC"},				-- Snake Wrap
{54956    , "CC"},				-- Impaling Charge
{59827    , "CC"},				-- Impaling Charge
{55663    , "Silence"},			-- Deafening Roar
{58992    , "Silence"},			-- Deafening Roar
{55633    , "Root"},				-- Body of Stone
{54716    , "Other"},				-- Mortal Strikes (healing effects reduced by 50%)
{59455    , "Other"},				-- Mortal Strikes (healing effects reduced by 75%)
{55816    , "Other"},				-- Eck Berserk
{40546    , "Other"},				-- Retaliation
{61362    , "Snare"},				-- Blast Wave
{55250    , "Snare"},				-- Whirling Slash
{59824    , "Snare"},				-- Whirling Slash
{58975    , "Snare"},				-- Thunderclap
},
{"Halls of Stone",
{50812    , "CC"},				-- Stoned
{50760    , "CC"},				-- Shock of Sorrow
{59726    , "CC"},				-- Shock of Sorrow
{59865    , "CC"},				-- Ground Smash
{51503    , "CC"},				-- Domination
{51842    , "CC"},				-- Charge
{59040    , "CC"},				-- Charge
{51491    , "CC"},				-- Unrelenting Strike
{59039    , "CC"},				-- Unrelenting Strike
{59868    , "Snare"},				-- Dark Matter
{50836    , "Snare"},				-- Petrifying Grip
},
{"Halls of Lightning",
{53045    , "CC"},				-- Sleep
{59165    , "CC"},				-- Sleep
{59142    , "CC"},				-- Shield Slam
{60236    , "CC"},				-- Cyclone
{36096    , "Immune"},		-- Spell Reflection
{53069    , "Root"},				-- Runic Focus
{59153    , "Root"},				-- Runic Focus
{61579    , "Root"},				-- Runic Focus
{61596    , "Root"},				-- Runic Focus
{52883    , "Root"},				-- Counterattack
{59181    , "Other"},				-- Deflection (parry chance increased by 40%)
{52773    , "Snare"},				-- Hammer Blow
{23600    , "Snare"},				-- Piercing Howl
{23113    , "Snare"},				-- Blast Wave
},
{"Trial of the Champion",
{67745    , "CC"},				-- Death's Respite
{66940    , "CC"},				-- Hammer of Justice
{66862    , "CC"},				-- Radiance
{66547    , "CC"},				-- Confess
{66546    , "CC"},				-- Holy Nova
{65918    , "CC"},				-- Stunned
{67867    , "CC"},				-- Trampled
{67868    , "CC"},				-- Trampled
{67255    , "CC"},				-- Final Meditation (movement, attack, and casting speeds reduced by 70%)
{67229    , "CC"},				-- Mind Control
{66043    , "CC"},				-- Polymorph
{66619    , "CC"},				-- Shadows of the Past (attack and casting speeds reduced by 90%)
{66552    , "CC"},				-- Waking Nightmare
{67541    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{66515    , "Immune"},			-- Reflective Shield
{67251    , "Immune"},			-- Divine Shield
{67534    , "Other"},				-- Hex of Mending (direct heals received will heal all nearby enemies)
{67542    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{66045    , "Other"},				-- Haste
{67781    , "Snare"},				-- Desecration
{66044    , "Snare"},				-- Blast Wave
},
{"The Forge of Souls",
{68950    , "CC"},				-- Fear
{68848    , "CC"},				-- Knockdown Stun
{69133    , "CC"},				-- Lethargy
{69056    , "Immune"},		-- Shroud of Runes
{69060    , "Root"},				-- Frost Nova
{68839    , "Other"},				-- Corrupt Soul
{69131    , "Other"},				-- Soul Sickness
{69633    , "Other"},				-- Veil of Shadow
{68921    , "Snare"},				-- Soulstorm
},
{"Pit of Saron",
{68771    , "CC"},				-- Thundering Stomp
{70380    , "CC"},				-- Deep Freeze
{69245    , "CC"},				-- Hoarfrost
{69503    , "CC"},				-- Devour Humanoid
{70302    , "CC"},				-- Blinding Dirt
{69572    , "CC"},				-- Shovelled!
{70639    , "CC"},				-- Call of Sylvanas
{70291    , "Disarm"},			-- Frostblade
{69575    , "Immune"},			-- Stoneform (not immune, damage taken reduced by 90%)
{70130    , "Root"},				-- Empowered Blizzard
{69580    , "Other"},				-- Shield Block (chance to block increased by 100%)
{69029    , "Other"},				-- Pursuit Confusion
{69167    , "Other"},				-- Unholy Power
{69172    , "Other"},				-- Overlord's Brand
{70381    , "Snare"},				-- Deep Freeze
{69238    , "Snare"},				-- Icy Blast
{71380    , "Snare"},				-- Icy Blast
{69573    , "Snare"},				-- Frostbolt
{69413    , "Silence"},			-- Strangulating
{70569    , "Silence"},			-- Strangulating
{70616    , "Snare"},				-- Frostfire Bolt
{51779    , "Snare"},				-- Frostfire Bolt
{34779    , "Root"},				-- Freezing Circle
{22645    , "Root"},				-- Frost Nova
{22746    , "Snare"},				-- Cone of Cold
},
{"Halls of Reflection",
{72435    , "CC"},				-- Defiling Horror
{72428    , "CC"},				-- Despair Stricken
{72321    , "CC"},				-- Cower in Fear
{70194    , "CC"},				-- Dark Binding
{69708    , "CC"},				-- Ice Prison
{72343    , "CC"},				-- Hallucination
{72335    , "CC"},				-- Kidney Shot
{72268    , "CC"},				-- Ice Shot
{69866    , "CC"},				-- Harvest Soul
{72171    , "Root"},				-- Chains of Ice
{69787    , "Immune"},			-- Ice Barrier (not immune, absorbs a lot of damage)
{70188    , "Immune"},			-- Cloak of Darkness
{69780    , "Snare"},				-- Remorseless Winter
{72166    , "Snare"},				-- Frostbolt
},
  ------------------------
  ---- PVE TBC
  ------------------------
{"Karazhan Raid",
  -- -- Trash
  {18812  , "CC"},				-- Knockdown
  {29684  , "CC"},				-- Shield Slam
  {29679  , "CC"},				-- Bad Poetry
  {29676  , "CC"},				-- Rolling Pin
  {29490  , "CC"},				-- Seduction
  {29300  , "CC"},				-- Sonic Blast
  {29321  , "CC"},				-- Fear
  {29546  , "CC"},				-- Oath of Fealty
  {29670  , "CC"},				-- Ice Tomb
  {29690  , "CC"},				-- Drunken Skull Crack
  {37498  , "CC"},				-- Stomp (physical damage done reduced by 50%)
  {41580  , "Root"},				-- Net
  {29505  , "Silence"},			-- Banshee Shriek
  {30013  , "Disarm"},			-- Disarm
  --{30019  , "CC"},				-- Control Piece
  --{39331  , "Silence"},			-- Game In Session

  -- -- Servant Quarters
  {29896  , "CC"},				-- Hyakiss' Web
  {29904  , "Silence"},			-- Sonic Burst
  -- -- Attumen the Huntsman
  {29711  , "CC"},				-- Knockdown
  {29833  , "CC"},				-- Intangible Presence (chance to hit with spells and melee attacks reduced by 50%)
  -- -- Moroes
  {29425  , "CC"},				-- Gouge
  {34694  , "CC"},				-- Blind
  -- -- Maiden of Virtue
  {29511  , "CC"},				-- Repentance
  {29512  , "Silence"},			-- Holy Ground
  -- -- Opera Event
  {31046  , "CC"},				-- Brain Bash
  {30889  , "CC"},				-- Powerful Attraction
  {30761  , "CC"},				-- Wide Swipe
  {31013  , "CC"},				-- Frightened Scream
  {30752  , "CC"},				-- Terrifying Howl
  {31075  , "CC"},				-- Burning Straw
  {30753  , "CC"},				-- Red Riding Hood
  {30756  , "CC"},				-- Little Red Riding Hood
  {31015  , "CC"},				-- Annoying Yipping
  {31069  , "Silence"},			-- Brain Wipe
  -- -- The Curator
  {30254  , "CC"},				-- Evocation
  -- -- Terestian Illhoof
  {30115  , "CC"},				-- Sacrifice
  -- -- Shade of Aran
  {29964  , "CC"},				-- Dragon's Breath
  {29963  , "CC"},				-- Mass Polymorph
  {29991  , "Root"},				-- Chains of Ice

  -- -- Nightbane
  {36922  , "CC"},				-- Bellowing Roar
  {30130  , "CC"},				-- Distracting Ash (chance to hit with attacks}, spells and abilities reduced by 30%)
  -- -- Prince Malchezaar
},
  ------------------------
{"Gruul's Lair Raid",
  -- -- Trash
  {33709  , "CC"},				-- Charge
  -- -- High King Maulgar & Council
  {33173  , "CC"},				-- Greater Polymorph
  {33130  , "CC"},				-- Death Coil
  {33175  , "Disarm"},			-- Arcane Shock
  -- -- Gruul the Dragonkiller
  {33652  , "CC"},				-- Stoned
  {36297  , "Silence"},			-- Reverberation
  ------------------------
  -- -- Magtheridon’s Lair Raid
  -- -- Trash
  {34437  , "CC"},				-- Death Coil
  --{31117  , "Silence"},			-- Unstable Affliction
  -- -- Magtheridon
  {30530  , "CC"},				-- Fear
  {30168  , "CC"},				-- Shadow Cage
  {30205  , "CC"},				-- Shadow Cage
},
  ------------------------
{"Serpentshrine Cavern Raid",
  -- -- Trash
  {38945  , "CC"},				-- Frightening Shout
  {38946  , "CC"},				-- Frightening Shout
  {38626  , "CC"},				-- Domination
  {39002  , "CC"},				-- Spore Quake Knockdown
  {38661  , "Root"},				-- Net
  {39035  , "Root"},				-- Frost Nova
  {39063  , "Root"},				-- Frost Nova
  {38634  , "Silence"},			-- Arcane Lightning
  {38491  , "Silence"},			-- Silence

  -- -- Hydross the Unstable
  {38246  , "CC"},				-- Vile Sludge (damage and healing dealt is reduced by 50%)
  -- -- Leotheras the Blind
  {37749  , "CC"},				-- Consuming Madness
  -- -- Fathom-Lord Karathress
  {38441  , "CC"},				-- Cataclysmic Bolt
  -- -- Morogrim Tidewalker
  {37871  , "CC"},				-- Freeze
  {37850  , "CC"},				-- Watery Grave
  {38023  , "CC"},				-- Watery Grave
  {38024  , "CC"},				-- Watery Grave
  {38025  , "CC"},				-- Watery Grave
  {38049  , "CC"},				-- Watery Grave
  -- -- Lady Vashj
  {38509  , "CC"},				-- Shock Blast
  {38511  , "CC"},				-- Persuasion
  {38258  , "CC"},				-- Panic
  {38316  , "Root"},				-- Entangle
  {38132  , "Root"},				-- Paralyze (Tainted Core item)
},
  ------------------------
{"The Eye (Tempest Keep) Raid",
  -- -- Trash
  {34937  , "CC"},				-- Powered Down
  {37122  , "CC"},				-- Domination
  {37135  , "CC"},				-- Domination
  {37118  , "CC"},				-- Shell Shock
  {39077  , "CC"},				-- Hammer of Justice
  {37160  , "Silence"},			-- Silence

  -- -- Void Reaver
  {34190  , "Silence"},			-- Arcane Orb
  -- -- Kael'thas
  {36834  , "CC"},				-- Arcane Disruption
  {37018  , "CC"},				-- Conflagration
  {44863  , "CC"},				-- Bellowing Roar
  {36797  , "CC"},				-- Mind Control
  {37029  , "CC"},				-- Remote Toy
  {36989  , "Root"},				-- Frost Nova

},
  ------------------------
{"Black Temple Raid",
  -- -- Trash
  {41345  , "CC"},				-- Infatuation
  {39645  , "CC"},				-- Shadow Inferno
  {41150  , "CC"},				-- Fear
  {39574  , "CC"},				-- Charge
  {39674  , "CC"},				-- Banish
  {40936  , "CC"},				-- War Stomp
  {41197  , "CC"},				-- Shield Bash
  {41272  , "CC"},				-- Behemoth Charge
  {41274  , "CC"},				-- Fel Stomp
  {41338  , "CC"},				-- Love Tap
  {41396  , "CC"},				-- Sleep
  {41356  , "CC"},				-- Chest Pains
  {41213  , "CC"},				-- Throw Shield
  {40864  , "CC"},				-- Throbbing Stun
  {41334  , "CC"},				-- Polymorph
  {40099  , "CC"},				-- Vile Slime (damage and healing dealt reduced by 50%)
  {40079  , "CC"},				-- Debilitating Spray (damage and healing dealt reduced by 50%)
  {39584  , "Root"},				-- Sweeping Wing Clip
  {40082  , "Root"},				-- Hooked Net
  {41086  , "Root"},				-- Ice Trap

  {41062  , "Disarm"},			-- Disarm
  {36139  , "Disarm"},			-- Disarm
  {41084  , "Silence"},			-- Silencing Shot
  {41168  , "Silence"},			-- Sonic Strike
  -- -- High Warlord Naj'entus
  {39837  , "CC"},				-- Impaling Spine
  -- -- Supremus
  -- -- Shade of Akama
  {41179  , "CC"},				-- Debilitating Strike (physical damage done reduced by 75%)
  -- -- Teron Gorefiend
  {40175  , "CC"},				-- Spirit Chains
  -- -- Gurtogg Bloodboil
  {40597  , "CC"},				-- Eject
  {40491  , "CC"},				-- Bewildering Strike
  {40569  , "Root"},				-- Fel Geyser
  {40591  , "CC"},				-- Fel Geyser
  -- -- Reliquary of the Lost
  {41426  , "CC"},				-- Spirit Shock
  -- -- Mother Shahraz
  {40823  , "Silence"},			-- Silencing Shriek
  -- -- The Illidari Council
  {41468  , "CC"},				-- Hammer of Justice
  {41479  , "CC"},				-- Vanish
  -- -- Illidan
  {40647  , "CC"},				-- Shadow Prison
  {41083  , "CC"},				-- Paralyze
  {40620  , "CC"},				-- Eyebeam
  {40695  , "CC"},				-- Caged
  {40760  , "CC"},				-- Cage Trap
  {41218  , "CC"},				-- Death
  {41220  , "CC"},				-- Death
  {41221  , "CC"},				-- Teleport Maiev
},
  ------------------------
{"Hyjal Summit Raid",
  -- -- Trash
  {31755  , "CC"},				-- War Stomp
  {31610  , "CC"},				-- Knockdown
  {31537  , "CC"},				-- Cannibalize
  {31302  , "CC"},				-- Inferno Effect
  {31651  , "CC"},				-- Banshee Curse (chance to hit reduced by 66%)
  {42201  , "Silence"},			-- Eternal Silence
  {42205  , "Silence"},			-- Residue of Eternity

  -- -- Rage Winterchill
  {31249  , "CC"},				-- Icebolt
  {31250  , "Root"},				-- Frost Nova
  -- -- Anetheron
  {31298  , "CC"},				-- Sleep
  -- -- Kaz'rogal
  {31480  , "CC"},				-- War Stomp
  -- -- Azgalor
  {31344  , "Silence"},			-- Howl of Azgalor
  -- -- Archimonde
  {31970  , "CC"},				-- Fear
  {32053  , "Silence"},			-- Soul Charge
  },
  ------------------------
  {"Zul'Aman Raid",
  -- -- Trash
  {43356  , "CC"},				-- Pounce
  {43361  , "CC"},				-- Domesticate
  {42220  , "CC"},				-- Conflagration
  {35011  , "CC"},				-- Knockdown
  {43362  , "Root"},				-- Electrified Net

  -- -- Akil'zon
  {43648  , "CC"},				-- Electrical Storm
  -- -- Nalorakk
  {42398  , "Silence"},			-- Deafening Roar
  -- -- Hex Lord Malacrass
  {43590  , "CC"},				-- Psychic Wail
  -- -- Daakara
  {43437  , "CC"},				-- Paralyzed
  },
  ------------------------
{"Sunwell Plateau Raid",
  -- -- Trash
  {46762  , "CC"},				-- Shield Slam
  {46288  , "CC"},				-- Petrify
  {46239  , "CC"},				-- Bear Down
  {46561  , "CC"},				-- Fear
  {46427  , "CC"},				-- Domination
  {46280  , "CC"},				-- Polymorph
  {46295  , "CC"},				-- Hex
  {46681  , "CC"},				-- Scatter Shot
  {45029  , "CC"},				-- Corrupting Strike
  {44872  , "CC"},				-- Frost Blast
  {45201  , "CC"},				-- Frost Blast
  {45203  , "CC"},				-- Frost Blast
  {46555  , "Root"},				-- Frost Nova

  -- -- Kalecgos & Sathrovarr
  {45066  , "CC"},				-- Self Stun
  {45002  , "CC"},				-- Wild Magic (chance to hit with melee and ranged attacks reduced by 50%)
  {45122  , "CC"},				-- Tail Lash
  -- -- Felmyst
  {46411  , "CC"},				-- Fog of Corruption
  {45717  , "CC"},				-- Fog of Corruption
  -- -- Grand Warlock Alythess & Lady Sacrolash
  {45256  , "CC"},				-- Confounding Blow
  {45342  , "CC"},				-- Conflagration
  -- -- M'uru
  {46102  , "Root"},				-- Spell Fury

  -- -- Kil'jaeden
  {37369  , "CC"},				-- Hammer of Justice
},
  ------------------------
  ------------------------
  -- TBC Dungeons
{"Hellfire Ramparts",
  {39427  , "CC"},				-- Bellowing Roar
  {30615  , "CC"},				-- Fear
  {30621  , "CC"},				-- Kidney Shot

  },
{"The Blood Furnace",
  {30923  , "CC"},				-- Domination
  {31865  , "CC"},				-- Seduction

  },
{"The Shattered Halls",
  {30500  , "CC"},				-- Death Coil
  {30741  , "CC"},				-- Death Coil
  {30584  , "CC"},				-- Fear
  {37511  , "CC"},				-- Charge
  {23601  , "CC"},				-- Scatter Shot
  {30980  , "CC"},				-- Sap
  {30986  , "CC"},				-- Cheap Shot
  },
{"The Slave Pens",
  {34984  , "CC"},				-- Psychic Horror
  {32173  , "Root"},				-- Entangling Roots
  {31983  , "Root"},				-- Earthgrab
  {32192  , "Root"},				-- Frost Nova
  },
{"The Underbog",
  {31428  , "CC"},				-- Sneeze
  {31932  , "CC"},				-- Freezing Trap Effect
  {35229  , "CC"},				-- Sporeskin (chance to hit with attacks}, spells and abilities reduced by 35%)
  {31673  , "Root"},				-- Foul Spores
  },
{"The Steamvault",
  {31718  , "CC"},				-- Enveloping Winds
  {38660  , "CC"},				-- Fear
  {35107  , "Root"},				-- Electrified Net
  },
{"Mana-Tombs",
  {32361  , "CC"},				-- Crystal Prison
  {34322  , "CC"},				-- Psychic Scream
  {33919  , "CC"},				-- Earthquake
  {34940  , "CC"},				-- Gouge
  {32365  , "Root"},				-- Frost Nova
  {34922  , "Silence"},			-- Shadows Embrace
  },
{"Auchenai Crypts",
  {32421  , "CC"},				-- Soul Scream
  {32830  , "CC"},				-- Possess
  {32859  , "Root"},				-- Falter
  {33401  , "Root"},				-- Possess
  {32346  , "CC"},				-- Stolen Soul (damage and healing done reduced by 50%)
  },
{"Sethekk Halls",
  {40305  , "CC"},				-- Power Burn
  {40184  , "CC"},				-- Paralyzing Screech
  {43309  , "CC"},				-- Polymorph
  {38245  , "CC"},				-- Polymorph
  {40321  , "CC"},				-- Cyclone of Feathers
  {35120  , "CC"},				-- Charm
  {32654  , "CC"},				-- Talon of Justice
  {32690  , "Silence"},			-- Arcane Lightning
  {38146  , "Silence"},			-- Arcane Lightning
  },
{"Shadow Labyrinth",
  {33547  , "CC"},				-- Fear
  {38791  , "CC"},				-- Banish
  {33563  , "CC"},				-- Draw Shadows
  {33684  , "CC"},				-- Incite Chaos
  {33502  , "CC"},				-- Brain Wash
  {33332  , "CC"},				-- Suppression Blast
  {33686  , "Silence"},			-- Shockwave
  {33499  , "Silence"},			-- Shape of the Beast
  },
{"Old Hillsbrad Foothills",
  {33789  , "CC"},				-- Frightening Shout
  {50733  , "CC"},				-- Scatter Shot
  {32890  , "CC"},				-- Knockout
  {32864  , "CC"},				-- Kidney Shot
  {41389  , "CC"},				-- Kidney Shot
  {50762  , "Root"},				-- Net
  {12024  , "Root"},				-- Net
  },
{"The Black Morass",
  {31422  , "CC"},				-- Time Stop
  },
{"The Mechanar",
  {35250  , "CC"},				-- Dragon's Breath
  {35326  , "CC"},				-- Hammer Punch
  {35280  , "CC"},				-- Domination
  {35049  , "CC"},				-- Pound
  {35783  , "CC"},				-- Knockdown
  {36333  , "CC"},				-- Anesthetic
  {35268  , "CC"},				-- Inferno
  {36022  , "Silence"},			-- Arcane Torrent
  {35055  , "Disarm"},			-- The Claw
  },
{"The Arcatraz",
  {36924  , "CC"},				-- Mind Rend
  {39017  , "CC"},				-- Mind Rend
  {39415  , "CC"},				-- Fear
  {37162  , "CC"},				-- Domination
  {36866  , "CC"},				-- Domination
  {39019  , "CC"},				-- Complete Domination
  {38850  , "CC"},				-- Deafening Roar
  {36887  , "CC"},				-- Deafening Roar
  {36700  , "CC"},				-- Hex
  {36840  , "CC"},				-- Polymorph
  {38896  , "CC"},				-- Polymorph
  {36634  , "CC"},				-- Emergence
  {36719  , "CC"},				-- Explode
  {38830  , "CC"},				-- Explode
  {36835  , "CC"},				-- War Stomp
  {38911  , "CC"},				-- War Stomp
  {36862  , "CC"},				-- Gouge
  {36778  , "CC"},				-- Soul Steal (physical damage done reduced by 45%)
  {35963  , "Root"},				-- Improved Wing Clip
  {36512  , "Root"},				-- Knock Away
  {36827  , "Root"},				-- Hooked Net
  {38912  , "Root"},				-- Hooked Net
  {37480  , "Root"},				-- Bind
  {38900  , "Root"},				-- Bind
  },
{"The Botanica",
  {34716  , "CC"},				-- Stomp
  {34661  , "CC"},				-- Sacrifice
  {32323  , "CC"},				-- Charge
  {34639  , "CC"},				-- Polymorph
  {34752  , "CC"},				-- Freezing Touch
  {34770  , "CC"},				-- Plant Spawn Effect
  {34801  , "CC"},				-- Sleep
  {22127  , "Root"},				-- Entangling Roots
  },
{"Magisters' Terrace",
  {47109  , "CC"},				-- Power Feedback
  {44233  , "CC"},				-- Power Feedback
  {46183  , "CC"},				-- Knockdown
  {46026  , "CC"},				-- War Stomp
  {46024  , "CC"},				-- Fel Iron Bomb
  {46184  , "CC"},				-- Fel Iron Bomb
  {44352  , "CC"},				-- Overload
  {38595  , "CC"},				-- Fear
  {44320  , "CC"},				-- Mana Rage
  {44547  , "CC"},				-- Deadly Embrace
  {44765  , "CC"},				-- Banish
  {44177  , "Root"},				-- Frost Nova
  {47168  , "Root"},				-- Improved Wing Clip
  {46182  , "Silence"},			-- Snap Kick
  },

  ------------------------
  ---- PVE CLASSIC
  ------------------------
{"Molten Core Raid",
  -- -- Trash
  {19364  , "CC"},				-- Ground Stomp
  {19369  , "CC"},				-- Ancient Despair
  {19641  , "CC"},				-- Pyroclast Barrage
  {20276  , "CC"},				-- Knockdown
  {19393  , "Silence"},			-- Soul Burn
  {19636  , "Root"},				-- Fire Blossom
  -- -- Lucifron
  {20604  , "CC"},				-- Dominate Mind
  -- -- Magmadar
  {19408  , "CC"},				-- Panic
  -- -- Gehennas
  {20277  , "CC"},				-- Fist of Ragnaros
  -- -- Garr
  -- -- Shazzrah
  -- -- Baron Geddon
  {19695  , "CC"},				-- Inferno
  {20478  , "CC"},				-- Armageddon
  -- -- Golemagg the Incinerator
  -- -- Sulfuron Harbinger
  {19780  , "CC"},				-- Hand of Ragnaros
  -- -- Majordomo Executus
  },
  ------------------------
{"Onyxia's Lair Raid",
  -- -- Onyxia
  {18431  , "CC"},				-- Bellowing Roar
  ------------------------
  -- Blackwing Lair Raid
  -- -- Trash
  {24375  , "CC"},				-- War Stomp
  {22289  , "CC"},				-- Brood Power: Green
  {22291  , "CC"},				-- Brood Power: Bronze
  {22561  , "CC"},				-- Brood Power: Green
  -- -- Razorgore the Untamed
  {19872  , "CC"},				-- Calm Dragonkin
  {23023  , "CC"},				-- Conflagration
  {15593  , "CC"},				-- War Stomp
  {16740  , "CC"},				-- War Stomp
  {28725  , "CC"},				-- War Stomp
  {14515  , "CC"},				-- Dominate Mind
  {22274  , "CC"},				-- Greater Polymorph
  -- -- Broodlord Lashlayer
  -- -- Chromaggus
  {23310  , "CC"},				-- Time Lapse
  {23312  , "CC"},				-- Time Lapse
  {23174  , "CC"},				-- Chromatic Mutation
  {23171  , "CC"},				-- Time Stop (Brood Affliction: Bronze)
  -- -- Nefarian
  {22666  , "Silence"},			-- Silence
  {22667  , "CC"},				-- Shadow Command
  {22686  , "CC"},				-- Bellowing Roar
  {22678  , "CC"},				-- Fear
  {23603  , "CC"},				-- Wild Polymorph
  {23364  , "CC"},				-- Tail Lash
  {23365  , "Disarm"},			-- Dropped Weapon
  {23414  , "Root"},				-- Paralyze
  },
  ------------------------
{"Zul'Gurub Raid",
  -- -- Trash
  {24619  , "Silence"},			-- Soul Tap
  {24048  , "CC"},				-- Whirling Trip
  {24600  , "CC"},				-- Web Spin
  {24335  , "CC"},				-- Wyvern Sting
  {24020  , "CC"},				-- Axe Flurry
  {24671  , "CC"},				-- Snap Kick
  {24333  , "CC"},				-- Ravage
  {6869   , "CC"},				-- Fall down
  {24053  , "CC"},				-- Hex
  -- -- High Priestess Jeklik
  {23918  , "Silence"},			-- Sonic Burst
  {22884  , "CC"},				-- Psychic Scream
  {22911  , "CC"},				-- Charge
  {23919  , "CC"},				-- Swoop
  {26044  , "CC"},				-- Mind Flay
  -- -- High Priestess Mar'li
  {24110  , "Silence"},			-- Enveloping Webs
  -- -- High Priest Thekal
  {21060  , "CC"},				-- Blind
  {12540  , "CC"},				-- Gouge
  {24193  , "CC"},				-- Charge
  -- -- Bloodlord Mandokir & Ohgan
  {24408  , "CC"},				-- Charge
  -- -- Gahz'ranka
  -- -- Jin'do the Hexxer
  {17172  , "CC"},				-- Hex
  {24261  , "CC"},				-- Brain Wash
  -- -- Edge of Madness: Gri'lek}, Hazza'rah}, Renataki}, Wushoolay
  {24648  , "Root"},				-- Entangling Roots
  {24664  , "CC"},				-- Sleep
  -- -- Hakkar
  {24687  , "Silence"},			-- Aspect of Jeklik
  {24686  , "CC"},				-- Aspect of Mar'li
  {24690  , "CC"},				-- Aspect of Arlokk
  {24327  , "CC"},				-- Cause Insanity
  {24178  , "CC"},				-- Will of Hakkar
  {24322  , "CC"},				-- Blood Siphon
  {24323  , "CC"},				-- Blood Siphon
  {24324  , "CC"},				-- Blood Siphon
  },
  ------------------------
{"Ruins of Ahn'Qiraj Raid",
  -- -- Trash
  {25371  , "CC"},				-- Consume
  {26196  , "CC"},				-- Consume
  {25654  , "CC"},				-- Tail Lash
  {25515  , "CC"},				-- Bash
  {25756  , "CC"},				-- Purge
  -- -- Kurinnaxx
  {25656  , "CC"},				-- Sand Trap
  -- -- General Rajaxx
  {19134  , "CC"},				-- Frightening Shout
  {29544  , "CC"},				-- Frightening Shout
  {25425  , "CC"},				-- Shockwave
  -- -- Moam
  {25685  , "CC"},				-- Energize
  {28450  , "CC"},				-- Arcane Explosion
  -- -- Ayamiss the Hunter
  {25852  , "CC"},				-- Lash
  {6608   , "Disarm"},			-- Dropped Weapon
  {25725  , "CC"},				-- Paralyze
  -- -- Ossirian the Unscarred
  {25189  , "CC"},				-- Enveloping Winds
  },
  ------------------------
{"Temple of Ahn'Qiraj Raid",
  -- -- Trash
  {7670   , "CC"},				-- Explode
  {18327  , "Silence"},			-- Silence
  {26069  , "Silence"},			-- Silence
  {26070  , "CC"},				-- Fear
  {26072  , "CC"},				-- Dust Cloud
  {25698  , "CC"},				-- Explode
  {26079  , "CC"},				-- Cause Insanity
  {26049  , "CC"},				-- Mana Burn
  {26552  , "CC"},				-- Nullify
  {26071  , "Root"},				-- Entangling Roots
  -- -- The Prophet Skeram
  {785    , "CC"},				-- True Fulfillment
  -- -- Bug Trio: Yauj}, Vem}, Kri
  {3242   , "CC"},				-- Ravage
  {26580  , "CC"},				-- Fear
  {19128  , "CC"},				-- Knockdown
  -- -- Fankriss the Unyielding
  {720    , "CC"},				-- Entangle
  {731    , "CC"},				-- Entangle
  {1121   , "CC"},				-- Entangle
  -- -- Viscidus
  {25937  , "CC"},				-- Viscidus Freeze
  -- -- Princess Huhuran
  {26180  , "CC"},				-- Wyvern Sting
  {26053  , "Silence"},			-- Noxious Poison
  -- -- Twin Emperors: Vek'lor & Vek'nilash
  {800    , "CC"},				-- Twin Teleport
  {804    , "Root"},				-- Explode Bug
  {12241  , "Root"},				-- Twin Colossals Teleport
  {12242  , "Root"},				-- Twin Colossals Teleport
  -- -- Ouro
  {26102  , "CC"},				-- Sand Blast
  -- -- C'Thun
  },
  ------------------------
{"Naxxramas (Classic) Raid",
  -- -- Trash
  {6605   , "CC"},				-- Terrifying Screech
  {27758  , "CC"},				-- War Stomp
  {27990  , "CC"},				-- Fear
  {28412  , "CC"},				-- Death Coil
  {29848  , "CC"},				-- Polymorph
  {29849  , "Root"},				-- Frost Nova
  {30094  , "Root"},				-- Frost Nova
  -- -- Anub'Rekhan
  {28786  , "CC"},				-- Locust Swarm
  {25821  , "CC"},				-- Charge
  {28991  , "Root"},				-- Web
  -- -- Grand Widow Faerlina
  {30225  , "Silence"},			-- Silence
  -- -- Maexxna
  {28622  , "CC"},				-- Web Wrap
  {29484  , "CC"},				-- Web Spray
  -- -- Noth the Plaguebringer
  -- -- Heigan the Unclean
  {30112  , "CC"},				-- Frenzied Dive
  -- -- Instructor Razuvious
  -- -- Gothik the Harvester
  {11428  , "CC"},				-- Knockdown
  -- -- Gluth
  {29685  , "CC"},				-- Terrifying Roar
  -- -- Sapphiron
  {28522  , "CC"},				-- Icebolt
  -- -- Kel'Thuzad
  {28410  , "CC"},				-- Chains of Kel'Thuzad
  {27808  , "CC"},				-- Frost Blast
  },
  ------------------------
{"Classic World Bosses",
  -- -- Azuregos
  {23186  , "CC"},				-- Aura of Frost
  {21099  , "CC"},				-- Frost Breath
  -- -- Doom Lord Kazzak & Highlord Kruul
  -- -- Dragons of Nightmare
  {25043  , "CC"},				-- Aura of Nature
  {24778  , "CC"},				-- Sleep (Dream Fog)
  {24811  , "CC"},				-- Draw Spirit
  {25806  , "CC"},				-- Creature of Nightmare
  {12528  , "Silence"},			-- Silence
  {23207  , "Silence"},			-- Silence
  {29943  , "Silence"},			-- Silence
  },
  ------------------------
  -- Classic Dungeons
{"Ragefire Chasm",
  {8242   , "CC"},				-- Shield Slam
  },
{"The Deadmines",
  {6304   , "CC"},				-- Rhahk'Zor Slam
  {6713   , "Disarm"},			-- Disarm
  {7399   , "CC"},				-- Terrify
  {6435   , "CC"},				-- Smite Slam
  {6432   , "CC"},				-- Smite Stomp
  {113    , "Root"},				-- Chains of Ice
  {512    , "Root"},				-- Chains of Ice
  {228    , "CC"},				-- Polymorph: Chicken
  {6466   , "CC"},				-- Axe Toss
  },
{"Wailing Caverns",
  {8040   , "CC"},				-- Druid's Slumber
  {8142   , "Root"},				-- Grasping Vines
  {5164   , "CC"},				-- Knockdown
  {7967   , "CC"},				-- Naralex's Nightmare
  {6271   , "CC"},				-- Naralex's Awakening
  {8150   , "CC"},				-- Thundercrack
  },
{"Shadowfang Keep",
  {7295   , "Root"},				-- Soul Drain
  {7587   , "Root"},				-- Shadow Port
  {7136   , "Root"},				-- Shadow Port
  {7586   , "Root"},				-- Shadow Port
  {7139   , "CC"},				-- Fel Stomp
  {13005  , "CC"},				-- Hammer of Justice
  {7621   , "CC"},				-- Arugal's Curse
  {7803   , "CC"},				-- Thundershock
  {7074   , "Silence"},			-- Screams of the Past
  },
{"Blackfathom Deeps",
  {15531  , "Root"},				-- Frost Nova
  {6533   , "Root"},				-- Net
  {8399   , "CC"},				-- Sleep
  {8379   , "Disarm"},			-- Disarm
  {8391   , "CC"},				-- Ravage
  {7645   , "CC"},				-- Dominate Mind
  },
{"The Stockade",
  {7964   , "CC"},				-- Smoke Bomb
  {6253   , "CC"},				-- Backhand
  },
{"Gnomeregan",
  {10737  , "CC"},				-- Hail Storm
  {15878  , "CC"},				-- Ice Blast
  {10856  , "CC"},				-- Link Dead
  {11820  , "Root"},				-- Electrified Net
  {10852  , "Root"},				-- Battle Net
  {11264  , "Root"},				-- Ice Blast
  {10730  , "CC"},				-- Pacify
  },
{"Razorfen Kraul",
  {8281   , "Silence"},			-- Sonic Burst
  {8359   , "CC"},				-- Left for Dead
  {8285   , "CC"},				-- Rampage
  {8377   , "Root"},				-- Earthgrab
  {6728   , "CC"},				-- Enveloping Winds
  {6524   , "CC"},				-- Ground Tremor
  },
{"Scarlet Monastery",
  {13323  , "CC"},				-- Polymorph
  {8988   , "Silence"},			-- Silence
  {9256   , "CC"},				-- Deep Sleep
  },
{"Razorfen Downs",
  {12252  , "Root"},				-- Web Spray
  {12946  , "Silence"},			-- Putrid Stench
  {745    , "Root"},				-- Web
  {12748  , "Root"},				-- Frost Nova
  },
{"Uldaman",
  {11876  , "CC"},				-- War Stomp
  {3636   , "CC"},				-- Crystalline Slumber
  {6726   , "Silence"},			-- Silence
  {10093  , "Silence"},			-- Harsh Winds
  {25161  , "Silence"},			-- Harsh Winds
  },
{"Maraudon",
  {12747  , "Root"},				-- Entangling Roots
  {21331  , "Root"},				-- Entangling Roots
  {21909  , "Root"},				-- Dust Field
  {21808  , "CC"},				-- Summon Shardlings
  {29419  , "CC"},				-- Flash Bomb
  {22592  , "CC"},				-- Knockdown
  {21869  , "CC"},				-- Repulsive Gaze
  {16790  , "CC"},				-- Knockdown
  {21748  , "CC"},				-- Thorn Volley
  {21749  , "CC"},				-- Thorn Volley
  {11922  , "Root"},				-- Entangling Roots
  },
{"Zul'Farrak",
  {11020  , "CC"},				-- Petrify
  {22692  , "CC"},				-- Petrify
  {13704  , "CC"},				-- Psychic Scream
  {11836  , "CC"},				-- Freeze Solid
  {11641  , "CC"},				-- Hex
  },
{"The Temple of Atal'Hakkar (Sunken Temple)",
  {12888  , "CC"},				-- Cause Insanity
  {12480  , "CC"},				-- Hex of Jammal'an
  {12890  , "CC"},				-- Deep Slumber
  {6607   , "CC"},				-- Lash
  {33126  , "Disarm"},			-- Dropped Weapon
  {25774  , "CC"},				-- Mind Shatter
  },
{"Blackrock Depths",
  {8994   , "CC"},				-- Banish
  {12674  , "Root"},				-- Frost Nova
  {15471  , "Silence"},			-- Enveloping Web
  {3609   , "CC"},				-- Paralyzing Poison
  {15474  , "Root"},				-- Web Explosion
  {17492  , "CC"},				-- Hand of Thaurissan
  {14030  , "Root"},				-- Hooked Net
  {14870  , "CC"},				-- Drunken Stupor
  {13902  , "CC"},				-- Fist of Ragnaros
  {15063  , "Root"},				-- Frost Nova
  {6945   , "CC"},				-- Chest Pains
  {3551   , "CC"},				-- Skull Crack
  {15621  , "CC"},				-- Skull Crack
  {11831  , "Root"},				-- Frost Nova
  },
{"Blackrock Spire",
  {16097  , "CC"},				-- Hex
  {22566  , "CC"},				-- Hex
  {15618  , "CC"},				-- Snap Kick
  {16075  , "CC"},				-- Throw Axe
  {16045  , "CC"},				-- Encage
  {16104  , "CC"},				-- Crystallize
  {16508  , "CC"},				-- Intimidating Roar
  {15609  , "Root"},				-- Hooked Net
  {16497  , "CC"},				-- Stun Bomb
  {5276   , "CC"},				-- Freeze
  {18763  , "CC"},				-- Freeze
  {16805  , "CC"},				-- Conflagration
  {13579  , "CC"},				-- Gouge
  {24698  , "CC"},				-- Gouge
  {28456  , "CC"},				-- Gouge
  {16469  , "Root"},				-- Web Explosion
  {15532  , "Root"},				-- Frost Nova
  },
{"Stratholme",
  {17398  , "CC"},				-- Balnazzar Transform Stun
  {17405  , "CC"},				-- Domination
  {17246  , "CC"},				-- Possessed
  {19832  , "CC"},				-- Possess
  {15655  , "CC"},				-- Shield Slam
  {16798  , "CC"},				-- Enchanting Lullaby
  {12542  , "CC"},				-- Fear
  {12734  , "CC"},				-- Ground Smash
  {17293  , "CC"},				-- Burning Winds
  {4962   , "Root"},				-- Encasing Webs
  {16869  , "CC"},				-- Ice Tomb
  {17244  , "CC"},				-- Possess
  {17307  , "CC"},				-- Knockout
  {15970  , "CC"},				-- Sleep
  {3589   , "Silence"},			-- Deafening Screech
  },
{"Dire Maul",
  {27553  , "CC"},				-- Maul
  {22651  , "CC"},				-- Sacrifice
  {22419  , "Disarm"},			-- Riptide
  {22691  , "Disarm"},			-- Disarm
  {22833  , "CC"},				-- Booze Spit (chance to hit reduced by 75%)
  {22856  , "CC"},				-- Ice Lock
  {16727  , "CC"},				-- War Stomp
  {22994  , "Root"},				-- Entangle
  {22924  , "Root"},				-- Grasping Vines
  {22915  , "CC"},				-- Improved Concussive Shot
  {28858  , "Root"},				-- Entangling Roots
  {22415  , "Root"},				-- Entangling Roots
  {22744  , "Root"},				-- Chains of Ice
  {16838  , "Silence"},			-- Banshee Shriek
  {22519  , "CC"},				-- Ice Nova
  },
{"Scholomance",
  {5708   , "CC"},				-- Swoop
  {18144  , "CC"},				-- Swoop
  {18103  , "CC"},				-- Backhand
  {8208   , "CC"},				-- Backhand
  {12461  , "CC"},				-- Backhand
  {27565  , "CC"},				-- Banish
  {16350  , "CC"},				-- Freeze

  --{139 , "CC", "Renew"},

},


{"Discovered LC Spells"
},
}

L.spellsTable = spellsTable
L.spellsArenaTable = spellsArenaTable

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

local defaultString = { --changes the font under LC for pLayer
	["CC"] = "CC",
	["Silence"] = "Silenced",
	["RootPhyiscal_Special"] = "Rooted",
	["RootMagic_Special"] = "Rooted",
	["Root"] = "Rooted",
	["ImmunePlayer"] = "Immune",
	["Disarm_Warning"] = "Disarm Warning",
	["CC_Warning"] = "Warning",
	--["Enemy_Smoke_Bomb"] = "SmokeBomb",
	["Stealth"] = "Stealth",
	["Immune"] = "Immune",
	["ImmuneSpell"] = "Immune",
	["ImmunePhysical"] = "Immune",
	["AuraMastery_Cast_Auras"] = "Aura Mastery",
	["ROP_Vortex"] = "Vortexed",
	["Disarm"] = "Disarmed",
	["Haste_Reduction"] = "Tongues",
	["Dmg_Hit_Reduction"] = "Hit Loss",
	["Interrupt"] = "Locked Out",
	["AOE_DMG_Modifiers"] = "Damage Amp",
	["Friendly_Smoke_Bomb"] = "SmokeBomb",
	["AOE_Spell_Refections"] = "Reflect",
	["Trees"] = "Tanking",
	["Speed_Freedoms"] = "Speed",
	["Freedoms"] = "Freedom",
	["Friendly_Defensives"] = "Defense",
	["Mana_Regen"] = "Mana Regen",
	["CC_Reduction"] = "CC Help",
	["Personal_Offensives"] = "Offense",
	["Peronsal_Defensives"] = "Defense",
	["Movable_Cast_Auras"] = "PowerUp",

	["Other"] = "Other", --PVE only
	["PvE"] = "PvE", --PVE only

	["SnareSpecial"] = "Snared",
	["SnarePhysical70"] = "Snared",
	["SnareMagic70"] = "Snared",
	["SnarePhysical50"] = "Snared",
	["SnarePosion50"] = "Snared",
	["SnareMagic50"] = "Snared",
	["SnarePhysical30"] = "Snared",
	["SnareMagic30"] = "Snared",
	["Snare"] = "Snared",
}


local tabsArena = {
	"Drink_Purge",
	"Immune_Arena",
	"CC_Arena",
	"Silence_Arena",
	"Interrupt", -- Needs to be same
	"Special_High",
	"Ranged_Major_OffenisiveCDs",
	"Roots_90_Snares",
	"Disarms",
	"Melee_Major_OffenisiveCDs",
	"Big_Defensive_CDs",
	"Player_Party_OffensiveCDs",
	"Small_Offenisive_CDs",
	"Small_Defensive_CDs",
	"Freedoms_Speed",
	"Snares_WithCDs",
	"Special_Low",
	"Snares_Ranged_Spamable",
	"Snares_Casted_Melee",
}

local tabsIndex = {}
for i = 1, #tabs do
	tabsIndex[tabs[i]] = i
end
local tabsArenaIndex = {}
for i = 1, #tabsArena do
	tabsArenaIndex[tabsArena[i]] = i
end


-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {
	}, -- empty but necessary
	BambiUI = {
		player = "PartyAnchor5", --Chris
		party1 = "PartyAnchor1", --Chris
		party2 = "PartyAnchor2", --Chris
		party3 = "PartyAnchor3", --Chris
		party4 = "PartyAnchor4",
	},
	Gladius = {
		arena1      = GladiusClassIconFramearena1 or nil,
		arena2      = GladiusClassIconFramearena2 or nil,
		arena3      = GladiusClassIconFramearena3 or nil,
		arena4      = GladiusClassIconFramearena4 or nil,
		arena5      = GladiusClassIconFramearena5 or nil,
	},
  Gladdy = {
  arena1       = GladdyButtonFrame1 and GladdyButtonFrame1.classIcon or nil,
  arena2       = GladdyButtonFrame2 and GladdyButtonFrame2.classIcon or nil,
  arena3       = GladdyButtonFrame3 and GladdyButtonFrame3.classIcon or nil,
  arena4       = GladdyButtonFrame4 and GladdyButtonFrame4.classIcon or nil,
  arena5       = GladdyButtonFrame5 and GladdyButtonFrame5.classIcon or nil,
  },
	Blizzard = {
		player       = "PlayerPortrait",
		pet          = "PetPortrait",
		target       = "TargetFramePortrait",
		targettarget = "TargetFrameToTPortrait",
		focus        = "FocusFramePortrait",
		focustarget  = "FocusFrameToTPortrait",
		party1       = "PartyMemberFrame1Portrait",
		party2       = "PartyMemberFrame2Portrait",
		party3       = "PartyMemberFrame3Portrait",
		party4       = "PartyMemberFrame4Portrait",
		--party1pet    = "PartyMemberFrame1PetFramePortrait",
		--party2pet    = "PartyMemberFrame2PetFramePortrait",
		--party3pet    = "PartyMemberFrame3PetFramePortrait",
		--party4pet    = "PartyMemberFrame4PetFramePortrait",
		arena1      = "ArenaEnemyFrame1ClassPortrait",
		arena2      = "ArenaEnemyFrame2ClassPortrait",
		arena3      = "ArenaEnemyFrame3ClassPortrait",
		arena4      = "ArenaEnemyFrame4ClassPortrait",
		arena5      = "ArenaEnemyFrame5ClassPortrait",

	},
	Perl = {
		player       = "Perl_Player_PortraitFrame",
		pet          = "Perl_Player_Pet_PortraitFrame",
		target       = "Perl_Target_PortraitFrame",
		targettarget = "Perl_Target_Target_PortraitFrame",
		focus        = "Perl_Focus_PortraitFrame",
		focustarget  = "Perl_Focus_Target_PortraitFrame",
		party1       = "Perl_Party_MemberFrame1_PortraitFrame",
		party2       = "Perl_Party_MemberFrame2_PortraitFrame",
		party3       = "Perl_Party_MemberFrame3_PortraitFrame",
		party4       = "Perl_Party_MemberFrame4_PortraitFrame",
	},
	XPerl = {
		player       = "XPerl_PlayerportraitFrameportrait",
		pet          = "XPerl_Player_PetportraitFrameportrait",
		target       = "XPerl_TargetportraitFrameportrait",
		targettarget = "XPerl_TargettargetportraitFrameportrait",
		focus        = "XPerl_FocusportraitFrameportrait",
		focustarget = "XPerl_FocustargetportraitFrameportrait",
		party1       = "XPerl_party1portraitFrameportrait",
		party2       = "XPerl_party2portraitFrameportrait",
		party3       = "XPerl_party3portraitFrameportrait",
		party4       = "XPerl_party4portraitFrameportrait",
	},
	LUI = {
		player       = "oUF_LUI_player",
		pet          = "oUF_LUI_pet",
		target       = "oUF_LUI_target",
		targettarget = "oUF_LUI_targettarget",
		focus        = "oUF_LUI_focus",
		focustarget  = "oUF_LUI_focustarget",
		party1       = "oUF_LUI_partyUnitButton1",
		party2       = "oUF_LUI_partyUnitButton2",
		party3       = "oUF_LUI_partyUnitButton3",
		party4       = "oUF_LUI_partyUnitButton4",
	},
	SyncFrames = {
		arena1 = "SyncFrame1Class",
		arena2 = "SyncFrame2Class",
		arena3 = "SyncFrame3Class",
		arena4 = "SyncFrame4Class",
		arena5 = "SyncFrame5Class",
	},
	SUF = {
		player       = SUFUnitplayer and SUFUnitplayer.portrait or nil,
		pet          = SUFUnitpet and SUFUnitpet.portrait or nil,
		target       = SUFUnittarget and SUFUnittarget.portrait or nil,
		targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil,
		focus        = SUFUnitfocus and SUFUnitfocus.portrait or nil,
		focustarget  = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil,
		party1       = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil,
		party2       = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil,
		party3       = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil,
		party4       = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil,
		arena1       = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil,
		arena2       = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil,
		arena3       = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil,
		arena4       = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil,
		arena5       = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil,
	},
	-- more to come here?
}

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	EnableGladiusGloss = true, --Add option Check Box for This
	InterruptIcons = false,
	InterruptOverlay = false,
	RedSmokeBomb = true,
	lossOfControl = true,
	lossOfControlInterrupt = 1,
	lossOfControlFull  = 0,
	lossOfControlSilence = 0,
	lossOfControlDisarm = 0,
	lossOfControlRoot = 0,
	DrawSwipeSetting = 0,
	DiscoveredSpells = { },
  customString = { },

	spellEnabled = { },
	spellEnabledArena = { },

	customSpellIds = { },
	customSpellIdsArena = { },

	version = 9.12, -- This is the settings version, not necessarily the same as the LoseControl version
	noCooldownCount = false,
	noBlizzardCooldownCount = true,
	noLossOfControlCooldown = false, --Chris Need to Test what is better
	disablePartyInBG = true,
	disableArenaInBG = true,
	disablePartyInRaid = true,
	disablePlayerTargetTarget = true,
	disableTargetTargetTarget = true,
	disablePlayerTargetPlayerTargetTarget = true,
	disableTargetDeadTargetTarget = true,
	disablePlayerFocusTarget = true,
	disableFocusFocusTarget = true,
	disablePlayerFocusPlayerFocusTarget = true,
	disableFocusDeadFocusTarget = true,
	showNPCInterruptsTarget = true,
	showNPCInterruptsFocus = true,
	showNPCInterruptsTargetTarget = true,
	showNPCInterruptsFocusTarget = true,
	duplicatePlayerPortrait = true,
  PlayerText = true,
  ArenaPlayerText = false,
  displayTypeDot = true,
  SilenceIcon = true,
	priority = {		-- higher numbers have more priority; 0 = disabled
			CC = 100,
			Silence = 95,
			RootPhyiscal_Special = 90,
			RootMagic_Special = 85,
			Root = 80,
			ImmunePlayer = 75,
			Disarm_Warning = 70,
			CC_Warning = 65,
			Enemy_Smoke_Bomb = 60,
			Stealth = 55,
			Immune = 50,
			ImmuneSpell = 45,
			ImmunePhysical = 45,
			AuraMastery_Cast_Auras = 44,
			ROP_Vortex = 42,
			Disarm = 40,
			Haste_Reduction = 38,
			Dmg_Hit_Reduction = 38,
			Interrupt = 36,
			AOE_DMG_Modifiers = 34,
			Friendly_Smoke_Bomb = 32,
			AOE_Spell_Refections = 30,
			Trees = 28,
			Speed_Freedoms = 26,
			Freedoms = 24,
			Friendly_Defensives = 22,
			CC_Reduction = 18,
			Personal_Offensives = 16,
			Peronsal_Defensives = 14,
      Mana_Regen = 10,
			Movable_Cast_Auras = 10,

			Other = 10, --PVE only
			PvE = 10, --PVE only

			SnareSpecial = 12,
			SnarePhysical70 = 8,
			SnareMagic70 = 7,
			SnarePhysical50 = 6,
			SnarePosion50 = 5,
			SnareMagic50 = 4,
			SnarePhysical30 = 3,
			SnareMagic30 = 2,
			Snare = 1,
	},
	durationType = {		-- higher numbers have more priority; 0 = disabled
			CC = false,
			Silence = false,
			RootPhyiscal_Special = false,
			RootMagic_Special = false,
			Root = true,
			ImmunePlayer = false,
			Disarm_Warning = false,
			CC_Warning = false,
			Enemy_Smoke_Bomb = false,
			Stealth = false,
			Immune = false,
			ImmuneSpell = false,
			ImmunePhysical = false,
			AuraMastery_Cast_Auras = false,
			ROP_Vortex = false,
			Disarm = false,
			Haste_Reduction = false,
			Dmg_Hit_Reduction = false,
			Interrupt = false,
			AOE_DMG_Modifiers = false,
			Friendly_Smoke_Bomb = false,
			AOE_Spell_Refections = false,
			Trees = false,
			Speed_Freedoms = false,
			Freedoms = false,
			Friendly_Defensives = false,
			Mana_Regen = false,
			CC_Reduction = false,
			Personal_Offensives = false,
			Peronsal_Defensives = false,
			Movable_Cast_Auras = false,

			Other = false,
			PvE = false,

			SnareSpecial = false,
			SnarePhysical70 = false,
			SnareMagic70 = false,
			SnarePhysical50 = true,
			SnarePosion50 = true,
			SnareMagic50 = true,
			SnarePhysical30 = true,
			SnareMagic30 = true,
			Snare = true,
	},
	priorityArena = {		-- higher numbers have more priority; 0 = disabled
			Drink_Purge = 100,
			Immune_Arena = 100,
			CC_Arena = 85,
			Silence_Arena = 80,
			Interrupt = 75, -- Needs to be same
			Special_High = 65,
			Ranged_Major_OffenisiveCDs = 60,
			Roots_90_Snares = 55,
			Disarms = 50,
			Melee_Major_OffenisiveCDs = 35,
			Big_Defensive_CDs = 35,
			Player_Party_OffensiveCDs = 35,
			Small_Offenisive_CDs = 25,
			Small_Defensive_CDs = 25,
			Freedoms_Speed = 25,
			Snares_WithCDs = 20,
			Special_Low = 15,
			Snares_Ranged_Spamable = 10,
			Snares_Casted_Melee = 5,
	},
	durationTypeArena ={
			Drink_Purge = false,
			Immune_Arena = false,
			CC_Arena = false,
			Silence_Arena = false,
			Interrupt = false, -- Needs to be same
			Special_High = false,
			Ranged_Major_OffenisiveCDs = false,
			Roots_90_Snares = false,
			Disarms = false,
			Melee_Major_OffenisiveCDs = false,
			Big_Defensive_CDs = false,
			Player_Party_OffensiveCDs = false,
			Small_Offenisive_CDs = false,
			Small_Defensive_CDs = false,
			Freedoms_Speed = false,
			Snares_WithCDs = false,
			Special_Low = false,
			Snares_Ranged_Spamable = false,
			Snares_Casted_Melee = false,
	},
	frames = {
		player = {
			enabled = true,
			size = 48, --CHRIS
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
				},
				debuff ={
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
			},
				interrupt = {
					friendly = false
				}
			}
		},
		player2 = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
				},
				debuff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
			},
				interrupt = {
					friendly = true
				}
			}
		},
		pet = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				}
				},
				interrupt = {
					friendly = true
				}
			}
		},
		target = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		targettarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focus = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focustarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		party1 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
						 Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 						  Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party2 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
			        Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party3 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 					    Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party4 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 						  Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true, 	Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires
------------------------------------------------------------------------------------
--[[
-------------------------------------------
-These functions filter to show newest buffs
-------------------------------------------]]
local function cmp_col1(lhs, rhs)
 return lhs.col1 > rhs.col1
end

local function cmp_col1_col2(lhs, rhs)
 if lhs.col1 > rhs.col1 then return true end
 if lhs.col1 < rhs.col1 then return false end
 return lhs.col2 > rhs.col2
end

local locBliz = CreateFrame("Frame")
locBliz:RegisterEvent("LOSS_OF_CONTROL_ADDED")
locBliz:SetScript("OnEvent", function(self, event, ...)
	if (event == "LOSS_OF_CONTROL_ADDED") then
		for i = 1, 40 do
		local data = CLocData(i);
		 	if not data then break end

        local customString = LoseControlDB.customString

			  local locType = data.locType;
			 	local spellID = data.spellID;
			 	local text = data.displayText;
			 	local iconTexture = data.iconTexture;
			 	local startTime = data.startTime;
			 	local timeRemaining = data.timeRemaining;
			 	local duration = data.duration;
			 	local lockoutSchool = data.lockoutSchool;
			 	local priority = data.priority;
			 	local displayType = data.displayType;
				local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
				local ZoneName = GetZoneText()
				local Type

        if locType == "SCHOOL_INTERRUPT" then text = strformat("%s Locked", GetSchoolString(lockoutSchool)) end

        string[spellID] = customString[spellID] or text

		  	if not spellIds[spellID] and  (lockoutSchool == 0 or nil or false) then
			  	if (locType == "STUN_MECHANIC") or (locType =="PACIFY") or (locType =="STUN") or (locType =="FEAR") or (locType =="CHARM") or (locType =="CONFUSE") or (locType =="POSSESS") or (locType =="FEAR_MECHANIC") or (locType =="FEAR") then
								 print("Found New CC",locType,"", spellID)
								 Type = "CC"
					elseif locType == "DISARM" then
								 print("Found New Disarm",locType,"", spellID)
							   Type = "Disarm"
					elseif (locType == "PACIFYSILENCE") or (locType =="SILENCE") then
						    print("Found New Silence",locType,"", spellID)
						 	  Type = "Silence"
					elseif locType == "ROOT" then
						  	print("Found New Root",locType,"", spellID)
								Type = "Root"
					else
								print("Found New Other",locType,"", spellID)
								Type = "Other"
					end
					spellIds[spellID] = Type
					LoseControlDB.spellEnabled[spellID]= true
					tblinsert(LoseControlDB.customSpellIds, {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex[Type]], {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
			  elseif (not interruptsIds[spellID]) and lockoutSchool > 0 then
					print("Found New Interrupt",locType,"", spellID)
					interruptsIds[spellID] = duration
					LoseControlDB.spellEnabled[spellID]= true
					tblinsert(LoseControlDB.customSpellIds, {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex["Interrupt"]], {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
				else
				end
			end
		end
	end)


local tooltip = CreateFrame("GameTooltip", "DebuffTextDebuffScanTooltip", UIParent, "GameTooltipTemplate")
local function GetDebuffText(unitId, debuffNum)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetUnitDebuff(unitId, debuffNum)
	local snarestring = DebuffTextDebuffScanTooltipTextLeft2:GetText()
	tooltip:Hide()
	if snarestring then
		if strmatch(snarestring, "Movement") or strmatch(snarestring, "movement") then
		return true
	  else
		return false
		end
	end
end


-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent, "CooldownFrameTemplate") -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Utility function to handle registering for unit events
function LoseControl:RegisterUnitEvents(enabled)
	local unitId = self.unitId
	if debug then print("RegisterUnitEvents", unitId, enabled) end
	if enabled then
		if unitId == "target" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "target")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- TargetTarget Blizzard Frame Show
				TargetFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -30)
						else
							self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 30)
						end
					end
				end)
				-- TargetTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local TframeToTDebuff = _G["TargetFrameToTDebuff"..i]
					if (TframeToTDebuff ~= nil) then
						TframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 40)
									end
								end)
							end
						end)
						TframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 43)
									end
								end)
							end
						end)
					end
				end
				TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "focus" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "focus")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- FocusTarget Blizzard Frame Show
				FocusFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -30)
						else
							self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 30)
						end
					end
				end)
				-- FocusTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local FframeToTDebuff = _G["FocusFrameToTDebuff"..i]
					if (FframeToTDebuff ~= nil) then
						FframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 30)
									end
								end)
							end
						end)
						FframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 31)
									end
								end)
							end
						end)
					end
				end
				FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "pet" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterUnitEvent("UNIT_PET", "player")
		else
			self:RegisterUnitEvent("UNIT_AURA", unitId)
		end
	else
		if unitId == "target" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "focus" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "pet" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("UNIT_PET")
		else
			self:UnregisterEvent("UNIT_AURA")
		end
		if not self.unlockMode then
			self:Hide()
			self:GetParent():Hide()
		end
	end
	local someFrameEnabled = false
	for _, v in pairs(LCframes) do
		if v.frame and v.frame.enabled then
			someFrameEnabled = true
			break
		end
	end
	if someFrameEnabled then
		LCframes["target"]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		LCframes["target"]:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

local function SetInterruptIconsSize(iconFrame, iconSize)
	local interruptIconSize = (iconSize * 0.88) / 3
	local interruptIconOffset = (iconSize * 0.06)
	if iconFrame.frame.anchor == "Blizzard" then
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[2] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[3] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[4] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2},
			[6] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize*2},
			[7] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize*2}
		}
	else
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset, interruptIconOffset},
			[2] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[3] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset},
			[4] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[6] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[7] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2}
		}
	end
	iconFrame.iconInterruptBackground:SetWidth(iconSize)
	iconFrame.iconInterruptBackground:SetHeight(iconSize)
	for _, v in pairs(iconFrame.iconInterruptList) do
		v:SetWidth(interruptIconSize)
		v:SetHeight(interruptIconSize)
		v:SetPoint("BOTTOMRIGHT", iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][1], iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][2])
	end
end

-- Function to disable Cooldown on player bars for CC effects
function LoseControl:DisableLossOfControlUI()
	if (not DISABLELOSSOFCONTROLUI_HOOKED) then
		hooksecurefunc('CooldownFrame_Set', function(self)
			if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
				self:SetDrawBling(false)
				self:SetCooldown(0, 0)
			else
				if not self:GetDrawBling() then
					self:SetDrawBling(true)
				end
			end
		end)
		hooksecurefunc('ActionButton_UpdateCooldown', function(self)
			if ( self.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
				local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration;
				local modRate = 1.0;
				local chargeModRate = 1.0;
				if ( self.spellID ) then
					start, duration, enable, modRate = GetSpellCooldown(self.spellID);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetSpellCharges(self.spellID);
				else
					start, duration, enable, modRate = GetActionCooldown(self.action);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(self.action);
				end
				self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
				self.cooldown:SetSwipeColor(0, 0, 0);
				self.cooldown:SetHideCountdownNumbers(false);
				if ( charges and maxCharges and maxCharges > 1 and charges < maxCharges ) then
					if chargeStart == 0 then
						ClearChargeCooldown(self);
					else
						if self.chargeCooldown then
							CooldownFrame_Set(self.chargeCooldown, chargeStart, chargeDuration, true, true, chargeModRate);
						end
					end
				else
					ClearChargeCooldown(self);
				end
				CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
			end
		end)
		DISABLELOSSOFCONTROLUI_HOOKED = true
	end
end


function LoseControl:CompileArenaSpells()

	spellIdsArena = {}

	local spellsArena = {}
	local spellsArenaLua = {}
	local hash = {}
	local customSpells = {}
	local toremove = {}
	--Build Custom Table for Check
	for k, v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, _, _, _, _, tabId  = unpack(v)
		customSpells[spellID] = {spellID, prio, k}
	end
	--Build the Spells Table
	for i = 1, (#tabsArena) do
		if spellsArena[i] == nil then
			spellsArena[i] = {}
		end
	end
--Sort the spells
	for k, v in ipairs(spellsArenaTable) do
		local spellID, prio = unpack(v)
		tblinsert(spellsArena[tabsArenaIndex[prio]], ({spellID, prio }))
		spellsArenaLua[spellID] = true
	end

	L.spellsArenaLua = spellsArenaLua
	--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
	for i = 1, (#spellsArena) do
		local removed = 0
		for l = 1, (#spellsArena[i]) do
			local spellID, prio = unpack(spellsArena[i][l])
			if (not hash[spellID]) and (not customSpells[spellID]) then
				hash[spellID] = {spellID, prio}
			else
				if customSpells[spellID] then
					local CspellID, Cprio, Ck = unpack(customSpells[spellID])
					if CspellID == spellID and Cprio == prio then
					tblremove(_G.LoseControlDB.customSpellIdsArena, Ck)
					print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored Arena Spell to Orginal Value|r")
					else
						if type(spellID) == "number" then
							if GetSpellInfo(spellID) then
								local name = GetSpellInfo(spellID)
								--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
						else
								--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
						end
						tblinsert(toremove, {i , l, removed, spellID})
						removed = removed + 1
					end
				else
					local HspellID, Hprio = unpack(hash[spellID])
					if type(spellID) == "number" then
							local name = GetSpellInfo(spellID)
							--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					else
							--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					end
					tblinsert(toremove, {i , l, removed, spellID})
					removed = removed + 1
				end
			end
		end
	end
	--Now Remove all the Duplicates and Custom Spells
	for k, v in ipairs(toremove) do
	local i, l, r, s = unpack(v)
	tblremove(spellsArena[i], l - r)
	end
	--ReAdd all dbCustom Spells to spells
	for k,v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, instanceType, zone, duration, customname, _, cleuEvent  = unpack(v)
		if prio ~= "Delete" then
			tblinsert(spellsArena[tabsArenaIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
		end
	end

		--Make spellIds from Spells for AuraFilter
	for i = 1, #spellsArena do
		for l = 1, #spellsArena[i] do
			spellIdsArena[spellsArena[i][l][1]] = spellsArena[i][l][2]
		end
	end

	for k, v in ipairs(interrupts) do
	local spellID, duration = unpack(v)
	tblinsert(spellsArena[tabsArenaIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
	end

	for k, v in ipairs(cleuSpells) do
	local spellID, duration, _, prioArena, _, customnameArena = unpack(v)
		if prioArena then
		tblinsert(spellsArena[tabsArenaIndex[prioArena]], 1, {spellID , prioArena, nil, nil, duration, customnameArena, nil, "cleuEventArena"})
		end
	end

	L.spellsArena = spellsArena
	L.spellIdsArena = spellIdsArena

--ARENAENABLED-------------------------------------------------------------------------------------------
	for k in pairs(spellIdsArena) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
		_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(interruptsIds) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
		_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
		if _G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena] == nil then
		_G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena]= true
		end
	end

end

function LoseControl:CompileSpells(typeUpdate)

		spellIds = {}
		interruptsIds = {}
		cleuPrioCastedSpells = {}

		local	spells = {}
		local spellsLua = {}
		local hash = {}
		local customSpells = {}
		local toremove = {}
		--Build Custom Table for Check
		for k, v in ipairs(_G.LoseControlDB.customSpellIds) do
			local spellID, prio, _, _, _, _, tabId  = unpack(v)
			customSpells[spellID] = {spellID, prio, tabId, k}
		end
		--Build the Spells Table
		for i = 1, (#spellsTable) do
			if spells[i] == nil then
		    spells[i] = {}
			end
	    for l = 1, (#tabs) do
				if spells[i][l] == nil then
					spells[i][l] = {}
	    	end
			end
		end
		--Sort the spells
		for i = 1, (#spellsTable) do
   		for l = 2, #spellsTable[i] do
				local spellID, prio = unpack(spellsTable[i][l])
        tblinsert(spells[i][tabsIndex[prio]], ({spellID, prio}))
				spellsLua[spellID] = true
			end
		end

    for i = 1, (#spellsTable) do
      for l = 2, #spellsTable[i] do
        local spellID, prio, string = unpack(spellsTable[i][l])
        if string then
          _G.LoseControlDB.customString[spellID] = string
        end
      end
    end

		L.spellsLua = spellsLua
		--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
		for i = 1, (#spells) do
			for l = 1, (#spells[i]) do
				local removed = 0
				for x = 1, (#spells[i][l]) do
					local spellID, prio = unpack(spells[i][l][x])
					if (not hash[spellID]) and (not customSpells[spellID]) then
						hash[spellID] = {spellID, prio}
					else
						if customSpells[spellID] then
							local CspellID, Cprio, CtabId, Ck = unpack(customSpells[spellID])
							if CspellID == spellID and Cprio == prio and CtabId == i then
							tblremove(_G.LoseControlDB.customSpellIds, Ck)
							print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored to Orginal Value|r")
              elseif CspellID == spellID and CtabId == #spells then
              tblremove(_G.LoseControlDB.customSpellIds, Ck)
              print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Added from Discovered Spells to LC Database (Reconfigure if Needed)|r")
							else
								if type(spellID) == "number" then
									if GetSpellInfo(spellID) then
										local name = GetSpellInfo(spellID)
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
									end
								else
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
								end
								tblinsert(toremove, {i , l, x, removed, spellID})
								removed = removed + 1
							end
						else
							local HspellID, Hprio = unpack(hash[spellID])
							if type(spellID) == "number" then
									local name = GetSpellInfo(spellID)
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							else
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
							tblinsert(toremove, {i , l, x, removed, spellID})
							removed = removed + 1
						end
					end
				end
			end
		end
		--Now Remove all the Duplicates and Custom Spells
		for k, v in ipairs(toremove) do
		local i, l, x, r, s = unpack(v)
		tblremove(spells[i][l], x - r)
		end
  	--ReAdd all dbCustom Spells to spells
			for k,v in ipairs(_G.LoseControlDB.customSpellIds) do
				local spellID, prio, instanceType, zone, duration, customname, row, cleuEvent, position  = unpack(v)
				if prio ~= "Delete" then
					if duration then
							interruptsIds[spellID] = duration
					end
          if customname == "Discovered" then row = #spells end
					if position then
          	tblinsert(spells[row][position], 1, v)
					else
            tblinsert(spells[row][tabsIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
					end
				end
			end
  	--Make spellIds from Spells for AuraFilter
		for i = 1, #spells do
			for l = 1, #spells[i] do
				for x = 1, #spells[i][l] do
					spellIds[spells[i][l][x][1]] = spells[i][l][x][2]
				end
			end
		end
		--Make interruptIds for cleu -- only need to compile 1x for arena and players
		for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		interruptsIds[spellID] = duration
		end
		--Make cleuPrioCastedSpells for cleu -- only need to compile 1x for arena and players
		for _, v in ipairs(cleuSpells) do
		local spellID, duration, prio, prioArena, cleuEvent, cleuEventArena = unpack(v)
		cleuPrioCastedSpells[spellID] = {["duration"] = duration, ["priority"] = prio, ["priorityArena"] = prioArena,  ["name"] = cleuEvent,  ["nameArena"] = cleuEventArena}
		end
		--Add interrupts to Spells for Table
		for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		tblinsert(spells[1][tabsIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
		end
		--Add cleuPrioCastedSpells  to Spells for Table
		for k, v in ipairs(cleuSpells) do
		local spellID, duration, prio, _, customname = unpack(v)
			if prio then
			tblinsert(spells[1][tabsIndex[prio]], 1, {spellID , prio, nil, nil, duration, customname, nil, "cleuEvent"})			--body...
			end
		end

		L.spells = spells
		L.spellIds = spellIds
		--check for any 1st time spells being added and set to On
		for k in pairs(spellIds) do --spellIds is the combined PVE list, Spell List and the Discovered & Custom lists from tblinsert above
			if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
			end
		end
		for k in pairs(interruptsIds) do --interruptsIds is the list and the Discovered list from tblinsert above
			if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
			end
		end
		for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
			if _G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name] == nil then
			_G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name]= true
			end
		end

end


-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == addonName then
			if (_G.LoseControlDB == nil) or (_G.LoseControlDB.version == nil) then
			_G.LoseControlDB = CopyTable(DBdefaults)
			print(L["LoseControl reset."])
		end
		if _G.LoseControlDB.version < DBdefaults.version then
			for j, u in pairs(DBdefaults) do
				if (_G.LoseControlDB[j] == nil) then
					_G.LoseControlDB[j] = u
				elseif (type(u) == "table") then
					for k, v in pairs(u) do
						if (_G.LoseControlDB[j][k] == nil) then
							_G.LoseControlDB[j][k] = v
						elseif (type(v) == "table") then
							for l, w in pairs(v) do
								if (_G.LoseControlDB[j][k][l] == nil) then
									_G.LoseControlDB[j][k][l] = w
								elseif (type(w) == "table") then
									for m, x in pairs(w) do
										if (_G.LoseControlDB[j][k][l][m] == nil) then
											_G.LoseControlDB[j][k][l][m] = x
										elseif (type(x) == "table") then
											for n, y in pairs(x) do
												if (_G.LoseControlDB[j][k][l][m][n] == nil) then
													_G.LoseControlDB[j][k][l][m][n] = y
												elseif (type(y) == "table") then
													for o, z in pairs(y) do
														if (_G.LoseControlDB[j][k][l][m][n][o] == nil) then
															_G.LoseControlDB[j][k][l][m][n][o] = z
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			_G.LoseControlDB.version = DBdefaults.version
		end
		LoseControlDB = _G.LoseControlDB
		self.VERSION = "9.0"
		self.noCooldownCount = LoseControlDB.noCooldownCount
		self.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
		self.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
		if LoseControlDB.noLossOfControlCooldown then
			LoseControl:DisableLossOfControlUI()
		end
		if (LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.anchor == "Blizzard") then
			LoseControlDB.duplicatePlayerPortrait = false
		end
		LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
		if LoseControlDB.noCooldownCount then
			self:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			end
			LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
		else
			self:SetHideCountdownNumbers(true)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(true)
			end
			LCframeplayer2:SetHideCountdownNumbers(true)
		end
		playerGUID = UnitGUID("player")
		if Masque then
			for _, v in pairs(LCframes) do
				v.MasqueGroup = Masque:Group(addonName, v.unitId)
				if (LoseControlDB.frames[v.unitId].anchor ~= "Blizzard") then
					v.MasqueGroup:AddButton(v:GetParent(), {
						FloatingBG = false,
						Icon = v.texture,
						Cooldown = v,
						Flash = _G[v:GetParent():GetName().."Flash"],
						Pushed = v:GetParent():GetPushedTexture(),
						Normal = v:GetParent():GetNormalTexture(),
						Disabled = v:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[v:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = v:GetParent():GetHighlightTexture(),
						Hotkey = _G[v:GetParent():GetName().."HotKey"],
						Count = _G[v:GetParent():GetName().."Count"],
						Name = _G[v:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[v:GetParent():GetName().."Shine"],
					}, "Button", true)
					if v.MasqueGroup then
						v.MasqueGroup:ReSkin()
					end
				end
			end
		end
		self:CompileSpells(1)
		self:CompileArenaSpells(1)
	  --L.SpellsPVEConfig:Addon_Load()
	  --L.SpellsConfig:Addon_Load()
		--L.SpellsArenaConfig:Addon_Load()
	end
end

LoseControl:RegisterEvent("ADDON_LOADED")


function LoseControl:CheckSUFUnitsAnchors(updateFrame)
	if not(ShadowUF and (SUFUnitplayer or SUFUnitpet or SUFUnittarget or SUFUnittargettarget or SUFHeaderpartyUnitButton1 or SUFHeaderpartyUnitButton2 or SUFHeaderpartyUnitButton3 or SUFHeaderpartyUnitButton4)) then return false end
	local frames = { self.unitId }
	if strfind(self.unitId, "party") then
		frames = { "party1", "party2", "party3", "party4" }
	elseif strfind(self.unitId, "arena") then
		frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
	end
	for _, unitId in ipairs(frames) do
		if anchors.SUF.player == nil then anchors.SUF.player = SUFUnitplayer and SUFUnitplayer.portrait or nil end
		if anchors.SUF.pet == nil then anchors.SUF.pet    = SUFUnitpet and SUFUnitpet.portrait or nil end
		if anchors.SUF.target == nil then anchors.SUF.target = SUFUnittarget and SUFUnittarget.portrait or nil end
		if anchors.SUF.targettarget == nil then anchors.SUF.targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil end
		if anchors.SUF.focus == nil then anchors.SUF.focus = SUFUnitfocus and SUFUnitfocus.portrait or nil end
		if anchors.SUF.focustarget == nil then anchors.SUF.focustarget = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil end
		if anchors.SUF.party1 == nil then anchors.SUF.party1 = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil end
		if anchors.SUF.party2 == nil then anchors.SUF.party2 = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil end
		if anchors.SUF.party3 == nil then anchors.SUF.party3 = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil end
		if anchors.SUF.party4 == nil then anchors.SUF.party4 = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil end
		if anchors.SUF.arena1 == nil then anchors.SUF.arena1 = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil end
		if anchors.SUF.arena2 == nil then anchors.SUF.arena2 = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil end
		if anchors.SUF.arena3 == nil then anchors.SUF.arena3 = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil end
		if anchors.SUF.arena4 == nil then anchors.SUF.arena4 = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil end
		if anchors.SUF.arena5 == nil then anchors.SUF.arena5 = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil end
		if updateFrame and anchors.SUF[unitId] ~= nil then
			local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
			local icon = LCframes[unitId]
			if self.fakeUnitId == "player2" then
				icon = LCframeplayer2
			end
			local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if newAnchor ~= nil and icon.anchor ~= newAnchor then
				icon.anchor = newAnchor
				icon:SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				icon:GetParent():SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				if icon.anchor:GetParent() then
					icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
		end
	end
	if self.fakeUnitId ~= "player2" and self.unitId == "player" then
		LCframeplayer2:CheckSUFUnitsAnchors(updateFrame)
	end
	return true
end

function LoseControl:CheckGladiusUnitsAnchors(updateFrame)
  if (strfind(self.unitId, "arena")) and LoseControlDB.frames[self.unitId].anchor == "Gladius" then
    local inInstance, instanceType = IsInInstance();  local gladiusFrame;  local frames = {}
  	if Gladius and (not anchors.Gladius[self.unitId]) then
  		if not GladiusClassIconFramearena1 and instanceType ~= "arena" then
  			gladiusFrame = "on"
  			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
  			if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  			else
  				DEFAULT_CHAT_FRAME.editBox:Show()
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  				DEFAULT_CHAT_FRAME.editBox:Hide()
  			end
    	end
  		if GladiusClassIconFramearena1 then frames[1] = "arena1" end
    	if GladiusClassIconFramearena2 then frames[2] = "arena2" end
  		if GladiusClassIconFramearena3 then frames[3] = "arena3" end
  		if GladiusClassIconFramearena4 then frames[4] = "arena4" end
  		if GladiusClassIconFramearena5 then frames[5] = "arena5" end
  			for _, unitId in pairs(frames) do
  				if (unitId == "arena1") and anchors.Gladius.arena1 == nil then anchors.Gladius.arena1 = GladiusClassIconFramearena1 or nil end
  				if (unitId == "arena2") and anchors.Gladius.arena2 == nil then anchors.Gladius.arena2 = GladiusClassIconFramearena2 or nil end
  				if (unitId == "arena3") and anchors.Gladius.arena3 == nil then anchors.Gladius.arena3 = GladiusClassIconFramearena3 or nil end
  				if (unitId == "arena4") and anchors.Gladius.arena4 == nil then anchors.Gladius.arena4 = GladiusClassIconFramearena4 or nil end
  				if (unitId == "arena5") and anchors.Gladius.arena5 == nil then anchors.Gladius.arena5 = GladiusClassIconFramearena5 or nil end
  				if updateFrame and anchors.Gladius[unitId] ~= nil then
					local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
					local icon = LCframes[unitId]
					local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
					if newAnchor ~= nil and icon.anchor ~= newAnchor then
						icon.anchor = newAnchor
						icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
						icon:ClearAllPoints() -- if we don't do this then the frame won't always move
						icon:GetParent():ClearAllPoints()
						icon:SetWidth(frame.size)
						icon:SetHeight(frame.size)
						icon:GetParent():SetWidth(frame.size)
						icon:SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						icon:GetParent():SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						if icon.anchor:GetParent() then
							icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
						end
						if #frames < 5 then
						print("|cff00ccffLoseControl|r : Successfully Anchored "..unitId.." frame to Gladius")
					  end
					end
				end
			end
			if #frames == 5 then
			print("|cff00ccffLoseControl|r : Successfully Anchored All Arena Frames")
			end
			if gladiusFrame == "on" then
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
		end
	end
end
function LoseControl:CheckGladdyUnitsAnchors(updateFrame)
  if (strfind(self.unitId, "arena")) and LoseControlDB.frames[self.unitId].anchor == "Gladdy" then
    local inInstance, instanceType = IsInInstance();  local gladdyFrame;  local frames = {}
  	if IsAddOnLoaded("Gladdy") and (not anchors.Gladdy[self.unitId]) then
  		if not GladdyButtonFrame1 and instanceType ~= "arena" then
  			gladdyFrame = "on"
  			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
  			if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy test5")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  			else
  				DEFAULT_CHAT_FRAME.editBox:Show()
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy test5")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  				DEFAULT_CHAT_FRAME.editBox:Hide()
  			end
    	end
  		if GladdyButtonFrame1 then frames[1] = "arena1" end
    	if GladdyButtonFrame2 then frames[2] = "arena2" end
  		if GladdyButtonFrame3 then frames[3] = "arena3" end
  		if GladdyButtonFrame4 then frames[4] = "arena4" end
  		if GladdyButtonFrame5 then frames[5] = "arena5" end
  			for _, unitId in pairs(frames) do
  				if (unitId == "arena1") and anchors.Gladdy.arena1 == nil then anchors.Gladdy.arena1 = GladdyButtonFrame1.classIcon or nil end
  				if (unitId == "arena2") and anchors.Gladdy.arena2 == nil then anchors.Gladdy.arena2 = GladdyButtonFrame2.classIcon or nil end
  				if (unitId == "arena3") and anchors.Gladdy.arena3 == nil then anchors.Gladdy.arena3 = GladdyButtonFrame3.classIcon or nil end
  				if (unitId == "arena4") and anchors.Gladdy.arena4 == nil then anchors.Gladdy.arena4 = GladdyButtonFrame4.classIcon or nil end
  				if (unitId == "arena5") and anchors.Gladdy.arena5 == nil then anchors.Gladdy.arena5 = GladdyButtonFrame5.classIcon or nil end
  				if updateFrame and anchors.Gladdy[unitId] ~= nil then
					local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
					local icon = LCframes[unitId]
					local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
					if newAnchor ~= nil and icon.anchor ~= newAnchor then
						icon.anchor = newAnchor
						icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
						icon:ClearAllPoints() -- if we don't do this then the frame won't always move
						icon:GetParent():ClearAllPoints()
						icon:SetWidth(frame.size)
						icon:SetHeight(frame.size)
						icon:GetParent():SetWidth(frame.size)
						icon:SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						icon:GetParent():SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						if icon.anchor:GetParent() then
							icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
						end
						if #frames < 5 then
						print("|cff00ccffLoseControl|r : Successfully Anchored "..unitId.." frame to Gladdy")
					  end
					end
				end
			end
			if #frames == 5 then
			print("|cff00ccffLoseControl|r : Successfully Anchored All Arena Frames")
			end
			if gladdyFrame == "on" then
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
		end
	end
end
-- Initialize a frame's position and register for events
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	local unitId = self.unitId
	self.frame = LoseControlDB.frames[self.fakeUnitId or unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	local inInstance, instanceType = IsInInstance()
  if (instanceType=="arena" or instanceType=="pvp") then LoseControlDB.priority["PvE"] = 0 else LoseControlDB.priority["PvE"] = 10 end --Disables PVE in Arena
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and (
			( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
			( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
		)
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
	)
	if (ShadowUF ~= nil) and not(self:CheckSUFUnitsAnchors(false)) and (self.SUFDelayedSearch == nil) then
		self.SUFDelayedSearch = GetTime()
		Ctimer(8, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckSUFUnitsAnchors(true)
		end)
	end
	if strfind(unitId, "arena") then
	if (Gladius ~= nil) and (self.GladiusDelayedSearch == nil) then
		self.GladiusDelayedSearch = GetTime()
		Ctimer(3, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckGladiusUnitsAnchors(true)
		end)
	end
    if IsAddOnLoaded("Gladdy") and (self.GladdyDelayedSearch == nil) then
    self.GladdyDelayedSearch = GetTime()
    Ctimer(3, function()	-- delay checking to make sure all variables of the other addons are loaded
      self:CheckGladdyUnitsAnchors(true)
    end)
  end
	end
	self.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
	self.unitGUID = UnitGUID(self.unitId)
	self.parent:SetParent(self.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:GetParent():ClearAllPoints()
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:GetParent():SetWidth(frame.size)
	self:GetParent():SetHeight(frame.size)
	self:RegisterUnitEvents(enabled)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	if self.anchor:GetParent() then
		self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
	end
	if self.MasqueGroup then
		self.MasqueGroup:ReSkin()
	end

	SetInterruptIconsSize(self, frame.size)

	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
	self:Hide()
	self:GetParent():Hide()

	if enabled and not self.unlockMode then
		self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 0)
	end
end

function LoseControl:GROUP_ROSTER_UPDATE()
	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "party")) then
		return
	end
	local inInstance, instanceType = IsInInstance()
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and LoseControlDB.disablePartyInBG
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
	)
	self:RegisterUnitEvents(enabled)
	self.unitGUID = UnitGUID(unitId)
	self:CheckSUFUnitsAnchors(true)
	if (frame == nil) or (unitId == nil) and (strfind(unitId, "arena")) then
	self:CheckGladiusUnitsAnchors(true)
  self:CheckGladdyUnitsAnchors(true)
	end
	if enabled and not self.unlockMode then
		self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 0)
	end
end

function LoseControl:GROUP_JOINED()
	self:GROUP_ROSTER_UPDATE()
end

function LoseControl:GROUP_LEFT()
	self:GROUP_ROSTER_UPDATE()
end

local function UpdateUnitAuraByUnitGUID(unitGUID, typeUpdate)
	local inInstance, instanceType = IsInInstance()
	for k, v in pairs(LCframes) do
		local enabled = v.frame.enabled and not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(v.unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(v.unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(v.unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
		)
		if enabled and not v.unlockMode then
			if v.unitGUID == unitGUID then
				v:UNIT_AURA(k, isFullUpdate, updatedAuras, typeUpdate)
				if (k == "player") and LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(k, isFullUpdate, updatedAuras, typeUpdate)
				end
			end
		end
	end
end

function LoseControl:ARENA_OPPONENT_UPDATE()

	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "arena")) then
		return
	end
	local inInstance, instanceType = IsInInstance()
	self:RegisterUnitEvents(
		frame.enabled and not (
			inInstance and instanceType == "pvp" and LoseControlDB.disableArenaInBG
		)
	)
	self.unitGUID = UnitGUID(self.unitId)
	self:CheckSUFUnitsAnchors(true)
	self:CheckGladiusUnitsAnchors(true)
  self:CheckGladdyUnitsAnchors(true)


	if enabled and not self.unlockMode then
		self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 0)
	end
end

function LoseControl:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	self:CheckGladiusUnitsAnchors(true)
  self:CheckGladdyUnitsAnchors(true)
	self:ARENA_OPPONENT_UPDATE()
end


local ArenaSeen = CreateFrame("Frame")
ArenaSeen:RegisterEvent("ARENA_OPPONENT_UPDATE")
ArenaSeen:SetScript("OnEvent", function(self, event, ...)
	local unit, arg2 = ...;
	if (event == "ARENA_OPPONENT_UPDATE") then
	if (unit =="arena1") or (unit =="arena2") or (unit =="arena3") then
		if arg2 == "seen" then
			if UnitExists(unit) then
        if (unit =="arena1") and (GladiusClassIconFramearena1 or GladdyButtonFrame1) then
		      if 	GladiusClassIconFramearena1 then GladiusClassIconFramearena1:SetAlpha(1) end
          if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
				if (unit =="arena2") and (GladiusClassIconFramearena2 or GladdyButtonFrame2) then
          if 	GladiusClassIconFramearena2 then GladiusClassIconFramearena2:SetAlpha(1) end
          if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
				if (unit =="arena3") and (GladiusClassIconFramearena3 or GladdyButtonFrame3) then
          if 	GladiusClassIconFramearena3 then GladiusClassIconFramearena3:SetAlpha(1) end
          if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
			Arenastealth[unit] = nil
			end
		elseif arg2 == "unseen" then
				local guid = UnitGUID(unit)
				UpdateUnitAuraByUnitGUID(guid, -200)
		elseif arg2 == "destroyed" then
			Arenastealth[unit] = nil
		elseif arg2 == "cleared" then
			Arenastealth[unit] = nil
		end
	end
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

-- This event check pvp interrupts and targettarget/focustarget unit aura triggers
function LoseControl:COMBAT_LOG_EVENT_UNFILTERED()
	if self.unitId == "target" then
		-- Check Interrupts
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (destGUID ~= nil) then --Diables Kicks for Player
			if (event == "SPELL_INTERRUPT") then
				local duration = interruptsIds[spellId]
				if (duration ~= nil) then
					local _, destClass = GetPlayerInfoByGUID(destGUID)
					if (destClass == "DRUID") then
						local unitIdFromGUID
						for _, v in pairs(LCframes) do
							if (UnitGUID(v.unitId) == destGUID) then
								unitIdFromGUID = v.unitId
								break
							end
						end
						if (unitIdFromGUID ~= nil) then
							for i = 1, 40 do
								local _, _, _, _, _, _, _, _, _, auxSpellId = UnitBuff(unitIdFromGUID, i)
								if not auxSpellId then break end
								if auxSpellId == 234084 then		-- Moon and Stars (Druid)
									duration = duration * 0.3
									break
								end
							end
						end
					end
					local expirationTime = GetTime() + duration
					if debug then print("interrupt", ")", destGUID, "|", GetSpellInfo(spellId), "|", duration, "|", expirationTime, "|", spellId) end
					local priority = LoseControlDB.priority.Interrupt
					local spellCategory = "Interrupt"
						if (destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3")) then
						priority = LoseControlDB.priorityArena.Interrupt
					  end
					local name, _, icon = GetSpellInfo(spellId)
					if (InterruptAuras[destGUID] == nil) then
						InterruptAuras[destGUID] = {}
					end
					tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
					UpdateUnitAuraByUnitGUID(destGUID, -20)
				end
			elseif (((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and (select(2, GetPlayerInfoByGUID(destGUID)) ~= "HUNTER")) then --may need to use UNIT_AURA check for Fiegn Death here to make more accurate
        if (InterruptAuras[destGUID] ~= nil) then --reset if the source of the kick dies
				InterruptAuras[destGUID] = nil
				UpdateUnitAuraByUnitGUID(destGUID, -21)
		  	end
			end
		end

   	-- Check Channel Interrupts for player
      if (event == "SPELL_CAST_SUCCESS") then
		    if interruptsIds[spellId] then
	        if (destGUID == UnitGUID("player")) and (select(7, UnitChannelInfo("player")) == false) then
           local duration = interruptsIds[spellId]
  			  	if (duration ~= nil) then
  					local expirationTime = GetTime() + duration
  					local priority = LoseControlDB.priority.Interrupt
  					local spellCategory = "Interrupt"
  					local name, _, icon = GetSpellInfo(spellId)
  					if (InterruptAuras[destGUID] == nil) then
  						InterruptAuras[destGUID] = {}
  					end
  					tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
  					UpdateUnitAuraByUnitGUID(destGUID, -20)
  		     end
         end
       end
     end
			-- Check Channel Interrupts for arena
			if (event == "SPELL_CAST_SUCCESS") then
				if interruptsIds[spellId] then
					for i = 1, GetNumArenaOpponents() do
					  if (destGUID == UnitGUID("arena"..i)) and (select(7, UnitChannelInfo("arena"..i)) == false) then
		          local duration = interruptsIds[spellId]
							if (duration ~= nil) then
								local expirationTime = GetTime() + duration
								local priority = LoseControlDB.priorityArena.Interrupt
								local spellCategory = "Interrupt"
								local name, _, icon = GetSpellInfo(spellId)
								if (InterruptAuras[destGUID] == nil) then
									InterruptAuras[destGUID] = {}
								end
								tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
								UpdateUnitAuraByUnitGUID(destGUID, -20)
					    end
					  end
					end
				end
			end
			-- Check Channel Interrupts for party
			if (event == "SPELL_CAST_SUCCESS") then
				if interruptsIds[spellId] then
					for i = 1, GetNumGroupMembers() do
						 if (destGUID == UnitGUID("party"..i)) and (select(7, UnitChannelInfo("party"..i)) == false) then
	            local duration = interruptsIds[spellId]
							if (duration ~= nil) then
								local expirationTime = GetTime() + duration
								local priority = LoseControlDB.priority.Interrupt
								local spellCategory = "Interrupt"
								local name, _, icon = GetSpellInfo(spellId)
								if (InterruptAuras[destGUID] == nil) then
									InterruptAuras[destGUID] = {}
								end
								tblinsert(InterruptAuras[destGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
								UpdateUnitAuraByUnitGUID(destGUID, -20)
	            end
					  end
					end
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Reset Stealth Table if Unit Dies
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and ((destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3"))) then
				if (destGUID == UnitGUID("arena1")) then
					Arenastealth["arena1"] = nil
				elseif (destGUID == UnitGUID("arena2")) then
					Arenastealth["arena2"] = nil
				elseif (destGUID == UnitGUID("arena3")) then
					Arenastealth["arena3"] = nil
				end
			end

      -----------------------------------------------------------------------------------------------------------------
      --[[Earthen Check (Totems Need a Spawn Time Check)
      -----------------------------------------------------------------------------------------------------------------
      if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 198838) then
        if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
            local duration = 15
            local expirationTime = GetTime() + duration
            if (Earthen[sourceGUID] == nil) then  --source is friendly unit party12345 raid1...
              Earthen[sourceGUID] = {}
            end
            Earthen[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
            C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
              if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
              if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
              if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
            end)
            C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
            Earthen[sourceGUID] = nil
            end)
        elseif sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
          local duration = 15
              local guid = destGUID
              local spawnTime
              local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
              if unitType == "Creature" or unitType == "Vehicle" then
              local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
              local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
              spawnTime = spawnEpoch + spawnEpochOffset
              print("Earthen Totem Spawned at: "..spawnTime)
              end
            local expirationTime = GetTime() + duration
            if (Earthen[spawnTime] == nil) then --source becomes the totem ><
              Earthen[spawnTime] = {}
            end
            Earthen[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
            C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
              if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
              if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
              if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
            end)
            C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
            Earthen[spawnTime] = nil
            end)
          end
        end]]

        -----------------------------------------------------------------------------------------------------------------
        --[[Grounding Check (Totems Need a Spawn Time Check)
        -----------------------------------------------------------------------------------------------------------------
        if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 204336) then
          if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
              local duration = 3
              local expirationTime = GetTime() + duration
              if (Grounding[sourceGUID] == nil) then --source is friendly unit party12345 raid1...
                Grounding[sourceGUID] = {}
              end
              Grounding[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
              C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
                if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
                if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
                if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
              end)
              C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
              Grounding[sourceGUID] = nil
              end)
          elseif sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
            local duration = 3
                local guid = destGUID
                local spawnTime
                local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
                if unitType == "Creature" or unitType == "Vehicle" then
                local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
                local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
                spawnTime = spawnEpoch + spawnEpochOffset
                print("Grounding Totem Spawned at: "..spawnTime)
                end
              local expirationTime = GetTime() + duration
              if (Grounding[spawnTime] == nil) then --source becomes the totem ><
                Grounding[spawnTime] = {}
              end
              Grounding[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
              C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
                if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
                if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
                if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
              end)
              C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
              Grounding[spawnTime] = nil
              end)
            end
          end]]

          -----------------------------------------------------------------------------------------------------------------
          --[[WarBanner Check (Totems Need a Spawn Time Check)
          -----------------------------------------------------------------------------------------------------------------
          if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 236320) then
            if sourceGUID then
              local duration = 15
              local expirationTime = GetTime() + duration
              if (WarBanner[sourceGUID] == nil) then --source is friendly unit party12345 raid1...
                WarBanner[sourceGUID] = {}
              end
              WarBanner[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
              C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
                if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
                if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
                if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
              end)
              C_Timer.After(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
              WarBanner[sourceGUID] = nil
              end)
            end
          end
          if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 236320) then
            if destGUID then
              local duration = 15
              local guid = destGUID
              local spawnTime
              local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
              if unitType == "Creature" or unitType == "Vehicle" then
              local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
              local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
              spawnTime = spawnEpoch + spawnEpochOffset
              print("WarBanner Totem Spawned at: "..spawnTime)
              end
            local expirationTime = GetTime() + duration
            if (WarBanner[spawnTime] == nil) then --source becomes the totem ><
              WarBanner[spawnTime] = {}
            end
            WarBanner[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
            C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
              if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
              if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
              if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
            end)
            C_Timer.After(duration +.2, function()	-- execute in some close next frame to accurate use of UnitAura function
            WarBanner[spawnTime] = nil
            end)
          end
        end]]


			-----------------------------------------------------------------------------------------------------------------
			--[[SmokeBomb Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 212182 or spellId == 359053)) then
				if (sourceGUID ~= nil) then
				local duration = 5
				local expirationTime = GetTime() + duration
					if (SmokeBombAuras[sourceGUID] == nil) then
						SmokeBombAuras[sourceGUID] = {}
					end
			  	SmokeBombAuras[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					SmokeBombAuras[sourceGUID] = nil
					end)
			  end
			end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[Barrier Check
      -----------------------------------------------------------------------------------------------------------------
      if ((event == "SPELL_CAST_SUCCESS") and (spellId == 62618)) then
        if (sourceGUID ~= nil) then
        local duration = 10
        local expirationTime = GetTime() + duration
          if (Barrier[sourceGUID] == nil) then
            Barrier[sourceGUID] = {}
          end
          Barrier[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
          Ctimer(duration + 1, function()	-- execute iKn some close next frame to accurate use of UnitAura function
          Barrier[sourceGUID] = nil
          end)
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[SGrounds Check
      -----------------------------------------------------------------------------------------------------------------
      if ((event == "SPELL_CAST_SUCCESS") and (spellId == 34861)) then
        if (sourceGUID ~= nil) then
        local duration = 5
        local expirationTime = GetTime() + duration
          if (SGrounds[sourceGUID] == nil) then
            SGrounds[sourceGUID] = {}
          end
          SGrounds[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
          Ctimer(duration + 1, function()	-- execute iKn some close next frame to accurate use of UnitAura function
          SGrounds[sourceGUID] = nil
          end)
        end
      end]]

			-----------------------------------------------------------------------------------------------------------------
			--[[Root Beam Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 78675)) then
				if (sourceGUID ~= nil) then
					local duration = 8
					local expirationTime = GetTime() + duration
					if (BeamAura[sourceGUID] == nil) then
						BeamAura[sourceGUID] = {}
					end
					BeamAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					BeamAura[sourceGUID] = nil
					end)
				end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--[[Shaodwy Duel Enemy Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 207736)) then
				if sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
					local duration = 5
					local expirationTime = GetTime() + duration
					if (DuelAura[sourceGUID] == nil) then
						DuelAura[sourceGUID] = {}
					end
					if (DuelAura[destGUID] == nil) then
						DuelAura[destGUID] = {}
					end
					DuelAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
					DuelAura[destGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
					--print("cleu enemy Dueled Data Stored destGUID is"..destGUID)
					--print("cleu enemy Dueled Data Stored sourceGUID is"..sourceGUID)
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					DuelAura[sourceGUID] = nil
					DuelAura[destGUID] = nil
					end)
				end
			end]]

		-----------------------------------------------------------------------------------------------------------------
		--CLEU SUMMONS Spell Cast Check (if Cast dies it will not update currently, not sure how to track that)
		-----------------------------------------------------------------------------------------------------------------
		if (((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (cleuPrioCastedSpells[spellId])) then
			local priority, priorityArena, spellCategory, name
      ------------------------------------------Player/Party/Target/Etc-------------------------------------------------------------
			if cleuPrioCastedSpells[spellId].priority == nil then
			 priority = nil
			else
			 priority = LoseControlDB.priority[cleuPrioCastedSpells[spellId].priority]
			 spellCategory = cleuPrioCastedSpells[spellId].priority
			 name = cleuPrioCastedSpells[spellId].name
			end
			------------------------------------------Arena123-----------------------------------------------------------------------------
			if (sourceGUID == UnitGUID("arena1")) or (sourceGUID == UnitGUID("arena2")) or (sourceGUID == UnitGUID("arena3")) then
				if cleuPrioCastedSpells[spellId].priorityArena == nil then
				 priority = nil
				else
				 priority = LoseControlDB.priorityArena[cleuPrioCastedSpells[spellId].priorityArena]
				 spellCategory = cleuPrioCastedSpells[spellId].priorityArena
				 name = cleuPrioCastedSpells[spellId].nameArena
				end
	  	end
			--------------------------------------------------------------------------------------------------------------------------------
			if priority then
				local duration = cleuPrioCastedSpells[spellId].duration
				local expirationTime = GetTime() + duration
				if not InterruptAuras[sourceGUID]  then
						InterruptAuras[sourceGUID] = {}
				end
        if not InterruptAuras[destGUID]  then
						InterruptAuras[destGUID] = {}
				end
				local namePrint, _, icon = GetSpellInfo(spellId)

        if spellId == 58834 or spellId == 58831 or spellId == 58833 then --Mirror IMage
          icon = 135994
        end
        if spellId == 157299 then
          icon = 2065626
        end
        local guid = destGUID
        --print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." LC")
				tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = nil, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint})
				UpdateUnitAuraByUnitGUID(sourceGUID, -20)
        local ticker = 1
        self.ticker = C_Timer.NewTicker(.25, function()
          if InterruptAuras[sourceGUID] then
            for k, v in pairs(InterruptAuras[sourceGUID]) do
    					if v.destGUID then
                if substring(v.destGUID, -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug
                  if ObjectExists(v.destGUID, ticker, v.namePrint, v.sourceName) then
                    print(v.sourceName.." "..ObjectExists(v.destGUID, ticker, v.namePrint, v.sourceName).." "..v.namePrint.." "..substring(v.destGUID, -7).." left w/ "..strformat("%.2f", v.expirationTime-GetTime()).." LC C_Ticker")
                    InterruptAuras[sourceGUID][k] = nil
                    UpdateUnitAuraByUnitGUID(sourceGUID, -20)
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
    --CLEU CASTED AURA Spell Cast Check (if Cast dies it will not update currently, not sure how to track that)
    -----------------------------------------------------------------------------------------------------------------
    if (event == "SPELL_CAST_SUCCESS") and ((spellId == 23989) or (spellId == 14185)) then --Readiness & Prep
      local priority, priorityArena, spellCategory, name
      ------------------------------------------Player/Party/Target/Etc-------------------------------------------------------------
      if cleuPrioCastedSpells[spellId].priority == nil then
       priority = nil
      else
       priority = LoseControlDB.priority[cleuPrioCastedSpells[spellId].priority]
       spellCategory = cleuPrioCastedSpells[spellId].priority
       name = cleuPrioCastedSpells[spellId].name
      end
      ------------------------------------------Arena123-----------------------------------------------------------------------------
      if (sourceGUID == UnitGUID("arena1")) or (sourceGUID == UnitGUID("arena2")) or (sourceGUID == UnitGUID("arena3")) then
        if cleuPrioCastedSpells[spellId].priorityArena == nil then
         priority = nil
        else
         priority = LoseControlDB.priorityArena[cleuPrioCastedSpells[spellId].priorityArena]
         spellCategory = cleuPrioCastedSpells[spellId].priorityArena
         name = cleuPrioCastedSpells[spellId].nameArena
        end
      end
      --------------------------------------------------------------------------------------------------------------------------------
      if priority then
        local duration = cleuPrioCastedSpells[spellId].duration
        local expirationTime = GetTime() + duration
        if not InterruptAuras[sourceGUID]  then
            InterruptAuras[sourceGUID] = {}
        end
        if not InterruptAuras[destGUID]  then
            InterruptAuras[destGUID] = {}
        end
        local namePrint, _, icon = GetSpellInfo(spellId)

        local guid = destGUID
        --print(sourceName.." Casted "..namePrint.." "..substring(destGUID, -7).." for "..duration.." LC")
        tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = nil, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint})
        UpdateUnitAuraByUnitGUID(sourceGUID, -20)
      end
    end

		-----------------------------------------------------------------------------------------------------------------
		--Cold Snap Reset (Resets Block/Barrier/Nova/CoC)
		-----------------------------------------------------------------------------------------------------------------
		if ((sourceGUID ~= nil) and (event == "SPELL_CAST_SUCCESS") and (spellId == 235219)) then
			local needUpdateUnitAura = false
			if (InterruptAuras[sourceGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[sourceGUID]) do
          if v.spellSchool then
  					if (bit_band(v.spellSchool, 16) > 0) then
  						needUpdateUnitAura = true
  						if (v.spellSchool > 16) then
  							InterruptAuras[sourceGUID][k].spellSchool = InterruptAuras[sourceGUID][k].spellSchool - 16
  						else
  							InterruptAuras[sourceGUID][k] = nil
  						end
  					end
          end
				end
				if (next(InterruptAuras[sourceGUID]) == nil) then
					InterruptAuras[sourceGUID] = nil
				end
			end
			if needUpdateUnitAura then
				UpdateUnitAuraByUnitGUID(sourceGUID, -22)
			end
		end

	elseif (self.unitId == "targettarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerTargetTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableTargetTargetTarget) or (self.unitGUID ~= LCframes.target.unitGUID))) or (self.unitId == "focustarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerFocusTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableFocusFocusTarget) or (self.unitGUID ~= LCframes.focus.unitGUID))) then
			-- Manage targettarget/focustarget UNIT_AURA triggers
			local _, event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
			if (destGUID ~= nil and destGUID == self.unitGUID) then
				if (event == "SPELL_AURA_APPLIED") or (event == "SPELL_PERIODIC_AURA_APPLIED") or
				 (event == "SPELL_AURA_REMOVED") or (event == "SPELL_PERIODIC_AURA_REMOVED") or
				 (event == "SPELL_AURA_APPLIED_DOSE") or (event == "SPELL_PERIODIC_AURA_APPLIED_DOSE") or
				 (event == "SPELL_AURA_REMOVED_DOSE") or (event == "SPELL_PERIODIC_AURA_REMOVED_DOSE") or
				 (event == "SPELL_AURA_REFRESH") or (event == "SPELL_PERIODIC_AURA_REFRESH") or
				 (event == "SPELL_AURA_BROKEN") or (event == "SPELL_PERIODIC_AURA_BROKEN") or
				 (event == "SPELL_AURA_BROKEN_SPELL") or (event == "SPELL_PERIODIC_AURA_BROKEN_SPELL") or
				 (event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES") then
					local timeCombatLogAuraEvent = GetTime()
					Ctimer(0.01, function()	-- execute in some close next frame to accurate use of UnitAura function
						if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent ~= timeCombatLogAuraEvent)) then
							self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, 3)
						end
					end)
				end
			end
		end
	end


-- This is the main event. Check for (de)buffs and update the frame icon and cooldown.
function LoseControl:UNIT_AURA(unitId, isFullUpdate, updatedAuras, typeUpdate) -- fired when a (de)buff is gained/lost
	if (((typeUpdate ~= nil and typeUpdate > 0) or (typeUpdate == nil and self.unitId == "targettarget") or (typeUpdate == nil and self.unitId == "focustarget")) and (self.lastTimeUnitAuraEvent == GetTime())) then return end
	if ((self.unitId == "targettarget" or self.unitId == "focustarget") and (not UnitIsUnit(unitId, self.unitId))) then return end
	local priority = LoseControlDB.priority
	local durationType = LoseControlDB.durationType
	local enabled = LoseControlDB.spellEnabled
  local customString = LoseControlDB.customString
	local spellIds = spellIds

	if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
		priority =  LoseControlDB.priorityArena
		durationType =  LoseControlDB.durationTypeArena
		enabled = LoseControlDB.spellEnabledArena
		spellIds = spellIdsArena
	end

	local maxPriority = 1
	local maxExpirationTime = 0
	local newExpirationTime = 0
	local maxPriorityIsInterrupt = false
	local Icon, Duration, Hue, Name, Spell, Count, Text, DispelType
	local LayeredHue = nil
	local forceEventUnitAuraAtEnd = false
	local buffs= {}
	self.lastTimeUnitAuraEvent = GetTime()

	if (self.anchor:IsVisible() or (self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard")) and UnitExists(self.unitId) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetPlayerTargetTarget) or not(UnitIsUnit("player", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetTarget) or not(UnitIsUnit("targettarget", "player")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetTargetTarget) or not(UnitIsUnit("targettarget", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetDeadTargetTarget) or (UnitHealth("target") > 0))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusPlayerFocusTarget) or not(UnitIsUnit("player", "focus") and UnitIsUnit("player", "focustarget")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusTarget) or not(UnitIsUnit("focustarget", "player")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusFocusTarget) or not(UnitIsUnit("focustarget", "focus")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusDeadFocusTarget) or (UnitHealth("focus") > 0))) then
		local reactionToPlayer = ((self.unitId == "target" or self.unitId == "focus" or self.unitId == "targettarget" or self.unitId == "focustarget" or strfind(self.unitId, "arena")) and UnitCanAttack("player", unitId)) and "enemy" or "friendly"
		-- Check debuffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, dispelType, duration, expirationTime, source, _, _, spellId = UnitAura(unitId, i, "HARMFUL")
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (self.unitId == "targettarget") or (self.unitId == "focustarget") then
				if debug then print(unitId, "debuff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end
			end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end
			-----------------------------------------------------------------------------------------------------------------
			--Finds all Snares in game
			-----------------------------------------------------------------------------------------------------------------
			if unitId == "player" and not spellIds[spellId] then
				if GetDebuffText(unitId, i) then
					print("Found New CC SNARE",spellId,"", name,"", snarestring)
					spellIds[spellId] = "Snare"
					local spellCategory = spellIds[spellId]
					local Priority = priority[spellCategory]
					local Name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
					local ZoneName = GetZoneText()
					LoseControlDB.spellEnabled[spellId]= true
					tblinsert(LoseControlDB.customSpellIds, {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex["Snare"]], {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
					local locClass = "Creature"
					if source then
					local guid, name = UnitGUID(source), UnitName(source)
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
						if type == "Creature" then
						 print(name .. "'s NPC id is " .. npc_id)
						elseif type == "Vignette" then
						 print(name .. " is a Vignette and should have its npc_id be zero (" .. npc_id .. ").") --Vignette" refers to NPCs that appear as a rare when you first encounter them, but appear as a common after you've looted them once.
						elseif type == "Player" then
						 local Class, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
						 print(Class.." "..name .. " is a player.")
					  else
						end
						locClass = Class
					else
					end
				end
			end


			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end

			-----------------------------------------------------------------------------------------------------------------
			--[[Enemy Duel
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 207736 then --Shodowey Duel enemy on friendly, friendly frame (red)
				if DuelAura[UnitGUID(unitId)] then --enemyDuel
					name = "EnemyShadowyDuel"
					spellIds[spellId] = "Enemy_Smoke_Bomb"
					--print(unitId.."Duel is Enemy")
					if (UnitGUID(unitId) == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
					spellIds[spellId] = "Special_High"
					end
				else
					--print(UnitGUID(unitId).."Duel is Friendly")
					name = "FriendlyShadowyDuel"
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
					spellIds[spellId] = "Special_High"
					end
	  		end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--[[SmokeBomb Check For Arena
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 212183 then -- Smoke Bomb
				if source and SmokeBombAuras[UnitGUID(source)] then
					--print(source)
					if UnitIsEnemy("player", source) then --still returns true for an enemy currently under mindcontrol I can add your fix.
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Enemy_Smoke_Bomb"
						--print(unitId.."SmokeBombed is enemy check")
							if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
								--print(unitId.."Enemy SmokeBombed in Arean123 check")
								spellIds[spellId] = "Special_High"
							end
						name = "EnemySmokeBomb"
					elseif not UnitIsEnemy("player", source) then --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Friendly_Smoke_Bomb"
							if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
								--print(unitId.."Friendly SmokeBombed on Arean123 check")
								spellIds[spellId] = "Special_High" --
							end
					end
				else
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
						spellIds[spellId] = "Special_High"
					end
				end
			end]]


			-----------------------------------------------------------------------------------------------------------------
			--[[Two debuff conidtions like Root Beam
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 81261 then
				local root = {}
					for i = 1, 40 do
		      local _, _, _, _, d, e, _, _, _, s = UnitAura(unitId, i, "HARMFUL")
					if not s then break end
							if (spellIds[s] == "RootPhyiscal_Special") or (spellIds[s] == "RootMagic_Special") or (spellIds[s] == "Root") or (spellIds[s] == "Roots_90_Snares") then
								tblinsert(root, {["col1"] = e, ["col2"]  = d})
							end
					end
					if #root then
						tblsort(root, cmp_col1)
					end
					if root[1] then
					expirationTime = root[1].col1 + .01
					duration = root[1].col2
						if source and BeamAura[UnitGUID(source)] then
							if (expirationTime - GetTime()) >  (BeamAura[UnitGUID(source)].expirationTime - GetTime()) then
								duration = BeamAura[UnitGUID(source)].duration
								expirationTime =BeamAura[UnitGUID(source)].expirationTime + .01
							end
						end
					end
				end]]

        -----------------------------------------------------------------------------------------------------------------
        --Hide BoneDustBrew if Debuff
        -----------------------------------------------------------------------------------------------------------------
      --[[if spellId == 325216 then
          spellIds[spellId] = "None" --Bonedust Pop on enemy hide
        end]]

        -----------------------------------------------------------------------------------------------------------------
        --[[Hide Surrander if Debuff
        -----------------------------------------------------------------------------------------------------------------
        if spellId == 319952 then
          spellIds[spellId] = "None" --Surrander to Madness Pop on enemy hide
        end]]

        -----------------------------------------------------------------------------------------------------------------
        --Icon Changes
        -----------------------------------------------------------------------------------------------------------------
        if spellId == 45524 then --Chains of Ice Dk
          --icon = 463560
          --icon = 236922
          icon = 236925
        end

        if spellId == 115196 then --Shiv
          icon = 135428
        end


        -----------------------------------------------------------------------------
        --Spell Id same for Friend and Enemey buff/debuff Hacks
        -----------------------------------------------------------------------------
        --[[if spellId == 325216 then
          spellIds[spellId] = "None" --Bonedust pop on enemy hide ,
        end]]

        -----------------------------------------------------------------------------------------------------------------
        --Hue Change
        -----------------------------------------------------------------------------------------------------------------
        if spellId == 320035 then -- Mirros of Torment Haste Reduction
          hue = "Purple"
        end

			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]

			if self.frame.categoriesEnabled.debuff[reactionToPlayer][spellCategory] then
				if Priority then
					-----------------------------------------------------------------------------------------------------------------
					--Unseen Table Debuffs
					-----------------------------------------------------------------------------------------------------------------
					if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
				  if typeUpdate == -200 and UnitExists(unitId) then
						if not Arenastealth[unitId] then
							Arenastealth[unitId] = {}
						end
						--print(unitId, "Debuff Stealth Table Information Captured", name)
						tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory],["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
					end
				  end
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration debuffs
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
						if Priority == maxPriority and expirationTime-duration > newExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              if dispelType then DispelType = dispelType else DispelType = "none" end
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              if dispelType then DispelType = dispelType else DispelType = "none" end
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						end
					elseif durationType[spellCategory] then
						if Priority == maxPriority and expirationTime > maxExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              if dispelType then DispelType = dispelType else DispelType = "none" end
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              if dispelType then DispelType = dispelType else DispelType = "none" end
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						end
					end
				end
			end
		end

		-- Check buffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, dispelType, duration, expirationTime, source, _, _, spellId = UnitAura(unitId, i)
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end
			if debug then print(unitId, "buff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end

      if spellId == 1784 then
        local Vanish
				for i = 1, 40 do
  	      local n, _, _, _, d, e, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if n == "Vanish" then
            local Vanish = true
            break
					end
				end
        if Vanish then
          spellIds[spellId] = "None"
        else
          spellIds[spellId] = "Special_High"
        end
      end


      -----------------------------------------------------------------------------w
			--[[Ghost Wolf hack for Spectral Recovery and Spirit Wolf
			------------------------------------------------------------------------------
      if spellId == 2645 then
        local ghostwolf = {}
        for i = 1, 40 do
        local _, _, c, _, _, _, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
        if not s then break end
          if s == 204262 or s == 260881 then
            tblinsert(ghostwolf, {s, c})
          end
        end
        if #ghostwolf == 2 then
          if ghostwolf[1][1] == 260881 then
            count = ghostwolf[1][2]
          else
            count = ghostwolf[2][2]
          end
          hue = "GhostPurple"
        elseif #ghostwolf == 1 then
          if ghostwolf[1][1] == 260881 then --Just Spirit Wolf
            count = ghostwolf[1][2]
          elseif ghostwolf[1][1] == 204262 then -- Just Spectral Recovery
            hue = "GhostPurple"
          end
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[Barrier Add Timer Check For Arena
      -----------------------------------------------------------------------------------------------------------------
      if spellId == 81782 then -- Barrier
        if source and Barrier[UnitGUID(source)] then
          duration = Barrier[UnitGUID(source)].duration
          expirationTime = Barrier[UnitGUID(source)].expirationTime
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[SGrounds Add Timer Check For Arena
      -----------------------------------------------------------------------------------------------------------------
      if spellId == 289655 then -- SGrounds
        if source and SGrounds[UnitGUID(source)] then
          duration = SGrounds[UnitGUID(source)].duration
          expirationTime = SGrounds[UnitGUID(source)].expirationTime
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[Totems Add Timer Check For Arena
      -----------------------------------------------------------------------------------------------------------------

      if spellId == 201633 then -- Earthen Totem (Totems Need a Spawn Time Check)
        if source and not UnitIsEnemy("player", source) then
          if Earthen[UnitGUID(source)] then
          duration = Earthen[UnitGUID(source)].duration
          expirationTime = Earthen[UnitGUID(source)].expirationTime
          end
        elseif source and UnitIsEnemy("player", source) then
          local guid = UnitGUID(source)
          local spawnTime
          local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
          if unitType == "Creature" or unitType == "Vehicle" then
          local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
          local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
          spawnTime = spawnEpoch + spawnEpochOffset
          --print("Earthen Buff Check at: "..spawnTime)
          end
          if Earthen[spawnTime] then
          duration = Earthen[spawnTime].duration
          expirationTime = Earthen[spawnTime].expirationTime
          end
        end
      end

      if spellId == 8178 then -- Grounding (Totems Need a Spawn Time Check)
        if source and not UnitIsEnemy("player", source) then
          if Grounding[UnitGUID(source)] then
          duration = Grounding[UnitGUID(source)].duration
          expirationTime = Grounding[UnitGUID(source)].expirationTime
          end
        elseif source and UnitIsEnemy("player", source) then
          local guid = UnitGUID(source)
          local spawnTime
          local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
          if unitType == "Creature" or unitType == "Vehicle" then
          local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
          local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
          spawnTime = spawnEpoch + spawnEpochOffset
          --print("Grounding Buff Check at: "..spawnTime)
          end
          if Grounding[spawnTime] then
          duration = Grounding[spawnTime].duration
          expirationTime = Grounding[spawnTime].expirationTime
          end
        end
      end

      if spellId == 236321 then -- Warbanner (Totems Need a Spawn Time Check)
        if source then
          local unitType, _, _, _, _, _, spawnUID = strsplit("-", UnitGUID(source))
          if unitType == "Player" then
            if WarBanner[UnitGUID(source)] then
            duration = WarBanner[UnitGUID(source)].duration
            expirationTime = WarBanner[UnitGUID(source)].expirationTime
            end
          else
            for i, p in ipairs(C_NamePlate.GetNamePlates()) do
              local nameplate = p.namePlateUnitToken
              if nameplate then
                local guid = UnitGUID(nameplate)
                local spawnTime
                local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
                if unitType == "Creature" or unitType == "Vehicle" then
                  local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
                  local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
                  spawnTime = spawnEpoch + spawnEpochOffset
                  --print("WarBanner Buff Check at: "..spawnTime)
                  if WarBanner[spawnTime] then
                  duration = WarBanner[spawnTime].duration
                  expirationTime = WarBanner[spawnTime].expirationTime
                    break
                  end
                end
              end
            end
          end
        end
      end]]
      -----------------------------------------------------------------------------------------------------------------
      --[[]Icon Changes
      -----------------------------------------------------------------------------------------------------------------
      if spellId == 317929 then --Aura Mastery Cast Immune Pally
        icon = 135863
      end

      if spellId == 199545 then --Steed of Glory Hack
    		icon = 135890
    	end

      if spellId == 329543 then --Divine Ascension
        icon = 2103871 --618976 -- or 590341
      end

      if spellId == 328530 then --Divine Ascension
        icon = 2103871 --618976 -- or 590341
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --Hue Change
      -----------------------------------------------------------------------------------------------------------------
      --[[if spellId == 199448 then -- Ultimate Sac Color Change
        hue = "Yellow"
      end]]

			-----------------------------------------------------------------------------
			--[[Mass Invis
			------------------------------------------------------------------------------
			if (spellId == 198158) then --Mass Invis Hack
				if source then
					if (UnitGUID(source) ~= UnitGUID(unitId)) then
						duration = 5
				  	expirationTime = GetTime() + duration
					end
				end
			end]]

      -----------------------------------------------------------------------------
      --[[Player Only Hacks to Disable on party12 or Target, Focus, Pet and Player Frame
      ------------------------------------------------------------------------------
      if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
      else
        if (spellId == 331937) or (spellId == 354054) then --Euphoria Venthyr Haste Buff Hack or Fatal Flaw Versa
  				if unitId ~= "player" then
            spellIds[spellId] = "None"
          else
            spellIds[spellId] = "Movable_Cast_Auras"
  				end
  			end

        if (spellId == 213610) then --Hide Holy Ward
          if unitId == "player" then
            spellIds[spellId] = "None"
          elseif (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
            spellIds[spellId] = "Small_Defensive_CDs"
          else
            spellIds[spellId] = "CC_Reduction"
          end
        end

        if (spellId == 332505) then --Soulsteel Clamps Hack player Only
  				if unitId ~= "player" then
            spellIds[spellId] = "None"
          elseif (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
            spellIds[spellId] = "Small_Defensive_CDs"
          else
            spellIds[spellId] = "Movable_Cast_Auras"
  				end
  			end

        if (spellId == 332506) then --Soulsteel Clamps Hack player Only
  				if unitId ~= "player" then
            spellIds[spellId] = "None"
          elseif (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
            spellIds[spellId] = "Small_Defensive_CDs"
          else
            spellIds[spellId] = "Movable_Cast_Auras"
  				end
  			end
      end]]
      -----------------------------------------------------------------------------
      --[[Same Spell Id , Differnt Spec , Change Prio
      ------------------------------------------------------------------------------

      if (spellId == 31884) then --Avenging Wrath
        local i, specID
        if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
          if strfind(unitId, "1") then i = 1 elseif strfind(unitId, "2") then i = 2 elseif strfind(unitId, "3") then i = 3 	elseif (UnitGUID(unitId) == UnitGUID("arena1")) then i = 1 elseif (UnitGUID(unitId) == UnitGUID("arena2")) then i = 2 elseif (UnitGUID(unitId) == UnitGUID("arena3")) then i = 3 end
    				specID = GetArenaOpponentSpec(i);
          if specID then
            if (specID == 70) or (specID == 66) then
              --print("Ret Wings Active "..unitId)
              spellIds[spellId] = "Big_Defensive_CDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
            else
              --print("Holy Wings Active "..unitId)
              spellIds[spellId] = "Big_Defensive_CDs" --Sets Prio to Holyw Wings to Defensive
            end
          end
        end
      end]]

    --[[if (spellId == 325216) then --BoneDust Brew
        local i, specID
        if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
          if strfind(unitId, "1") then i = 1 elseif strfind(unitId, "2") then i = 2 elseif strfind(unitId, "3") then i = 3 end
          specID = GetArenaOpponentSpec(i);
        elseif (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
          specID = GetInspectSpecialization(unitId)
        end
        if specID then
          if (specID == 269) or (specID == 268) then --Monk: Brewmaster: 268 / Windwalker: 269 / Mistweaver: 270
            --print("WW BoneDust Buff "..unitId)
            spellIds[spellId] = "Melee_Major_OffenisiveCDs" --Ranged_Major_OffenisiveCDs Sets Prio BonedustBrew
          else
            --print("MW BoneDust Buff "..unitId)
            --spellIds[spellId] = "Small_Offenisive_CDs" --Sets Prio to MW BonedustBrew
            spellIds[spellId] = "None"
          end
        end
      end]]

      --[[if (spellId == 310454) then --Weapons of Order
        local i, specID
        if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
          if strfind(unitId, "1") then i = 1 elseif strfind(unitId, "2") then i = 2 elseif strfind(unitId, "3") then i = 3 	elseif (UnitGUID(unitId) == UnitGUID("arena1")) then i = 1 elseif (UnitGUID(unitId) == UnitGUID("arena2")) then i = 2 elseif (UnitGUID(unitId) == UnitGUID("arena3")) then i = 3 end
    				specID = GetArenaOpponentSpec(i);
          if specID then
            if (specID == 269) or (specID == 268) then
              --print("WW Weapons Active "..unitId)
              spellIds[spellId] = "Melee_Major_OffenisiveCDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
            else
              --print("MW Weapons Active "..unitId)
              spellIds[spellId] = "None" --Sets Prio to Holy Wings to Defensive
            end
          end
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[Show Surrander to Madness if Buff
      -----------------------------------------------------------------------------------------------------------------
      if spellId == 319952 then
        spellIds[spellId] = "Ranged_Major_OffenisiveCDs" --Surrander to Madness Pop on enemy hide
        if unitId == "player" then
        spellIds[spellId] = "Personal_Offensives"
        end
      end]]

      -----------------------------------------------------------------------------------------------------------------
      --[[Stack Editing
      -----------------------------------------------------------------------------------------------------------------

      if spellId == 248646 then -- WW Tiger Eye Stacks, Removes Timer
        duration = 0
        expirationTime = GetTime() + 1
      end

      if spellId == 334320 then -- Lock Drain LIfe Stacks, Removes Timer  247676
        duration = 0
        expirationTime = GetTime() + 1
      end

      if spellId == 247676 then -- Reckoning Ret Stacks, Removes Timer
        duration = 0
        expirationTime = GetTime() + 1
      end]]

			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]


			if self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory] then
				if Priority then
					-----------------------------------------------------------------------------------------------------------------
					--Unseen Table Debuffs
					-----------------------------------------------------------------------------------------------------------------
					if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
					if typeUpdate == -200 and UnitExists(unitId) then
						if not Arenastealth[unitId] then
							Arenastealth[unitId] = {}
						end
						--print(unitId, "Buff Stealth Table Information Captured", name)
						tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
					end
			  	end
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration buffs
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
						if Priority == maxPriority and expirationTime-duration > newExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              DispelType = "Buff"
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              DispelType = "Buff"
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						end
					elseif durationType[spellCategory] then
						if Priority == maxPriority and expirationTime > maxExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              DispelType = "Buff"
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
              Spell = spellId
              DispelType = "Buff"
              Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
						end
					end
				end
			end
		end

		-- Check interrupts or cleu
		if ((self.unitGUID ~= nil) and (UnitIsPlayer(unitId) or (((unitId ~= "target") or (LoseControlDB.showNPCInterruptsTarget)) and ((unitId ~= "focus") or (LoseControlDB.showNPCInterruptsFocus)) and ((unitId ~= "targettarget") or (LoseControlDB.showNPCInterruptsTargetTarget)) and ((unitId ~= "focustarget") or (LoseControlDB.showNPCInterruptsFocusTarget))))) then
			local spellSchoolInteruptsTable = {
				[1] = {false, 0},
				[2] = {false, 0},
				[4] = {false, 0},
				[8] = {false, 0},
				[16] = {false, 0},
				[32] = {false, 0},
				[64] = {false, 0}
			}
			if (InterruptAuras[self.unitGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[self.unitGUID]) do
					local Priority = v.priority
					local spellCategory = v.spellCategory
					local expirationTime = v.expirationTime
					local duration = v.duration
					local icon = v.icon
					local spellSchool = v.spellSchool
					local hue = v.hue
					local name = v.name
					local spellId = v.spellId
					if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil; Priority = 0 end
					if spellCategory ~= "Interrupt" and ((Priority == 0) or (not self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory])) then
							if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
							end
					elseif (spellCategory == "Interrupt") and ((Priority == 0) or (not self.frame.categoriesEnabled.interrupt[reactionToPlayer])) then
							if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
							end
					else
						if Priority then
							-----------------------------------------------------------------------------------------------------------------
							--Unseen Table Debuffs
							-----------------------------------------------------------------------------------------------------------------
							if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
							if typeUpdate == -200 and UnitExists(unitId) then
								if not Arenastealth[unitId] then
									Arenastealth[unitId] = {}
								end
								--print(unitId, "cleu Stealth Table Information Captured", name)
								local localForceEventUnitAuraAtEnd = false
								tblinsert(Arenastealth[unitId],  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
							end
				  		end
							---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
							local localForceEventUnitAuraAtEnd = false
							tblinsert(buffs,  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue }}) -- this will create a table to show the highest duration cleu
							---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
							if spellSchool then -- Stop Interrupt Check when Trees Prio or SPELL_CAST_SUCCESS event
								for schoolIntId, _ in pairs(spellSchoolInteruptsTable) do
									if (bit_band(spellSchool, schoolIntId) > 0) then
										spellSchoolInteruptsTable[schoolIntId][1] = true
										if expirationTime > spellSchoolInteruptsTable[schoolIntId][2] then
											spellSchoolInteruptsTable[schoolIntId][2] = expirationTime
										end
									end
								end
							end
							if not durationType[spellCategory] then
								if Priority == maxPriority and expirationTime-duration > newExpirationTime then
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
                  DispelType = "CLEU"
                  Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								elseif Priority > maxPriority then
									maxPriority = Priority
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
                  DispelType = "CLEU"
                  Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								end
							elseif durationType[spellCategory] then
								if Priority == maxPriority and expirationTime > maxExpirationTime then
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
                  DispelType = "CLEU"
                  Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								elseif Priority > maxPriority then
									maxPriority = Priority
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
                  DispelType = "CLEU"
                  Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								end
							end
						end
					end
				end
			end
			if _G.LoseControlDB.InterruptIcons then
				for schoolIntId, schoolIntFrame in pairs(self.iconInterruptList) do
					if spellSchoolInteruptsTable[schoolIntId][1] then
						if (not schoolIntFrame:IsShown()) then
							schoolIntFrame:Show()
						end
						local orderInt = 1
						for schoolInt2Id, schoolInt2Info in pairs(spellSchoolInteruptsTable) do
							if ((schoolInt2Info[1]) and ((spellSchoolInteruptsTable[schoolIntId][2] < schoolInt2Info[2]) or ((spellSchoolInteruptsTable[schoolIntId][2] == schoolInt2Info[2]) and (schoolIntId > schoolInt2Id)))) then
								orderInt = orderInt + 1
							end
						end
						schoolIntFrame:SetPoint("BOTTOMRIGHT", self.interruptIconOrderPos[orderInt][1], self.interruptIconOrderPos[orderInt][2])
						schoolIntFrame.interruptIconOrder = orderInt
					elseif schoolIntFrame:IsShown() then
						schoolIntFrame.interruptIconOrder = nil
						schoolIntFrame:Hide()
					end
				end
			end
		end
	end

----------------------------------------------------------------------
--Filters for highest aura duration of specfied priority will not work for cleu , currently set for all snares
----------------------------------------------------------------------
	if #buffs then
		tblsort(buffs, cmp_col1)
		tblsort(buffs, cmp_col1_col2)
	end

----------------------------------------------------------------------
--transfer stealth table to buffs
----------------------------------------------------------------------
if Arenastealth[unitId] and (not UnitExists(unitId)) then
	for i = 1, #Arenastealth[unitId] do
	  buffs[i] =  {["col1"] = Arenastealth[unitId][i].col1 , ["col2"]  = Arenastealth[unitId][i].col2 , ["col3"] = { ["name"] = Arenastealth[unitId][i].col3.name, ["duration"] = Arenastealth[unitId][i].col3.duration, ["expirationTime"] = Arenastealth[unitId][i].col3.expirationTime,  ["icon"] = Arenastealth[unitId][i].col3.icon, ["localForceEventUnitAuraAtEnd"] = Arenastealth[unitId][i].col3.localForceEventUnitAuraAtEnd, ["hue"] = Arenastealth[unitId][i].col3.hue }}
	end
	tblsort(buffs, cmp_col1)
	tblsort(buffs, cmp_col1_col2)
end

-----------------------------------------------------------------------
--Stealth Filter What to show while unseen Arena Opponents
-------------------------------------------------------------------------
	if (not UnitExists(unitId)) then
		if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
			 if Arenastealth[unitId] and #buffs then
				 local foundbuff = 0
				 for i = 1, #buffs do
					 	if ((buffs[i].col3.expirationTime > GetTime() + .10) and (buffs[i].col3.duration ~= 0 ) and (buffs[i].col1 >= priority.Special_High)) then --Special_High is Stealth for Arena
								maxExpirationTime = buffs[i].col3.expirationTime
								Duration = buffs[i].col3.duration
								Icon = buffs[i].col3.icon
								forceEventUnitAuraAtEnd = false
								Hue = buffs[i].col3.hue
								Name = buffs[i].col3.name
								local nextTimerUpdate = (buffs[i].col3.expirationTime - GetTime()) + 0.05
								if nextTimerUpdate < 0.05 then
									nextTimerUpdate = 0.05
								end
								Ctimer(nextTimerUpdate, function()
										self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, -5)
								end)
								foundbuff = 1
								print(unitId, "Unseen or Stealth w/", buffs[i].col3.name)
								break
							elseif ((buffs[i].col1 == priority.Special_High) or (buffs[i].col3.name == "FriendlyShadowyDuel") or (buffs[i].col3.name == "EnemyShadowyDuel")) then --and ((duration == 0) or (buffs[i].col3.expirationTime < (GetTime() + .10))) then
								maxExpirationTime = GetTime() + 1
								Duration = 0
								Icon = buffs[i].col3.icon
								forceEventUnitAuraAtEnd = false
								Hue = buffs[i].col3.hue
								Name = buffs[i].col3.name
								foundbuff = 1
								print(unitId, "Permanent Stealthed w/", buffs[i].col3.name)
								break
							end
						end
						if foundbuff == 0 then
							maxExpirationTime = 0
							Duration = Duration
							Icon = Icon
							forceEventUnitAuraAtEnd = forceEventUnitAuraAtEnd
							Hue = Hue
							Name = Name
							print(unitId, "No Stealth Buff Found")
							if unitId == "arena1" and GladiusClassIconFramearena1 and GladiusHealthBararena1 then
								GladiusClassIconFramearena1:SetAlpha(GladiusHealthBararena1:GetAlpha())
                if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(GladiusHealthBararena1:GetAlpha()) end
							end
							if unitId == "arena2" and GladiusClassIconFramearena2 and GladiusHealthBararena2 then
								GladiusClassIconFramearena2:SetAlpha(GladiusHealthBararena2:GetAlpha())
                if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(GladiusHealthBararena2:GetAlpha()) end
							end
							if unitId == "arena3" and GladiusClassIconFramearena3 and GladiusHealthBararena3 then
								GladiusClassIconFramearena3:SetAlpha(GladiusHealthBararena3:GetAlpha())
                if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(GladiusHealthBararena3:GetAlpha()) end
							end
            end
					end
		    end
		  end


  	for i = 1, #buffs do --creates a layered hue for every icon when a specific priority, or spellid is present
  		if not buffs[i] then break end
  			if (buffs[i].col3.name == "EnemySmokeBomb") or (buffs[i].col3.name == "EnemyShadowyDuel") then --layered hue conidition
  				if buffs[i].col3.expirationTime > GetTime() then
  					if LoseControlDB.RedSmokeBomb then
  					LayeredHue = true
  					Hue = "Red"
  					end
  				local remaining = buffs[i].col3.expirationTime - GetTime() -- refires on layer exit, to reset the icons
  				if  remaining  < 0.05 then
  					 remaining  = 0.05
  				end
  				Ctimer(remaining + .05, function() self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, -55) end)
  				end
  			end
  		end
  	if (maxExpirationTime == 0) then -- no (de)buffs found
  		self.maxExpirationTime = 0
  		if self.anchor ~= UIParent and self.drawlayer then
  			self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer
  		end
  		if self.iconInterruptBackground:IsShown() then
  			self.iconInterruptBackground:Hide()
  		end
  		if self.gloss:IsShown() then
  			self.gloss:Hide()
  		end
      if self.count:IsShown() then
      self.count:Hide()
      end
  		self:Hide()
  		self:GetParent():Hide()
      self.spellCategory = spellIds[Spell]
  	elseif maxExpirationTime ~= self.maxExpirationTime or ((LayeredHue) or (typeUpdate == -55) or (not UnitExists(unitId)))  then -- this is a different (de)buff, so initialize the cooldown
  		self.maxExpirationTime = maxExpirationTime
  		if self.anchor ~= UIParent then
  			self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard") and 3 or 0)) -- must be dynamic, frame level changes all the time
  			if not self.drawlayer and self.anchor.GetDrawLayer then
  				self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
  			end
  			if self.drawlayer and self.anchor.SetDrawLayer then
  				self.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
  			end
  		end

  		if LoseControlDB.EnableGladiusGloss and (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3")  or (self.unitId == "arena4") or (self.unitId == "arena5") and (self.frame.anchor == "Gladius" or self.frame.anchor == "Gladdy") then
  			self.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
  			self.gloss.normalTexture = _G[self.gloss:GetName().."NormalTexture"]
  			self.gloss.normalTexture:SetHeight(self.frame.size)
  			self.gloss.normalTexture:SetWidth(self.frame.size)
        if self.frame.anchor == "Gladdy" then
          self.gloss.normalTexture:SetScale(.81) --.81 for Gladdy
        else
          self.gloss.normalTexture:SetScale(.9) --.81 for Gladdy
        end
  			self.gloss.normalTexture:ClearAllPoints()
  			self.gloss.normalTexture:SetPoint("CENTER", self, "CENTER")
  			self.gloss:SetNormalTexture("Interface\\AddOns\\LoseControl\\Textures\\Gloss")
  			self.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
  			self.gloss:SetFrameLevel((self:GetParent():GetFrameLevel()) + 10)
  			if (not self.gloss:IsShown()) then
  				self.gloss:Show()
  			end
  		else
  			if self.gloss:IsShown() then
  				self.gloss:Hide()
  			end
  		end

      if Count then
          if (unitId == "player" or unitId == "party1" or unitId == "party2" or unitId == "party3" or unitId == "party4") and not ((unitId == "player") and (self.frame.anchor == "Blizzard")) then
           if ( Count > 1 ) then
            local countText = Count
            if ( Count >= 100 ) then
             countText = BUFF_STACKS_OVERFLOW
            end
            self.count:ClearAllPoints()
            self.count:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE, MONOCHROME")
            self.count:SetPoint("TOPRIGHT", -1, 8);
            self.count:SetJustifyH("RIGHT");
            self.count:Show();
            self.count:SetText(countText)
           else
            if self.count:IsShown() then
              self.count:Hide()
            end
           end
        elseif (unitId == "arena1" or unitId == "arena2" or unitId == "arena3") and (self.frame.anchor == "Gladius" or self.frame.anchor == "Gladdy") then
          if ( Count > 1 ) then
           local countText = Count
           if ( Count >= 100 ) then
            countText = BUFF_STACKS_OVERFLOW
           end
           self.count:ClearAllPoints()
           self.count:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, MONOCHROME")
           self.count:SetPoint("BOTTOMRIGHT", 0, 0);
           self.count:SetJustifyH("RIGHT");
           self.count:Show();
           self.count:SetText(countText)
          else
           if self.count:IsShown() then
             self.count:Hide()
           end
          end
         end
      else
        if self.count:IsShown() then
          self.count:Hide()
        end
      end

      local inInstance, instanceType = IsInInstance()
      if (instanceType == "arena" or instanceType == "pvp") and LoseControlDB.ArenaPlayerText then
        --Do Nothing
      else
        if Text and unitId == "player" and self.frame.anchor ~= "Blizzard" and LoseControlDB.PlayerText  then
          self.Ltext:SetText(Text)
          self.Ltext:Show()
          if LoseControlDB.displayTypeDot then
            self.dispelTypeframe.tex:SetDesaturated(nil)
            self.dispelTypeframe.tex:SetVertexColor(colorTypes[DispelType][1], colorTypes[DispelType][2], colorTypes[DispelType][3]);
            if self.Ltext:GetStringHeight() < 16 then
              self.dispelTypeframe:SetPoint("CENTER", LoseControlplayer, "CENTER", -self.Ltext:GetStringWidth()/2 - 4, -30)
            else
              self.dispelTypeframe:SetPoint("CENTER", LoseControlplayer, "CENTER", -self.Ltext:GetStringWidth()/2 - 4, -30 - 6.5)
            end
          end
        else
          if self.Ltext:IsShown() then
            self.Ltext:Hide()
          end
        end
      end

  		if maxPriorityIsInterrupt then
  			if self.frame.anchor == "Blizzard" then
  				if LoseControlDB.InterruptOverlay and interruptsIds[Spell] then
  				self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait") --CHRIS
  				end
  			else
  				if LoseControlDB.InterruptOverlay and interruptsIds[Spell] then
  				self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background") --CHRIS
  				end
  			end
  			if (not self.iconInterruptBackground:IsShown()) then
  				self.iconInterruptBackground:Show()
  			end
  		else
  			if self.iconInterruptBackground:IsShown() then
  				self.iconInterruptBackground:Hide()
  			end
  		end
  		if not interruptsIds[Spell] then
  			if self.iconInterruptBackground:IsShown() then
  				self.iconInterruptBackground:Hide()
  			end
  		end
  		if self.frame.anchor == "Blizzard" then  --CHRIS DISABLE SQ
        if Hue then
          if Hue == "Red" then -- Changes Icon Hue to Red
            SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
            self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
            SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
            self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
            self.texture:SetDesaturated(nil) --Destaurate  Icon
            self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
            SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
            self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate  Icon
            self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
            SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
            self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Smoke Bomb Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
            SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
            self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(.65, .5, .9);  --Purple Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          end
        else
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a filHuee applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
          self.texture:SetDesaturated(nil) --Destaurate Icon
          self.texture:SetVertexColor(1, 1, 1)
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        end
  		else
        if Hue then
          if Hue == "Red" then -- Changes Icon Hue to Red
            self.texture:SetTexture(Icon)   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
            self.texture:SetTexture(Icon)   --SetIcon
            self.texture:SetDesaturated(nil) --Destaurate Icon
            self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
            self.texture:SetTexture(Icon)   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
            self.texture:SetTexture(Icon)   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
            self.texture:SetTexture(Icon)   --Set Icon
            self.texture:SetDesaturated(1) --Destaurate Icon
            self.texture:SetVertexColor(.65, .5, .9); --Purple Hue Set For Icon
            self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
          end
        else
          self.texture:SetTexture(Icon)
          self.texture:SetDesaturated(nil) --Destaurate Icon
          self.texture:SetVertexColor(1, 1, 1)
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        end
  		end
  		if forceEventUnitAuraAtEnd and maxExpirationTime > 0 and Duration > 0 then
  			local nextTimerUpdate = maxExpirationTime - GetTime() + 0.10
  			if nextTimerUpdate < 0.10 then
  				nextTimerUpdate = 0.10
  			end
  			Ctimer(nextTimerUpdate, function()
  				if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.08))) then
  					self:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 4)
  				end
  			end)
  		end
      if Spell and Spell == 199448 then --Ultimate Sac Glow
        ActionButton_ShowOverlayGlow(self)
      else
        ActionButton_HideOverlayGlow(self)
      end
      self.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
      self.spellCategory = spellIds[Spell]
      self.Priority = priority[self.spellCategory]
  		self:Show()
  		self:GetParent():Show()
      if Duration > 0 then
  			if not self:GetDrawSwipe() then
  				self:SetDrawSwipe(false) --SET TO FALSE TO DISABLE DRAWSWIPE , ADD OPTION FOR THIS
  			end
        if (maxExpirationTime - GetTime()) > (9*60+59) then
          self:SetCooldown(GetTime(), 0)
          self:SetCooldown(GetTime(), 0)
        else
  		     self:SetCooldown( maxExpirationTime - Duration, Duration )
        end
  		else
  			if self:GetDrawSwipe() then
  				if LoseControlDB.DrawSwipeSetting > 0 then
  				self:SetDrawSwipe(true)
  				else
  				self:SetDrawSwipe(false)
  				end
  			end
  			self:SetCooldown(GetTime(), 0)
  			self:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
  		end
      if (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3") or (self.unitId == "arena4") or (self.unitId == "arena5") then --Chris sets alpha timer/frame inherot of frame of selected units
        if self.frame.anchor == "Gladius" then
          self:GetParent():SetAlpha(self.anchor:GetAlpha())
          if (not UnitExists(unitId)) then
            if unitId == "arena1" and GladiusClassIconFramearena1 then
              self:GetParent():SetAlpha(0.8)
              GladiusClassIconFramearena1:SetAlpha(0)
              --if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(0) end
            end
            if unitId == "arena2" and GladiusClassIconFramearena2 then
              self:GetParent():SetAlpha(0.8)
              GladiusClassIconFramearena2:SetAlpha(0)
              --if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(0) end
            end
            if unitId == "arena3" and GladiusClassIconFramearena3 then
              self:GetParent():SetAlpha(0.8)
              GladiusClassIconFramearena3:SetAlpha(0)
              --if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(0) end
            end
          end
        end
      else
        self:GetParent():SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
    end
  end
  if unitId == "player" and LoseControlDB.SilenceIcon then
    if self.Priority and self.Priority > LoseControlDB.priority["Silence"] then
      LoseControl:Silence(LoseControlplayer)
    else
      if playerSilence then playerSilence:Hide() end
    end
  end
end




function LoseControl:Silence(frame)
  if not playerSilence then
    local playerSilence = CreateFrame("Frame", "playerSilence", frame)
    playerSilence:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 1, 0)
    playerSilence:SetWidth(frame:GetWidth()-5)
    playerSilence:SetHeight(frame:GetHeight()-5)
    playerSilence.texture = playerSilence:CreateTexture(nil, "BACKGROUND")
    playerSilence.texture:SetAllPoints(true)
    playerSilence.cooldown = CreateFrame("Cooldown", nil,   playerSilence, 'CooldownFrameTemplate')
    playerSilence.cooldown:SetAllPoints(playerSilence)
    playerSilence.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
    playerSilence.cooldown:SetDrawSwipe(true)
    playerSilence.cooldown:SetDrawEdge(false)
    playerSilence.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
    playerSilence.cooldown:SetReverse(false) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
    playerSilence.cooldown:SetDrawBling(false)
    playerSilence.Ltext = playerSilence:CreateFontString(nil, "ARTWORK")
    playerSilence.Ltext:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    playerSilence.Ltext:SetParent(playerSilence)
    playerSilence.Ltext:SetJustifyH("CENTER")
    playerSilence.Ltext:SetTextColor(1, 1, 1, 1)
    playerSilence.Ltext:SetPoint("TOP", playerSilence, "BOTTOM")
  end
  local Icon, Duration, maxPriority, maxExpirationTime
  local maxPriority = 1
  local maxExpirationTime = 0
  local priority = LoseControlDB.priority
  for i = 1, 40 do
    local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura("player", i, "HARMFUL")
    if duration == 0 and expirationTime == 0 then
      expirationTime = GetTime() + 1 -- normal expirationTime = 0
    end
    local spellCategory = spellIds[spellId] or spellIds[name]
    local Priority = priority[spellCategory]
    if spellCategory == "Silence" then
      if expirationTime > maxExpirationTime then
        maxExpirationTime = expirationTime
        Duration = duration
        Icon = icon
      end
    end
  end
  for i = 1, 40 do
    local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura("player", i, "HELPFUL")
    if duration == 0 and expirationTime == 0 then
      expirationTime = GetTime() + 1 -- normal expirationTime = 0
    end
    local spellCategory = spellIds[spellId] or spellIds[name]
    local Priority = priority[spellCategory]
    if spellCategory == "Silence" then
      if expirationTime > maxExpirationTime then
        maxExpirationTime = expirationTime
        Duration = duration
        Icon = icon
      end
    end
  end
  if maxExpirationTime == 0 then
    playerSilence.maxExpirationTime = 0
    playerSilence:Hide()
  elseif maxExpirationTime then
    playerSilence.maxExpirationTime = maxExpirationTime
    if LoseControlDB.DrawSwipeSetting > 0 then
      playerSilence.cooldown:SetDrawSwipe(true)
    else
      playerSilence.cooldown:SetDrawSwipe(false)
    end
    playerSilence.texture:SetTexture(Icon)
    playerSilence.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
    if Duration > 0 then
      if (maxExpirationTime - GetTime()) > (9*60+59) then
        playerSilence.cooldown:SetCooldown(GetTime(), 0)
        playerSilence.cooldown:SetCooldown(GetTime(), 0)
      else
         playerSilence.cooldown:SetCooldown( maxExpirationTime - Duration, Duration )
      end
    else
      if playerSilence.cooldown:GetDrawSwipe() then
        if LoseControlDB.DrawSwipeSetting > 0 then
        playerSilence.cooldown:SetDrawSwipe(true)
        else
        playerSilence.cooldown:SetDrawSwipe(false)
        end
      end
      playerSilence.cooldown:SetCooldown(GetTime(), 0)
      playerSilence.cooldown:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
    end
    local inInstance, instanceType = IsInInstance()
    playerSilence:Show()
  end
end





function LoseControl:PLAYER_FOCUS_CHANGED()
	--if (debug) then print("PLAYER_FOCUS_CHANGED") end
	if (self.unitId == "focus" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -10)
		end
	end
end

function LoseControl:PLAYER_TARGET_CHANGED()
	--if (debug) then print("PLAYER_TARGET_CHANGED") endw
	if (self.unitId == "target" or self.unitId == "targettarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -11)
		end
	end
end

function LoseControl:UNIT_TARGET(unitId)
	--if (debug) then print("UNIT_TARGET", unitId) end
	if (self.unitId == "targettarget" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -12)
		end
	end
end

function LoseControl:UNIT_PET(unitId)
	--if (debug) then print("UNIT_PET", unitId) end
	if (self.unitId == "pet") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, isFullUpdate, updatedAuras, -13)
		end
	end
end

-- Handle mouse dragging
function LoseControl:StopMoving()
	local frame = LoseControlDB.frames[self.unitId]
	frame.point, frame.anchor, frame.relativePoint, frame.x, frame.y = self:GetPoint()
	if not frame.anchor then
		frame.anchor = "None"
		local AnchorDropDown = _G['LoseControlOptionsPanel'..self.unitId..'AnchorDropDown']
		if (AnchorDropDown) then
			UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		end
		if self.MasqueGroup then
			self.MasqueGroup:RemoveButton(self:GetParent())
			self.MasqueGroup:AddButton(self:GetParent(), {
				FloatingBG = false,
				Icon = self.texture,
				Cooldown = self,
				Flash = _G[self:GetParent():GetName().."Flash"],
				Pushed = self:GetParent():GetPushedTexture(),
				Normal = self:GetParent():GetNormalTexture(),
				Disabled = self:GetParent():GetDisabledTexture(),
				Checked = false,
				Border = _G[self:GetParent():GetName().."Border"],
				AutoCastable = false,
				Highlight = self:GetParent():GetHighlightTexture(),
				Hotkey = _G[self:GetParent():GetName().."HotKey"],
				Count = _G[self:GetParent():GetName().."Count"],
				Name = _G[self:GetParent():GetName().."Name"],
				Duration = false,
				Shine = _G[self:GetParent():GetName().."Shine"],
			}, "Button", true)
		end
	end
	self.anchor = _G[anchors[frame.anchor][self.unitId]] or (type(anchors[frame.anchor][self.unitId])=="table" and anchors[frame.anchor][self.unitId] or UIParent)
	self:ClearAllPoints()
	self:GetParent():ClearAllPoints()
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	if self.MasqueGroup then
		self.MasqueGroup:ReSkin()
	end
	self:StopMovingOrSizing()
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown", addonName .. unitId, nil, 'CooldownFrameTemplate') --, UIParent)
	local op = CreateFrame("Button", addonName .. "ButtonParent" .. unitId, nil, 'ActionButtonTemplate')
	op:EnableMouse(false)
	if op:GetPushedTexture() ~= nil then op:GetPushedTexture():SetAlpha(0) op:GetPushedTexture():Hide() end
	if op:GetNormalTexture() ~= nil then op:GetNormalTexture():SetAlpha(0) op:GetNormalTexture():Hide() end
	if op:GetDisabledTexture() ~= nil then op:GetDisabledTexture():SetAlpha(0) op:GetDisabledTexture():Hide() end
	if op:GetHighlightTexture() ~= nil then op:GetHighlightTexture():SetAlpha(0) op:GetHighlightTexture():Hide() end
	if _G[op:GetName().."Shine"] ~= nil then _G[op:GetName().."Shine"]:SetAlpha(0) _G[op:GetName().."Shine"]:Hide() end
	if _G[op:GetName().."Count"] ~= nil then _G[op:GetName().."Count"]:SetAlpha(0) _G[op:GetName().."Count"]:Hide() end
	if _G[op:GetName().."HotKey"] ~= nil then _G[op:GetName().."HotKey"]:SetAlpha(0) _G[op:GetName().."HotKey"]:Hide() end
	if _G[op:GetName().."Flash"] ~= nil then _G[op:GetName().."Flash"]:SetAlpha(0) _G[op:GetName().."Flash"]:Hide() end
	if _G[op:GetName().."Name"] ~= nil then _G[op:GetName().."Name"]:SetAlpha(0) _G[op:GetName().."Name"]:Hide() end
	if _G[op:GetName().."Border"] ~= nil then _G[op:GetName().."Border"]:SetAlpha(0) _G[op:GetName().."Border"]:Hide() end
	if _G[op:GetName().."Icon"] ~= nil then _G[op:GetName().."Icon"]:SetAlpha(0) _G[op:GetName().."Icon"]:Hide() end


	setmetatable(o, self)
	self.__index = self

	o:SetParent(op)
	o.parent = op

	o.Ltext = o:CreateFontString(nil, "ARTWORK")
	o.Ltext:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	o.Ltext:SetParent(o)
	o.Ltext:SetJustifyH("CENTER")
	o.Ltext:SetTextColor(1, 1, 1, 1)
  o.Ltext:SetPoint("TOP", o, "BOTTOM")

  if unitId == "player" then
    o.dispelTypeframe  = CreateFrame("Frame", addonName .. "dispelTypeframe" .. unitId, o)
    o.dispelTypeframe:ClearAllPoints()
    o.dispelTypeframe:SetHeight(5)
    o.dispelTypeframe:SetWidth(5)
    o.dispelTypeframe:SetAlpha(1)
    o.dispelTypeframe:SetFrameLevel(3)
    o.dispelTypeframe:SetFrameStrata("MEDIUM")
    o.dispelTypeframe:EnableMouse(false)
    o.dispelTypeframe.tex = o.dispelTypeframe:CreateTexture()
    o.dispelTypeframe.tex:SetAllPoints(o.dispelTypeframe)
    SetPortraitToTexture(o.dispelTypeframe.tex, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
    o.dispelTypeframe.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  end

	o:SetDrawEdge(false)

	-- Init class members
	if unitId == "player2" then
		o.unitId = "player" -- ties the object to a unit
		o.fakeUnitId = unitId
	else
		o.unitId = unitId -- ties the object to a unit
	end
	o:SetAttribute("unit", o.unitId)
	o.texture = o:CreateTexture(nil, "BORDER") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	o.text = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	o.text:SetText(L[o.unitId])
	o.text:SetPoint("BOTTOM", o, "BOTTOM")
	o.text:Hide()

  o.count = o.CreateFontString(o, "OVERLAY", "GameFontWhite");
  o.count:Hide()


-----------------------------------------------------------------------------------

	o:Hide()
	op:Hide()

	o.gloss = CreateFrame("Button", addonName .. "Gloss" .. unitId, nil, 'ActionButtonTemplate')
--	o.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
--	o.gloss.normalTexture = _G[o.gloss:GetName().."NormalTexture"]
--	o.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
	o.gloss:Hide()

	-- Create and initialize Interrupt Mini Icons
	o.iconInterruptBackground = o:CreateTexture(addonName .. unitId .. "InterruptIconBackground", "ARTWORK", nil, -2)
	--o.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background")
	o.iconInterruptBackground:SetAlpha(0.7)
	o.iconInterruptBackground:SetPoint("TOPLEFT", 0, 0)
	o.iconInterruptBackground:Hide()
	o.iconInterruptPhysical = o:CreateTexture(addonName .. unitId .. "InterruptIconPhysical", "ARTWORK", nil, -1)
	o.iconInterruptPhysical:SetTexture("Interface\\Icons\\Ability_meleedamage")
	o.iconInterruptHoly = o:CreateTexture(addonName .. unitId .. "InterruptIconHoly", "ARTWORK", nil, -1)
	o.iconInterruptHoly:SetTexture("Interface\\Icons\\Spell_holy_holybolt")
	o.iconInterruptFire = o:CreateTexture(addonName .. unitId .. "InterruptIconFire", "ARTWORK", nil, -1)
	o.iconInterruptFire:SetTexture("Interface\\Icons\\Spell_fire_selfdestruct")
	o.iconInterruptNature = o:CreateTexture(addonName .. unitId .. "InterruptIconNature", "ARTWORK", nil, -1)
	o.iconInterruptNature:SetTexture("Interface\\Icons\\Spell_nature_protectionformnature")
	o.iconInterruptFrost = o:CreateTexture(addonName .. unitId .. "InterruptIconFrost", "ARTWORK", nil, -1)
	o.iconInterruptFrost:SetTexture("Interface\\Icons\\Spell_frost_icestorm")
	o.iconInterruptShadow = o:CreateTexture(addonName .. unitId .. "InterruptIconShadow", "ARTWORK", nil, -1)
	o.iconInterruptShadow:SetTexture("Interface\\Icons\\Spell_shadow_antishadow")
	o.iconInterruptArcane = o:CreateTexture(addonName .. unitId .. "InterruptIconArcane", "ARTWORK", nil, -1)
	o.iconInterruptArcane:SetTexture("Interface\\Icons\\Spell_nature_wispsplode")
	o.iconInterruptList = {
		[1] = o.iconInterruptPhysical,
		[2] = o.iconInterruptHoly,
		[4] = o.iconInterruptFire,
		[8] = o.iconInterruptNature,
		[16] = o.iconInterruptFrost,
		[32] = o.iconInterruptShadow,
		[64] = o.iconInterruptArcane
	}
	for _, v in pairs(o.iconInterruptList) do
		v:SetAlpha(.8) --hide Interrupt Icons
		v:Hide()
		SetPortraitToTexture(v, v:GetTexture())
		v:SetTexCoord(0.08,0.92,0.08,0.92)
	end

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function

	o:RegisterEvent("PLAYER_ENTERING_WORLD")
	o:RegisterEvent("GROUP_ROSTER_UPDATE")
	o:RegisterEvent("GROUP_JOINED")
	o:RegisterEvent("GROUP_LEFT")
	o:RegisterEvent("ARENA_OPPONENT_UPDATE")
	--o:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

	return o
end

-- Create new object instance for each frame
for k in pairs(DBdefaults.frames) do
	if (k ~= "player2") then
		LCframes[k] = LoseControl:new(k)
	end
end
LCframeplayer2 = LoseControl:new("player2")

-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = addonName .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(addonName)

local unlocknewline = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
unlocknewline:SetText("If a icon is Anchored, the Anchor must be showing, find a Target, TargetofTarget, FocusTarget ,FocusTargetofTarget")

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(addonName, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(addonName, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(L["Unlock"])
function Unlock:OnClick()
	if self:GetChecked() then
		_G[O.."UnlockText"]:SetText(L["Unlock"] .. L[" (drag an icon to move)"])
		unlocknewline:SetPoint("TOPLEFT", title, "TOPLEFT", 0, 23)
		unlocknewline:Show()
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LCframes) do
			v.maxExpirationTime = 0
			v.unlockMode = true
			local frame = LoseControlDB.frames[k]
			if frame.enabled and (_G[anchors[frame.anchor][k]] or (type(anchors[frame.anchor][k])=="table" and anchors[frame.anchor][k] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
				v:RegisterUnitEvents(false)
				v.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
				if _G[anchors[frame.anchor][k]] then
					if not _G[anchors[frame.anchor][k]]:IsVisible() then
						local frame = anchors[frame.anchor][k]
					 end
				end
				if frame.anchor == "None" then
				v.parent:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
				elseif frame.anchor == "Blizzard" then
				v.parent:SetParent(v.anchor:GetParent())
				end
				if v.anchor:GetParent() then
					v:SetFrameLevel(v.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
				v.text:Show()
				v:Show()
				v:GetParent():Show()
				v:SetDrawSwipe(true)
				v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
				v:SetCooldown( GetTime(), 60 )
				v:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
				v:SetMovable(true)
				v:RegisterForDrag("LeftButton")
				v:EnableMouse(true)
        if k == "arena3" and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
          if GladdyButtonFrame3 then
            GladdyButtonFrame3:SetAlpha(.5)
            GladdyButtonFrame3.classIcon:SetAlpha(0)
            v:SetAlpha(.5)
          end
          if GladiusClassIconFramearena3 then
            GladiusButtonFramearena3:SetAlpha(.5)
            GladiusClassIconFramearena3:SetAlpha(0)
            v:SetAlpha(.5)
          end
        end
        if LoseControlDB.EnableGladiusGloss and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
          v.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
          v.gloss.normalTexture = _G[v.gloss:GetName().."NormalTexture"]
          if frame.anchor == "Gladdy" then
            v.gloss.normalTexture:SetHeight(v.frame.size + 2)
            v.gloss.normalTexture:SetWidth(v.frame.size + 2)
          else
            v.gloss.normalTexture:SetHeight(v.frame.size )
            v.gloss.normalTexture:SetWidth(v.frame.size )
          end
          if frame.anchor == "Gladdy" then
            v.gloss.normalTexture:SetScale(.81) --.81 for Gladdy
          else
            v.gloss.normalTexture:SetScale(.9) --.81 for Gladdy
          end
          v.gloss.normalTexture:ClearAllPoints()
          v.gloss.normalTexture:SetPoint("CENTER", v, "CENTER")
          v.gloss:SetNormalTexture("Interface\\AddOns\\LoseControl\\Textures\\Gloss")
          v.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
          v.gloss:SetFrameLevel((v:GetParent():GetFrameLevel()) + 10)
          if (not v.gloss:IsShown()) then
            v.gloss:Show()
          end
        else
          if v.gloss:IsShown() then
            v.gloss:Hide()
          end
        end
			end
		end
		LCframeplayer2.maxExpirationTime = 0
		LCframeplayer2.unlockMode = true
		local frame = LoseControlDB.frames.player2
		if frame.enabled and (_G[anchors[frame.anchor][LCframeplayer2.unit]] or (type(anchors[frame.anchor][LCframeplayer2.unit])=="table" and anchors[frame.anchor][LCframeplayer2.unit] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
			LCframeplayer2:RegisterUnitEvents(false)
			LCframeplayer2.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
			if frame.anchor == "None" then
			LCframeplayer2.parent:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
			end
			if LCframeplayer2.anchor:GetParent() then
				LCframeplayer2:SetFrameLevel(LCframeplayer2.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			LCframeplayer2.text:Show()
			LCframeplayer2:Show()
			LCframeplayer2:GetParent():Show()
			LCframeplayer2:SetDrawSwipe(true)
			LCframeplayer2:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
			LCframeplayer2:SetCooldown( GetTime(), 60 )
			LCframeplayer2:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
		end
	else
		_G[O.."UnlockText"]:SetText(L["Unlock"])
		for k, v in pairs(LCframes) do
			unlocknewline:Hide()
      local frame = LoseControlDB.frames[k]
      if k == "arena3" and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
        if GladdyButtonFrame3 then
          GladdyButtonFrame3:SetAlpha(1)
          GladdyButtonFrame3.classIcon:SetAlpha(1)
          v:SetAlpha(1)
        end
        if GladiusClassIconFramearena3 then
          GladiusButtonFramearena3:SetAlpha(1)
          GladiusClassIconFramearena3:SetAlpha(1)
          v:SetAlpha(1)
        end
      end
			v.unlockMode = falseI
			v:EnableMouse(false)
			v:RegisterForDrag()
			v:SetMovable(false)
			v.text:Hide()
			v:PLAYER_ENTERING_WORLD()
		end
		LCframeplayer2.unlockMode = false
		LCframeplayer2.text:Hide()
		LCframeplayer2:PLAYER_ENTERING_WORLD()
	end
end
Unlock:SetScript("OnClick", Unlock.OnClick)

local DisableBlizzardCooldownCount = CreateFrame("CheckButton", O.."DisableBlizzardCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableBlizzardCooldownCountText"]:SetText(L["Disable Blizzard Countdown"])
function DisableBlizzardCooldownCount:Check(value)
	LoseControlDB.noBlizzardCooldownCount = value
	LoseControl.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
	LoseControl:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	for _, v in pairs(LCframes) do
		v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	end
	LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
end
DisableBlizzardCooldownCount:SetScript("OnClick", function(self)
	DisableBlizzardCooldownCount:Check(self:GetChecked())
end)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(L["Disable OmniCC Support"])
DisableCooldownCount:SetScript("OnClick", function(self)
	LoseControlDB.noCooldownCount = self:GetChecked()
	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
	if self:GetChecked() then
		DisableBlizzardCooldownCount:Enable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
	else
		DisableBlizzardCooldownCount:Disable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
		DisableBlizzardCooldownCount:SetChecked(true)
		DisableBlizzardCooldownCount:Check(true)
	end
end)

local DisableLossOfControlCooldownAuxText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
DisableLossOfControlCooldownAuxText:SetText(L["NeedsReload"])
DisableLossOfControlCooldownAuxText:SetTextColor(1,0,0)
DisableLossOfControlCooldownAuxText:Hide()

local DisableLossOfControlCooldownAuxButton = CreateFrame("Button", O.."DisableLossOfControlCooldownAuxButton", OptionsPanel, "OptionsButtonTemplate")
_G[O.."DisableLossOfControlCooldownAuxButtonText"]:SetText(L["ReloadUI"])
DisableLossOfControlCooldownAuxButton:SetHeight(12)
DisableLossOfControlCooldownAuxButton:Hide()
DisableLossOfControlCooldownAuxButton:SetScript("OnClick", function(self)
	ReloadUI()
end)

local DisableLossOfControlCooldown = CreateFrame("CheckButton", O.."DisableLossOfControlCooldown", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableLossOfControlCooldownText"]:SetText(L["DisableLossOfControlCooldownText"])
DisableLossOfControlCooldown:SetScript("OnClick", function(self)
	LoseControlDB.noLossOfControlCooldown = self:GetChecked()
	LoseControl.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
	if (self:GetChecked()) then
		LoseControl:DisableLossOfControlUI()
		DisableLossOfControlCooldownAuxText:Hide()
		DisableLossOfControlCooldownAuxButton:Hide()
	else
		DisableLossOfControlCooldownAuxText:Show()
		DisableLossOfControlCooldownAuxButton:Show()
	end
end)

local LossOfControlSpells = CreateFrame("Button", O.."LossOfControlSpells", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpells"]:SetText("PVP Spells")
LossOfControlSpells:SetHeight(18)
LossOfControlSpells:SetWidth(185)
LossOfControlSpells:SetScale(1)
LossOfControlSpells:SetScript("OnClick", function(self)
L.SpellsConfig:Toggle()
end)
local LossOfControlSpellsArena = CreateFrame("Button", O.."LossOfControlSpellsArena", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpellsArena"]:SetText("Arena123")
LossOfControlSpellsArena:SetHeight(18)
LossOfControlSpellsArena:SetWidth(185)
LossOfControlSpellsArena:SetScale(1)
LossOfControlSpellsArena:SetScript("OnClick", function(self)
L.SpellsArenaConfig:Toggle()
end)
local LossOfControlSpellsPVE = CreateFrame("Button", O.."LossOfControlSpellsPVE", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpellsPVE"]:SetText("PVE Spells")
LossOfControlSpellsPVE:SetHeight(18)
LossOfControlSpellsPVE:SetWidth(185)
LossOfControlSpellsPVE:SetScale(1)
LossOfControlSpellsPVE:SetScript("OnClick", function(self)
L.SpellsPVEConfig:Toggle()
end)

local Priority = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Priority:SetText(L["Priority"])

local PriorityDescription = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
PriorityDescription:SetText(L["PriorityDescription"])

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv
local function CreateSlider(text, parent, low, high, step, globalName)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(150)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	return slider
end

local function CreateSliderMain(text, parent, low, high, step, globalName)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(185)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	return slider
end



local DrawSwipeSlider = CreateSliderMain(nil, OptionsPanel, 0, 1, .1, "DrawSwipe")
DrawSwipeSlider:SetScript("OnValueChanged", function(self, value)
_G["DrawSwipeText"]:SetText("DrawSwipe" .. " (" .. ("%.1f"):format(value) .. ")")
LoseControlDB.DrawSwipeSetting = value
end)

local PrioritySlider = {}
for k in pairs(DBdefaults.priority) do
	PrioritySlider[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "Priority"..k.."Slider")
	PrioritySlider[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

local PrioritySliderArena = {}
for k in pairs(DBdefaults.priorityArena) do
	PrioritySliderArena[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "priorityArena"..k.."Slider")
	PrioritySliderArena[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

-------------------------------------------------------------------------------
-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 8, -10)

local BambiText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
BambiText:SetFont("Fonts\\MORPHEUS.ttf", 14 )
BambiText:SetText("By ".."|cff00ccffBambi|r")
BambiText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 38, 1)

Unlock:SetPoint("TOPLEFT",  title, "BOTTOMLEFT", 110, 22)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, 6)

DisableBlizzardCooldownCount:SetPoint("TOPLEFT", subText, "TOPRIGHT", 15, 10)
DisableLossOfControlCooldownAuxButton:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 54, -5)

Priority:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
subText:SetPoint("TOPLEFT", Priority, "BOTTOMLEFT", 0, -3)
PriorityDescription:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -3)

PrioritySlider.CC:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", 0, -45)
PrioritySlider.Silence:SetPoint("TOPLEFT", PrioritySlider.CC, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootPhyiscal_Special:SetPoint("TOPLEFT", PrioritySlider.Silence, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootMagic_Special:SetPoint("TOPLEFT", PrioritySlider.RootPhyiscal_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.Root:SetPoint("TOPLEFT", PrioritySlider.RootMagic_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePlayer:SetPoint("TOPLEFT", PrioritySlider.Root, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm_Warning:SetPoint("TOPLEFT", PrioritySlider.ImmunePlayer, "BOTTOMLEFT", 0, -14)
PrioritySlider.CC_Warning:SetPoint("TOPLEFT", PrioritySlider.Disarm_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Enemy_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.CC_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Stealth:SetPoint("TOPLEFT", PrioritySlider.Enemy_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Immune:SetPoint("TOPLEFT", PrioritySlider.Stealth, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmuneSpell:SetPoint("TOPLEFT", PrioritySlider.Immune, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePhysical:SetPoint("TOPLEFT", PrioritySlider.ImmuneSpell, "BOTTOMLEFT", 0, -14)
PrioritySlider.AuraMastery_Cast_Auras:SetPoint("TOPLEFT", PrioritySlider.ImmunePhysical, "BOTTOMLEFT", 0, -14)
PrioritySlider.ROP_Vortex:SetPoint("TOPLEFT", PrioritySlider.AuraMastery_Cast_Auras, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm:SetPoint("TOPLEFT", PrioritySlider.ROP_Vortex, "BOTTOMLEFT", 0, -14)
PrioritySlider.Haste_Reduction:SetPoint("TOPLEFT", PrioritySlider.Disarm, "BOTTOMLEFT", 0, -14)
PrioritySlider.Dmg_Hit_Reduction:SetPoint("TOPLEFT", PrioritySlider.Haste_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.Interrupt:SetPoint("TOPLEFT", PrioritySlider.Dmg_Hit_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_DMG_Modifiers:SetPoint("TOPLEFT", PrioritySlider.Interrupt, "BOTTOMLEFT", 0, -14)
PrioritySlider.Friendly_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.AOE_DMG_Modifiers, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_Spell_Refections:SetPoint("TOPLEFT", PrioritySlider.Friendly_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Trees:SetPoint("TOPLEFT", PrioritySlider.AOE_Spell_Refections, "BOTTOMLEFT", 0, -14)

PrioritySlider.Snare:SetPoint("TOPLEFT", PrioritySlider.Trees, "TOPRIGHT", 42, 0)
PrioritySlider.SnareMagic30:SetPoint("BOTTOMLEFT", PrioritySlider.Snare, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical30:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePosion50:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePosion50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic70:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical70:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic70, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareSpecial:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical70, "TOPLEFT", 0, -14*-1)
PrioritySlider.PvE:SetPoint("BOTTOMLEFT", PrioritySlider.SnareSpecial, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Other:SetPoint("BOTTOMLEFT", PrioritySlider.PvE, "TOPLEFT", 0, -14*-1)
PrioritySlider.Movable_Cast_Auras:SetPoint("BOTTOMLEFT", PrioritySlider.Other, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Mana_Regen:SetPoint("BOTTOMLEFT", PrioritySlider.Movable_Cast_Auras, "TOPLEFT", 0, -14*-1)
PrioritySlider.Peronsal_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.Mana_Regen, "TOPLEFT", 0, -14*-1)
PrioritySlider.Personal_Offensives:SetPoint("BOTTOMLEFT", PrioritySlider.Peronsal_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.CC_Reduction:SetPoint("BOTTOMLEFT", PrioritySlider.Personal_Offensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Friendly_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.CC_Reduction, "TOPLEFT", 0, -14*-1)
PrioritySlider.Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Friendly_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Speed_Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Freedoms, "TOPLEFT", 0, -14*-1)

PrioritySliderArena.Snares_Casted_Melee:SetPoint("TOPLEFT", PrioritySlider.Snare, "TOPRIGHT", 42, 0)
PrioritySliderArena.Snares_Ranged_Spamable:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Casted_Melee, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_Low:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Ranged_Spamable, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Snares_WithCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_Low, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Freedoms_Speed:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_WithCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Freedoms_Speed, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Offenisive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Player_Party_OffensiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Offenisive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Big_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Player_Party_OffensiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Melee_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Big_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Disarms:SetPoint("BOTTOMLEFT", PrioritySliderArena.Melee_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Roots_90_Snares:SetPoint("BOTTOMLEFT", PrioritySliderArena.Disarms, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Ranged_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Roots_90_Snares, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_High:SetPoint("BOTTOMLEFT", PrioritySliderArena.Ranged_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Interrupt:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_High, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Silence_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Interrupt, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.CC_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Silence_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Immune_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.CC_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Drink_Purge:SetPoint("BOTTOMLEFT", PrioritySliderArena.Immune_Arena, "TOPLEFT", 0, -14*-1)

local durationTypeCheckBoxNew = {}
local durationTypeCheckBoxHigh = {}

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k] = CreateFrame("CheckButton", O.."durationTypeNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k] = CreateFrame("CheckButton", O.."durationTypeHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxNew[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k]:SetPoint("TOPLEFT", "Priority"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k]:SetPoint("TOPLEFT", O.."durationTypeNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxHigh[k]:SetScale(.8)
end

local durationTypeCheckBoxArenaNew = {}
local durationTypeCheckBoxArenaHigh = {}

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k] = CreateFrame("CheckButton", O.."durationTypeArenaNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k] = CreateFrame("CheckButton", O.."durationTypeArenaHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaNew[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k]:SetPoint("TOPLEFT", "priorityArena"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxArenaNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k]:SetPoint("TOPLEFT", O.."durationTypeArenaNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxArenaHigh[k]:SetScale(.8)
end

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeArenaText:SetPoint("BOTTOMLEFT", O.."durationTypeArenaNewDrink_Purge", "TOPLEFT", 1, 0)

local durtiontypeText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText:SetPoint("BOTTOMLEFT", O.."durationTypeNewCC", "TOPLEFT", 1, 0)

local durtiontypeText2 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText2:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText2:SetPoint("BOTTOMLEFT", O.."durationTypeNewSpeed_Freedoms", "TOPLEFT", 1, 0)

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("Set the duration for the priority:".."|cff00ccff[N]|r Newest Spell to affect you vs ".."|cffff0000[H] |r Highest duration spell affecting you ")
durtiontypeArenaText:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", -1, -3)

LossOfControlSpells:SetPoint("CENTER",PrioritySlider.Speed_Freedoms, "CENTER", 8, 55)
LossOfControlSpellsPVE:SetPoint("CENTER", LossOfControlSpells, "CENTER", 0, -20)
LossOfControlSpellsArena:SetPoint("CENTER", PrioritySliderArena.Drink_Purge, "CENTER", 8, 36)


SetInterruptIcons = CreateFrame("CheckButton", O.."SetInterruptIcons", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptIconsText"]:SetText("Enable Interrupt Icons")
SetInterruptIcons:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.InterruptIcons = true
	else
		LoseControlDB.InterruptIcons = false
	end
end)

SetRedSmokeBomb = CreateFrame("CheckButton", O.."SetRedSmokeBomb", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetRedSmokeBombText"]:SetText("Enable Red Enemy Smoke Bomb / Shadowy Duel")
SetRedSmokeBomb:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.RedSmokeBomb = true
	else
		LoseControlDB.RedSmokeBomb = false
	end
end)

SetInterruptOverlay = CreateFrame("CheckButton", O.."SetInterruptOverlay", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptOverlayText"]:SetText("Enable Interrupt Overlay")
SetInterruptOverlay:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.InterruptOverlay = true
	else
		LoseControlDB.InterruptOverlay = false
	end
end)

SetInterruptIcons:SetPoint("TOPLEFT", LossOfControlSpells, "TOPRIGHT", 18, -2)
SetInterruptOverlay:SetPoint("TOPLEFT", SetInterruptIcons, "BOTTOMLEFT", 0, 6)
SetRedSmokeBomb:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 150, 0)
DisableLossOfControlCooldown:SetPoint("TOPLEFT", SetRedSmokeBomb, "BOTTOMLEFT", 0, 6)
DisableLossOfControlCooldownAuxText:SetPoint("TOPLEFT", DisableLossOfControlCooldown, "BOTTOMLEFT", 26, 10)
DrawSwipeSlider:SetPoint("BOTTOMLEFT", SetInterruptIcons, "TOPLEFT", 1, 0)
-------------------------------------------------------------------------------
OptionsPanel.default = function() -- This method will run when the player clicks "defaults"
	L.SpellsConfig:ResetAllSpellList()
	L.SpellsPVEConfig:ResetAllSpellList()
	L.SpellsArenaConfig:ResetAllSpellList()
	_G.LoseControlDB = nil
	L.SpellsPVEConfig:WipeAll()
	L.SpellsConfig:WipeAll()
	L.SpellsArenaConfig:WipeAll()
	LoseControl:ADDON_LOADED(addonName)
	L.SpellsConfig:UpdateAll()
	L.SpellsPVEConfig:UpdateAll()
	L.SpellsArenaConfig:UpdateAll()
	for _, v in pairs(LCframes) do
		v:PLAYER_ENTERING_WORLD()
	end
	LCframeplayer2:PLAYER_ENTERING_WORLD()
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	DisableBlizzardCooldownCount:SetChecked(LoseControlDB.noBlizzardCooldownCount)
	DisableLossOfControlCooldown:SetChecked(LoseControlDB.noLossOfControlCooldown)
	DrawSwipeSlider:SetValue(LoseControlDB.DrawSwipeSetting)

	for k in pairs(DBdefaults.priority) do
	if LoseControlDB.durationType[k] == false then durationTypeCheckBoxNew[k]:SetChecked(true) else durationTypeCheckBoxNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priority) do
	if LoseControlDB.durationType[k] == true then durationTypeCheckBoxHigh[k]:SetChecked(true) else durationTypeCheckBoxHigh[k]:SetChecked(false) end
	end

	for k in pairs(DBdefaults.priorityArena) do
	if LoseControlDB.durationTypeArena[k] == false then durationTypeCheckBoxArenaNew[k]:SetChecked(true) else durationTypeCheckBoxArenaNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priorityArena) do
	if LoseControlDB.durationTypeArena[k] == true then durationTypeCheckBoxArenaHigh[k]:SetChecked(true) else durationTypeCheckBoxArenaHigh[k]:SetChecked(false) end
	end

	if LoseControlDB.InterruptIcons == false then SetInterruptIcons:SetChecked(false) else SetInterruptIcons:SetChecked(true) end
	if LoseControlDB.InterruptOverlay == false then SetInterruptOverlay:SetChecked(false) else SetInterruptOverlay:SetChecked(true) end
	if LoseControlDB.RedSmokeBomb == false then SetRedSmokeBomb:SetChecked(false) else SetRedSmokeBomb:SetChecked(true) end

	if not LoseControlDB.noCooldownCount then
		DisableBlizzardCooldownCount:Disable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
		DisableBlizzardCooldownCount:SetChecked(true)
		DisableBlizzardCooldownCount:Check(true)
	else
		DisableBlizzardCooldownCount:Enable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
	end
	local priority = LoseControlDB.priority
	for k in pairs(priority) do
		PrioritySlider[k]:SetValue(priority[k])
	end
	local priorityArena = LoseControlDB.priorityArena
	for k in pairs(priorityArena) do
		PrioritySliderArena[k]:SetValue(priorityArena[k])
	end
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
-- DropDownMenu helper function
local function AddItem(owner, text, value)
	local info = UIDropDownMenu_CreateInfo()
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

-------------------------------------------------------------------------------
-- Create sub-option frames
for _, v in ipairs({ "player", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
	local OptionsPanelFrame = CreateFrame("Frame", O..v)
	OptionsPanelFrame.parent = addonName
	OptionsPanelFrame.name = L[v]

	local AnchorDropDownLabel = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDownLabel", "ARTWORK", "GameFontNormal")
	AnchorDropDownLabel:SetText(L["Anchor"])
	local AnchorDropDown2Label
	if v == "player" then
		AnchorDropDown2Label = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDown2Label", "ARTWORK", "GameFontNormal")
		AnchorDropDown2Label:SetText(L["Anchor"])
	end
	local CategoriesEnabledLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoriesEnabledLabel", "ARTWORK", "GameFontNormal")
	CategoriesEnabledLabel:SetText(L["CategoriesEnabledLabel"])
	CategoriesEnabledLabel:SetJustifyH("LEFT")

	L.CategoryEnabledInterruptLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledInterruptLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledInterruptLabel:SetText(L["Interrupt"]..":")

	L.CategoryEnabledCCLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCCLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCCLabel:SetText(L["CC"]..":")
	L.CategoryEnabledSilenceLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilenceLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilenceLabel:SetText(L["Silence"]..":")
	L.CategoryEnabledRootPhyiscal_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootPhyiscal_SpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootPhyiscal_SpecialLabel:SetText(L["RootPhyiscal_Special"]..":")
	L.CategoryEnabledRootMagic_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootMagic_SpeciallLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootMagic_SpecialLabel:SetText(L["RootMagic_Special"]..":")
	L.CategoryEnabledRootLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootLabel:SetText(L["Root"]..":")
	L.CategoryEnabledImmunePlayerLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePlayerLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePlayerLabel:SetText(L["ImmunePlayer"]..":")
	L.CategoryEnabledDisarm_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarm_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarm_WarningLabel:SetText(L["Disarm_Warning"]..":")
	L.CategoryEnabledCC_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledEnemy_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledEnemy_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_WarningLabel:SetText(L["CC_Warning"]..":")
	L.CategoryEnabledEnemy_Smoke_BombLabel:SetText(L["Enemy_Smoke_Bomb"]..":")
	L.CategoryEnabledStealthLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledStealthLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledStealthLabel:SetText(L["Stealth"]..":")
	L.CategoryEnabledImmuneLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneLabel:SetText(L["Immune"]..":")
	L.CategoryEnabledImmuneSpellLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneSpellLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneSpellLabel:SetText(L["ImmuneSpell"]..":")
	L.CategoryEnabledImmunePhysicalLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePhysicalLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePhysicalLabel:SetText(L["ImmunePhysical"]..":")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAuraMastery_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel:SetText(L["AuraMastery_Cast_Auras"]..":")
	L.CategoryEnabledROP_VortexLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledROP_VortexLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledROP_VortexLabel:SetText(L["ROP_Vortex"]..":")
	L.CategoryEnabledDisarmLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmLabel:SetText(L["Disarm"]..":")
	L.CategoryEnabledHaste_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledHaste_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledHaste_ReductionLabel:SetText(L["Haste_Reduction"]..":")
	L.CategoryEnabledDmg_Hit_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDmg_Hit_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDmg_Hit_ReductionLabel:SetText(L["Dmg_Hit_Reduction"]..":")
	L.CategoryEnabledAOE_DMG_ModifiersLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_DMG_ModifiersLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_DMG_ModifiersLabel:SetText(L["AOE_DMG_Modifiers"]..":")
	L.CategoryEnabledFriendly_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_Smoke_BombLabel:SetText(L["Friendly_Smoke_Bomb"]..":")
	L.CategoryEnabledAOE_Spell_RefectionsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_Spell_RefectionsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_Spell_RefectionsLabel:SetText(L["AOE_Spell_Refections"]..":")
	L.CategoryEnabledTreesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledTreesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledTreesLabel:SetText(L["Trees"]..":")
	L.CategoryEnabledSpeed_FreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpeed_FreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpeed_FreedomsLabel:SetText(L["Speed_Freedoms"]..":")
	L.CategoryEnabledFreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedomsLabel:SetText(L["Freedoms"]..":")
	L.CategoryEnabledFriendly_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_DefensivesLabel:SetText(L["Friendly_Defensives"]..":")
	L.CategoryEnabledMana_RegenLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMana_RegenLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMana_RegenLabel:SetText(L["Mana_Regen"]..":")
	L.CategoryEnabledCC_ReductionLabel:SetText(L["CC_Reduction"]..":")
	L.CategoryEnabledPersonal_OffensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPersonal_OffensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPersonal_OffensivesLabel:SetText(L["Personal_Offensives"]..":")
	L.CategoryEnabledPeronsal_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPeronsal_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPeronsal_DefensivesLabel:SetText(L["Peronsal_Defensives"]..":")
	L.CategoryEnabledMovable_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMovable_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMovable_Cast_AurasLabel:SetText(L["Movable_Cast_Auras"]..":")
	L.CategoryEnabledOtherLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledOtherLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPvELabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPvELabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledOtherLabel:SetText(L["Other"]..":")
	L.CategoryEnabledPvELabel:SetText(L["PvE"]..":")
	L.CategoryEnabledSnareSpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareSpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareSpecialLabel:SetText(L["SnareSpecial"]..":")
	L.CategoryEnabledSnarePhysical70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical70Label:SetText(L["SnarePhysical70"]..":")
	L.CategoryEnabledSnareMagic70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic70Label:SetText(L["SnareMagic70"]..":")
	L.CategoryEnabledSnarePhysical50Label:SetText(L["SnarePhysical50"]..":")
	L.CategoryEnabledSnarePosion50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePosion50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePosion50Label:SetText(L["SnarePosion50"]..":")
	L.CategoryEnabledSnareMagic50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic50Label:SetText(L["SnareMagic50"]..":")
	L.CategoryEnabledSnarePhysical30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical30Label:SetText(L["SnarePhysical30"]..":")
	L.CategoryEnabledSnareMagic30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic30Label:SetText(L["SnareMagic30"]..":")
	L.CategoryEnabledSnareLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareLabel:SetText(L["Snare"]..":")

	L.CategoryEnabledDrink_PurgeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDrink_PurgeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDrink_PurgeLabel:SetText(L["Drink_Purge"]..":")
	L.CategoryEnabledImmune_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmune_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmune_ArenaLabel:SetText(L["Immune_Arena"]..":")
	L.CategoryEnabledCC_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ArenaLabel:SetText(L["CC_Arena"]..":")
	L.CategoryEnabledSilence_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilence_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilence_ArenaLabel:SetText(L["Silence_Arena"]..":")
	L.CategoryEnabledSpecial_HighLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_HighLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_HighLabel:SetText(L["Special_High"]..":")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRanged_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel:SetText(L["Ranged_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledRoots_90_SnaresLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRoots_90_SnaresLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRoots_90_SnaresLabel:SetText(L["Roots_90_Snares"]..":")
	L.CategoryEnabledDisarmsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmsLabel:SetText(L["Disarms"]..":")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMelee_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel:SetText(L["Melee_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledBig_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledBig_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledBig_Defensive_CDsLabel:SetText(L["Big_Defensive_CDs"]..":")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPlayer_Party_OffensiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Offenisive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Offenisive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Offenisive_CDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Defensive_CDsLabel:SetText(L["Small_Defensive_CDs"]..":")
	L.CategoryEnabledFreedoms_SpeedLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedoms_SpeedLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedoms_SpeedLabel:SetText(L["Freedoms_Speed"]..":")
	L.CategoryEnabledSnares_WithCDsLabel = OptionsPanelFrame:CreateFontString(O..v.." CategoryEnabledSnares_WithCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_WithCDsLabel:SetText(L["Snares_WithCDs"]..":")
	L.CategoryEnabledSpecial_LowLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_LowLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_LowLabel:SetText(L["Special_Low"]..":")
	L.CategoryEnabledSnares_Ranged_SpamableLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Ranged_SpamableLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Ranged_SpamableLabel:SetText(L["Snares_Ranged_Spamable"]..":")
	L.CategoryEnabledSnares_Casted_MeleeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Casted_MeleeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Casted_MeleeLabel:SetText(L["Snares_Casted_Melee"]..":")


	local CategoriesLabels = {
		["Interrupt"] = L.CategoryEnabledInterruptLabel,
		["CC"] = L.CategoryEnabledCCLabel,
		["Silence"] = L.CategoryEnabledSilenceLabel,
		["RootPhyiscal_Special"] = L.CategoryEnabledRootPhyiscal_SpecialLabel,
		["RootMagic_Special"] = L.CategoryEnabledRootMagic_SpecialLabel,
		["Root"] = L.CategoryEnabledRootLabel,
		["ImmunePlayer"] = L.CategoryEnabledImmunePlayerLabel,
		["Disarm_Warning"] = L.CategoryEnabledDisarm_WarningLabel,
		["CC_Warning"] = L.CategoryEnabledCC_WarningLabel,
		["Enemy_Smoke_Bomb"] = L.CategoryEnabledEnemy_Smoke_BombLabel,
		["Stealth"] = L.CategoryEnabledStealthLabel,
		["Immune"] = L.CategoryEnabledImmuneLabel,
		["ImmuneSpell"] = L.CategoryEnabledImmuneSpellLabel,
		["ImmunePhysical"] = L.CategoryEnabledImmunePhysicalLabel,
		["AuraMastery_Cast_Auras"] = L.CategoryEnabledAuraMastery_Cast_AurasLabel,
		["ROP_Vortex"] = L.CategoryEnabledROP_VortexLabel,
		["Disarm"] = L.CategoryEnabledDisarmLabel,
		["Haste_Reduction"] = L.CategoryEnabledHaste_ReductionLabel,
		["Dmg_Hit_Reduction"] = L.CategoryEnabledDmg_Hit_ReductionLabel,
		["AOE_DMG_Modifiers"] = L.CategoryEnabledAOE_DMG_ModifiersLabel,
		["Friendly_Smoke_Bomb"] = L.CategoryEnabledFriendly_Smoke_BombLabel,
		["AOE_Spell_Refections"] = L.CategoryEnabledAOE_Spell_RefectionsLabel,
		["Trees"] = L.CategoryEnabledTreesLabel,
		["Speed_Freedoms"] = L.CategoryEnabledSpeed_FreedomsLabel,
		["Freedoms"] = L.CategoryEnabledFreedomsLabel,
		["Friendly_Defensives"] = L.CategoryEnabledFriendly_DefensivesLabel,
		["CC_Reduction"] = L.CategoryEnabledCC_ReductionLabel,
		["Personal_Offensives"] = L.CategoryEnabledPersonal_OffensivesLabel,
		["Peronsal_Defensives"] = L.CategoryEnabledPeronsal_DefensivesLabel,
		["Mana_Regen"] = L.CategoryEnabledMana_RegenLabel,
		["Movable_Cast_Auras"] = L.CategoryEnabledMovable_Cast_AurasLabel,
		["Other"] =  L.CategoryEnabledOtherLabel,
		["PvE"] = L.CategoryEnabledPvELabel,
		["SnareSpecial"] = L.CategoryEnabledSnareSpecialLabel,
		["SnarePhysical70"] = L.CategoryEnabledSnarePhysical70Label,
		["SnareMagic70"] = L.CategoryEnabledSnareMagic70Label,
		["SnarePhysical50"] = L.CategoryEnabledSnarePhysical50Label,
		["SnarePosion50"] = L.CategoryEnabledSnarePosion50Label,
		["SnareMagic50"] = L.CategoryEnabledSnareMagic50Label,
		["SnarePhysical30"] = L.CategoryEnabledSnarePhysical30Label,
		["SnareMagic30"] = L.CategoryEnabledSnareMagic30Label,
		["Snare"] = L.CategoryEnabledSnareLabel,

		["Drink_Purge"] = L.CategoryEnabledDrink_PurgeLabel,
		["Immune_Arena"] = L.CategoryEnabledImmune_ArenaLabel,
		["CC_Arena"] = L.CategoryEnabledCC_ArenaLabel,
		["Silence_Arena"] = L.CategoryEnabledSilence_ArenaLabel,
		["Special_High"] = L.CategoryEnabledSpecial_HighLabel,
		["Ranged_Major_OffenisiveCDs"] = L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,
		["Roots_90_Snares"] = L.CategoryEnabledRoots_90_SnaresLabel,
		["Disarms"] = L.CategoryEnabledDisarmsLabel,
		["Melee_Major_OffenisiveCDs"] = L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,
		["Big_Defensive_CDs"] = L.CategoryEnabledBig_Defensive_CDsLabel,
		["Player_Party_OffensiveCDs"] = L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,
		["Small_Offenisive_CDs"] = L.CategoryEnabledSmall_Offenisive_CDsLabel,
		["Small_Defensive_CDs"] = L.CategoryEnabledSmall_Defensive_CDsLabel,
		["Freedoms_Speed"] = L.CategoryEnabledFreedoms_SpeedLabel,
		["Snares_WithCDs"] = L.CategoryEnabledSnares_WithCDsLabel,
		["Special_Low"] = L.CategoryEnabledSpecial_LowLabel,
		["Snares_Ranged_Spamable"] = L.CategoryEnabledSnares_Ranged_SpamableLabel,
		["Snares_Casted_Melee"] = L.CategoryEnabledSnares_Casted_MeleeLabel,
		}

	local AnchorDropDown = CreateFrame("Frame", O..v.."AnchorDropDown", OptionsPanelFrame, "UIDropDownMenuTemplate")
	function AnchorDropDown:OnClick()
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, self.value)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, unitId in ipairs(frames) do
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]
			frame.anchor = self.value
			icon.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if self.value ~= "None" then -- reset the frame position so it centers on the anchor frame
				frame.point = nil
				frame.relativePoint = nil
				frame.x = nil
				frame.y = nil
				if self.value == "Gladius" then
					if strfind(unitId, "arena") then
					LCframes[unitId]:CheckGladiusUnitsAnchors(true)
					end
					if GladiusClassIconFramearena1 then
						local W = GladiusClassIconFramearena1:GetWidth()
						local H = GladiusClassIconFramearena1:GetWidth()
						print("|cff00ccffLoseControl|r".." : "..unitId.." GladiusClassIconFrame Size "..mathfloor(H))
						portrSizeValue = W
					else
						if (strfind(unitId, "arena")) then
							portrSizeValue = 42
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
        if self.value == "Gladdy" then
          if strfind(unitId, "arena") then
          LCframes[unitId]:CheckGladdyUnitsAnchors(true)
          end
          if GladdyButtonFrame1.classIcon then
            local W = GladdyButtonFrame1.classIcon:GetWidth()
            local H = GladdyButtonFrame1.classIcon:GetWidth()
            print("|cff00ccffLoseControl|r".." : "..unitId.." GladdyClassIconFrame Size "..mathfloor(H))
            portrSizeValue = W
          else
            if (strfind(unitId, "arena")) then
              portrSizeValue = 42
            end
          end
          frame.size = portrSizeValue
          icon:SetWidth(portrSizeValue)
          icon:SetHeight(portrSizeValue)
          icon:GetParent():SetWidth(portrSizeValue)
          icon:GetParent():SetHeight(portrSizeValue)
          if icon.MasqueGroup then
            icon.MasqueGroup:RemoveButton(icon:GetParent())
          end
          _G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
        end
				if self.value == "BambiUI" then
					if (strfind(unitId, "party")) then
						portrSizeValue = 64
					end
					if unitId == "player" then
						portrSizeValue = 48
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
				if self.value == "Blizzard" then
					local portrSizeValue = 36
					if (unitId == "player" or unitId == "target" or unitId == "focus") then
						portrSizeValue = 62
					elseif (strfind(unitId, "arena")) then
						portrSizeValue = 28
					end
					if (unitId == "player") and LoseControlDB.duplicatePlayerPortrait then
						local DuplicatePlayerPortrait = _G['LoseControlOptionsPanel'..unitId..'DuplicatePlayerPortrait']
						if DuplicatePlayerPortrait then
							DuplicatePlayerPortrait:SetChecked(false)
							DuplicatePlayerPortrait:Check(false)
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
			else
				if icon.MasqueGroup then
					icon.MasqueGroup:RemoveButton(icon:GetParent())
					icon.MasqueGroup:AddButton(icon:GetParent(), {
						FloatingBG = false,
						Icon = icon.texture,
						Cooldown = icon,
						Flash = _G[icon:GetParent():GetName().."Flash"],
						Pushed = icon:GetParent():GetPushedTexture(),
						Normal = icon:GetParent():GetNormalTexture(),
						Disabled = icon:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[icon:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = icon:GetParent():GetHighlightTexture(),
						Hotkey = _G[icon:GetParent():GetName().."HotKey"],
						Count = _G[icon:GetParent():GetName().."Count"],
						Name = _G[icon:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[icon:GetParent():GetName().."Shine"],
					}, "Button", true)
				end
			end
			SetInterruptIconsSize(icon, frame.size)
			icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			if icon.MasqueGroup then
				icon.MasqueGroup:ReSkin()
			end
		end
	end

	local AnchorDropDown2
	if v == "player" then
		AnchorDropDown2	= CreateFrame("Frame", O..v.."AnchorDropDown2", OptionsPanelFrame, "UIDropDownMenuTemplate")
		function AnchorDropDown2:OnClick()
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, self.value)
			local frame = LoseControlDB.frames.player2
			local icon = LCframeplayer2
			frame.anchor = self.value
			frame.point = nil
			frame.relativePoint = nil
			frame.x = nil
			frame.y = nil
			if self.value == "Blizzard" then
				local portrSizeValue = 62
				frame.size = portrSizeValue
				icon:SetWidth(portrSizeValue)
				icon:SetHeight(portrSizeValue)
				icon:GetParent():SetWidth(portrSizeValue)
				icon:GetParent():SetHeight(portrSizeValue)
			end
			icon.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
			SetInterruptIconsSize(icon, frame.size)
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
		end
	end

	local SizeSlider = CreateSlider(L["Icon Size"], OptionsPanelFrame, 16, 256, 2, OptionsPanelFrame:GetName() .. "IconSizeSlider")
	SizeSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Icon Size"] .. " (" .. value .. "px)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].size = value
			LCframes[frame]:SetWidth(value)
			LCframes[frame]:SetHeight(value)
			LCframes[frame]:GetParent():SetWidth(value)
			LCframes[frame]:GetParent():SetHeight(value)
			if LCframes[frame].MasqueGroup then
				LCframes[frame].MasqueGroup:ReSkin()
			end
			SetInterruptIconsSize(LCframes[frame], value)
		end
	end)

	local AlphaSlider = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 2, OptionsPanelFrame:GetName() .. "OpacitySlider") -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
	AlphaSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. ("%.0f"):format(value) .. "%)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].alpha = value / 100 -- the real alpha value
			LCframes[frame]:GetParent():SetAlpha(value / 100)
		end
	end)

	local AlphaSlider2
	if v == "player" then
		AlphaSlider2 = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 2, OptionsPanelFrame:GetName() .. "Opacity2Slider") -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
		AlphaSlider2:SetScript("OnValueChanged", function(self, value)
			_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. ("%.0f"):format(value) .. "%)")
			local frames = { v }
			if v == "player" then
				LoseControlDB.frames.player2.alpha = value / 100 -- the real alpha value
				LCframeplayer2:GetParent():SetAlpha(value / 100)
			end
		end)
	end

	local DisableInBG
	if v == "party" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	elseif v == "arena" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disableArenaInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 5 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	end

	local DisableInRaid
	if v == "party" then
		DisableInRaid = CreateFrame("CheckButton", O..v.."DisableInRaid", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInRaidText"]:SetText(L["DisableInRaid"])
		DisableInRaid:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInRaid = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	end

	local ShowNPCInterrupts
	if v == "target" or v == "focus" or v == "targettarget" or v == "focustarget"  then
		ShowNPCInterrupts = CreateFrame("CheckButton", O..v.."ShowNPCInterrupts", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."ShowNPCInterruptsText"]:SetText(L["ShowNPCInterrupts"])
		ShowNPCInterrupts:SetScript("OnClick", function(self)
			if v == "target" then
				LoseControlDB.showNPCInterruptsTarget = self:GetChecked()
			elseif v == "focus" then
				LoseControlDB.showNPCInterruptsFocus = self:GetChecked()
			elseif v == "targettarget" then
				LoseControlDB.showNPCInterruptsTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.showNPCInterruptsFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerTargetTarget
	if v == "targettarget" or v == "focustarget" then
		DisablePlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetTargetText"]:SetText(L["DisablePlayerTargetTarget"])
		DisablePlayerTargetTarget:SetScript("OnClick", function(self)
			if v == "targettarget" then
				LoseControlDB.disablePlayerTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.disablePlayerFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableTargetTargetTarget
	if v == "targettarget" then
		DisableTargetTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetTargetTargetText"]:SetText(L["DisableTargetTargetTarget"])
		DisableTargetTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerTargetPlayerTargetTarget
	if v == "targettarget" then
		DisablePlayerTargetPlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetPlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetPlayerTargetTargetText"]:SetText(L["DisablePlayerTargetPlayerTargetTarget"])
		DisablePlayerTargetPlayerTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerTargetPlayerTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableTargetDeadTargetTarget
	if v == "targettarget" then
		DisableTargetDeadTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetDeadTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetDeadTargetTargetText"]:SetText(L["DisableTargetDeadTargetTarget"])
		DisableTargetDeadTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetDeadTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableFocusFocusTarget
	if v == "focustarget" then
		DisableFocusFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusFocusTargetText"]:SetText(L["DisableFocusFocusTarget"])
		DisableFocusFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerFocusPlayerFocusTarget
	if v == "focustarget" then
		DisablePlayerFocusPlayerFocusTarget = CreateFrame("CheckButton", O..v.."DisablePlayerFocusPlayerFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerFocusPlayerFocusTargetText"]:SetText(L["DisablePlayerFocusPlayerFocusTarget"])
		DisablePlayerFocusPlayerFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerFocusPlayerFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableFocusDeadFocusTarget
	if v == "focustarget" then
		DisableFocusDeadFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusDeadFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusDeadFocusTargetText"]:SetText(L["DisableFocusDeadFocusTarget"])
		DisableFocusDeadFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusDeadFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local EnableGladiusGloss
	if strfind(v, "arena") then
		EnableGladiusGloss = CreateFrame("CheckButton", O..v.."EnableGladiusGloss", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."EnableGladiusGlossText"]:SetText(L["EnableGladiusGloss"])
		EnableGladiusGloss:SetScript("OnClick", function(self)
			LoseControlDB.EnableGladiusGloss = self:GetChecked()
      if Unlock:GetChecked() then
        Unlock:OnClick()
      end
		end)
	end

	local lossOfControlInterrupt
	if  v == "player" then
		lossOfControlInterrupt = CreateSlider(L["lossOfControlInterrupt"], OptionsPanelFrame, 0, 2, 1, "lossOfControlInterrupt")
		lossOfControlInterrupt:SetScript("OnValueChanged", function(self, value)
		lossOfControlInterrupt:SetScale(.82)
		lossOfControlInterrupt:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlInterrupt"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlInterrupt = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlInterrupt", ("%.0f"):format(value))
		end)
	end

	local lossOfControlFull
	if  v == "player" then
		lossOfControlFull = CreateSlider(L["lossOfControlFull"], OptionsPanelFrame, 0, 2, 1, "lossOfControlFull")
		lossOfControlFull:SetScript("OnValueChanged", function(self, value)
		lossOfControlFull:SetScale(.82)
		lossOfControlFull:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlFull"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlFull = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlFull", ("%.0f"):format(value))
		end)
	end

	local lossOfControlSilence
	if  v == "player" then
		lossOfControlSilence = CreateSlider(L["lossOfControlSilence"], OptionsPanelFrame, 0, 2, 1, "lossOfControlSilence")
		lossOfControlSilence:SetScript("OnValueChanged", function(self, value)
		lossOfControlSilence:SetScale(.82)
		lossOfControlSilence:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlSilence"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlSilence = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlSilence", ("%.0f"):format(value))
		end)
	end

	local lossOfControlDisarm
	if  v == "player" then
		lossOfControlDisarm = CreateSlider(L["lossOfControlDisarm"], OptionsPanelFrame, 0, 2, 1, "lossOfControlDisarm")
		lossOfControlDisarm:SetScript("OnValueChanged", function(self, value)
		lossOfControlDisarm:SetScale(.82)
		lossOfControlDisarm:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlDisarm"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlDisarm = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlDisarm", ("%.0f"):format(value))
		end)
	end

	local lossOfControlRoot
	if  v == "player" then
		lossOfControlRoot = CreateSlider(L["lossOfControlRoot"], OptionsPanelFrame, 0, 2, 1, "lossOfControlRoot")
		lossOfControlRoot:SetScript("OnValueChanged", function(self, value)
		lossOfControlRoot:SetScale(.82)
		lossOfControlRoot:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlRoot"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlRoot = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlRoot", ("%.0f"):format(value))
		end)
	end

	local lossOfControl
	if  v == "player" then
		lossOfControl = CreateFrame("CheckButton", O..v.."lossOfControl", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		lossOfControl:SetScale(1)
		lossOfControl:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."lossOfControlText"]:SetText(L["lossOfControl"])
		lossOfControl:SetScript("OnClick", function(self)
			LoseControlDB.lossOfControl = self:GetChecked()
			if (self:GetChecked()) then
				SetCVar("lossOfControl", 1)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlFull)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot)
			else
				SetCVar("lossOfControl", 0)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlFull)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot)
			end
		end)
	end

  local PlayerText
  if  v == "player" then
    PlayerText = CreateFrame("CheckButton", O..v.."PlayerText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
    PlayerText:SetScale(1)
    PlayerText:SetHitRectInsets(0, 0, 0, 0)
    _G[O..v.."PlayerTextText"]:SetText("Show Category Text on Frame")
    PlayerText:SetScript("OnClick", function(self)
      LoseControlDB.PlayerText = self:GetChecked()
      if (self:GetChecked()) then
        LoseControlDB.PlayerText = true
      else
        LoseControlDB.PlayerText = false
      end
    end)
  end

  local ArenaPlayerText
  if  v == "player" then
    ArenaPlayerText = CreateFrame("CheckButton", O..v.."ArenaPlayerText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
    ArenaPlayerText:SetScale(1)
    ArenaPlayerText:SetHitRectInsets(0, 0, 0, 0)
    _G[O..v.."ArenaPlayerTextText"]:SetText("Disable Player Text in PvP")
    ArenaPlayerText:SetScript("OnClick", function(self)
      LoseControlDB.ArenaPlayerText = self:GetChecked()
      if (self:GetChecked()) then
        LoseControlDB.ArenaPlayerText = true
      else
        LoseControlDB.ArenaPlayerText = false
      end
    end)
  end

  local displayTypeDot
  if  v == "player" then
    displayTypeDot = CreateFrame("CheckButton", O..v.."displayTypeDot", OptionsPanelFrame, "OptionsCheckButtonTemplate")
    displayTypeDot:SetScale(1)
    displayTypeDot:SetHitRectInsets(0, 0, 0, 0)
    _G[O..v.."displayTypeDotText"]:SetText("Icon Type Color Next to Text")
    displayTypeDot:SetScript("OnClick", function(self)
      LoseControlDB.displayTypeDot = self:GetChecked()
      if (self:GetChecked()) then
        LoseControlDB.displayTypeDot = true
      else
        LoseControlDB.displayTypeDot = false
      end
    end)
  end

  local SilenceIcon
  if  v == "player" then
    SilenceIcon = CreateFrame("CheckButton", O..v.."SilenceIcon", OptionsPanelFrame, "OptionsCheckButtonTemplate")
    SilenceIcon:SetScale(1)
    SilenceIcon:SetHitRectInsets(0, 0, 0, 0)
    _G[O..v.."SilenceIconText"]:SetText("Show Silence Frame Separate")
    SilenceIcon:SetScript("OnClick", function(self)
      LoseControlDB.SilenceIcon = self:GetChecked()
      if (self:GetChecked()) then
        LoseControlDB.SilenceIcon = true
      else
        LoseControlDB.SilenceIcon = false
      end
    end)
  end

	local catListEnChecksButtons = {
																	"CC","Silence","RootPhyiscal_Special","RootMagic_Special","Root","ImmunePlayer","Disarm_Warning","CC_Warning","Enemy_Smoke_Bomb","Stealth",
																	"Immune","ImmuneSpell","ImmunePhysical","AuraMastery_Cast_Auras","ROP_Vortex","Disarm","Haste_Reduction","Dmg_Hit_Reduction",
																	"AOE_DMG_Modifiers","Friendly_Smoke_Bomb","AOE_Spell_Refections","Trees","Speed_Freedoms","Freedoms","Friendly_Defensives",
																	"CC_Reduction","Personal_Offensives","Peronsal_Defensives","Mana_Regen","Movable_Cast_Auras","Other","PvE","SnareSpecial","SnarePhysical70","SnareMagic70",
																	"SnarePhysical50","SnarePosion50","SnareMagic50","SnarePhysical30","SnareMagic30","Snare",
																	}
--Interrupts
	local CategoriesCheckButtons = { }
	local FriendlyInterrupt = CreateFrame("CheckButton", O..v.."FriendlyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	FriendlyInterrupt:SetScale(.82)
	FriendlyInterrupt:SetHitRectInsets(0, -36, 0, 0)
	_G[O..v.."FriendlyInterruptText"]:SetText(L["CatFriendly"])
	FriendlyInterrupt:SetScript("OnClick", function(self)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframes[frame].maxExpirationTime = 0
			if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
			end
		end
	end)
	tblinsert(CategoriesCheckButtons, { frame = FriendlyInterrupt, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 120, yPos = 5 })

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
		local EnemyInterrupt = CreateFrame("CheckButton", O..v.."EnemyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		EnemyInterrupt:SetScale(.82)
		EnemyInterrupt:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."EnemyInterruptText"]:SetText(L["CatEnemy"])
		EnemyInterrupt:SetScript("OnClick", function(self)
			local frames = { v }
			if v == "arena" then
				frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
			end
			for _, frame in ipairs(frames) do
				LoseControlDB.frames[frame].categoriesEnabled.interrupt.enemy = self:GetChecked()
				LCframes[frame].maxExpirationTime = 0
				if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
					LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
				end
			end
		end)
		tblinsert(CategoriesCheckButtons, { frame = EnemyInterrupt, auraType = "interrupt", reaction = "enemy", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
	end

--Spells
	for _, cat in pairs(catListEnChecksButtons) do
		if not strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

		if not strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
				local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
				EnemyBuff:SetScale(.82)
				EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
				_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
				EnemyBuff:SetScript("OnClick", function(self)
					LoseControlDB.frames[v].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
					LCframes[v].maxExpirationTime = 0
					if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
						LCframes[v]:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
					end
				end)
				tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
			end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
				local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
				EnemyDebuff:SetScale(.82)
				EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
				_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
				EnemyDebuff:SetScript("OnClick", function(self)
					LoseControlDB.frames[v].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
					LCframes[v].maxExpirationTime = 0
					if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
						LCframes[v]:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
					end
				end)
				tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
			end
	end




---Spells Arena
local catListEnChecksButtonsArena = {
		"Drink_Purge",
		"Immune_Arena",
		"CC_Arena",
		"Silence_Arena",
		"Special_High",
		"Ranged_Major_OffenisiveCDs",
		"Roots_90_Snares",
		"Disarms",
		"Melee_Major_OffenisiveCDs",
		"Big_Defensive_CDs",
		"Player_Party_OffensiveCDs",
		"Small_Offenisive_CDs",
		"Small_Defensive_CDs",
		"Freedoms_Speed",
		"Snares_WithCDs",
		"Special_Low",
		"Snares_Ranged_Spamable",
		"Snares_Casted_Melee",
}
	for _, cat in pairs(catListEnChecksButtonsArena) do
		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyBuff:SetScale(.82)
			EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
			EnemyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyDebuff:SetScale(.82)
			EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
			EnemyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
		end
	end


	local CategoriesCheckButtonsPlayer2
	if (v == "player") then
		CategoriesCheckButtonsPlayer2 = { }
		local FriendlyInterruptPlayer2 = CreateFrame("CheckButton", O..v.."FriendlyInterruptPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		FriendlyInterruptPlayer2:SetScale(.82)
		FriendlyInterruptPlayer2:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."FriendlyInterruptPlayer2Text"]:SetText(L["CatFriendly"].."|cfff28614(Icon2)|r")
		FriendlyInterruptPlayer2:SetScript("OnClick", function(self)
			LoseControlDB.frames.player2.categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframeplayer2.maxExpirationTime = 0
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
			end
		end)
		tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyInterruptPlayer2, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
		for _, cat in pairs(catListEnChecksButtons) do
			local FriendlyBuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."BuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuffPlayer2:SetScale(.82)
			FriendlyBuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffPlayer2Text"]:SetText(L["CatFriendlyBuff"].."|cfff28614(Icon2)|r")
			FriendlyBuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.buff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyBuffPlayer2, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
			local FriendlyDebuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."DebuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuffPlayer2:SetScale(.82)
			FriendlyDebuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffPlayer2Text"]:SetText(L["CatFriendlyDebuff"].."|cfff28614(Icon2)|r")
			FriendlyDebuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyDebuffPlayer2, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 359, yPos = 5 })
		end
	end

	local DuplicatePlayerPortrait
	if v == "player" then
		DuplicatePlayerPortrait = CreateFrame("CheckButton", O..v.."DuplicatePlayerPortrait", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DuplicatePlayerPortraitText"]:SetText(L["DuplicatePlayerPortrait"])
		function DuplicatePlayerPortrait:Check(value)
			LoseControlDB.duplicatePlayerPortrait = self:GetChecked()
			local enable = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
			if AlphaSlider2 then
				if enable then
					BlizzardOptionsPanel_Slider_Enable(AlphaSlider2)
				else
					BlizzardOptionsPanel_Slider_Disable(AlphaSlider2)
				end
			end
			if AnchorDropDown2 then
				if enable then
					UIDropDownMenu_EnableDropDown(AnchorDropDown2)
				else
					UIDropDownMenu_DisableDropDown(AnchorDropDown2)
				end
			end
			if CategoriesCheckButtonsPlayer2 then
				if enable then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			LoseControlDB.frames.player2.enabled = enable
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(enable)
			if self:GetChecked() and LoseControlDB.frames.player.anchor ~= "None" then
				local frame = LoseControlDB.frames["player"]
				frame.anchor = "None"
				local AnchorDropDown = _G['LoseControlOptionsPanel'..LCframes.player.unitId..'AnchorDropDown']
				if (AnchorDropDown) then
					UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
				end
				if LCframes.player.MasqueGroup then
					LCframes.player.MasqueGroup:RemoveButton(LCframes.player:GetParent())
					LCframes.player.MasqueGroup:AddButton(LCframes.player:GetParent(), {
						FloatingBG = false,
						Icon = LCframes.player.texture,
						Cooldown = LCframes.player,
						Flash = _G[LCframes.player:GetParent():GetName().."Flash"],
						Pushed = LCframes.player:GetParent():GetPushedTexture(),
						Normal = LCframes.player:GetParent():GetNormalTexture(),
						Disabled = LCframes.player:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[LCframes.player:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = LCframes.player:GetParent():GetHighlightTexture(),
						Hotkey = _G[LCframes.player:GetParent():GetName().."HotKey"],
						Count = _G[LCframes.player:GetParent():GetName().."Count"],
						Name = _G[LCframes.player:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[LCframes.player:GetParent():GetName().."Shine"],
					}, "Button", true)
				end
				LCframes.player.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
				LCframes.player:ClearAllPoints()
				LCframes.player:SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				LCframes.player:GetParent():SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				if LCframes.player.anchor:GetParent() then
					LCframes.player:SetFrameLevel(LCframes.player.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
				if LCframes.player.MasqueGroup then
					LCframes.player.MasqueGroup:ReSkin()
				end
			end
			if enable and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, isFullUpdate, updatedAuras, 0)
			end
		end
		DuplicatePlayerPortrait:SetScript("OnClick", function(self)
			DuplicatePlayerPortrait:Check(self:GetChecked())
		end)
	end

	local Enabled = CreateFrame("CheckButton", O..v.."Enabled", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	_G[O..v.."EnabledText"]:SetText(L["Enabled"])
	Enabled:SetScript("OnClick", function(self)
		local enabled = self:GetChecked()
		if enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Enable(lossOfControl) end
    	if PlayerText then BlizzardOptionsPanel_CheckButton_Enable(PlayerText) end
    	if ArenaPlayerText then BlizzardOptionsPanel_CheckButton_Enable(ArenaPlayerText) end
    	if displayTypeDot then BlizzardOptionsPanel_CheckButton_Enable(displayTypeDot) end
    	if SilenceIcon then BlizzardOptionsPanel_CheckButton_Enable(SilenceIcon) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlFull)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Disable(lossOfControl) end
      if PlayerText then BlizzardOptionsPanel_CheckButton_Disable(PlayerText) end
      if ArenaPlayerText then BlizzardOptionsPanel_CheckButton_Disable(ArenaPlayerText) end
      if displayTypeDot then BlizzardOptionsPanel_CheckButton_Disable(displayTypeDot) end
      if SilenceIcon then BlizzardOptionsPanel_CheckButton_Disable(SilenceIcon) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(GRAY_FONT_COLOR:GetRGB())

			for k, catGrey in ipairs(CategoriesLabels) do
			catGrey:SetVertexColor(GRAY_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlFull)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot)
			UIDropDownMenu_DisableDropDown(AnchorDropDown)
			if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
			if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].enabled = enabled
			local inInstance, instanceType = IsInInstance()
			local enable = enabled and not (
				inInstance and instanceType == "pvp" and (
					( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
					( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
				)
			) and not (
				IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
			)
			LCframes[frame].maxExpirationTime = 0
			LCframes[frame]:RegisterUnitEvents(enable)
			if enable and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
			end
			if (frame == "player") then
				LoseControlDB.frames.player2.enabled = enabled and LoseControlDB.duplicatePlayerPortrait
				LCframeplayer2.maxExpirationTime = 0
				LCframeplayer2:RegisterUnitEvents(enabled and LoseControlDB.duplicatePlayerPortrait)
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(frame, isFullUpdate, updatedAuras, 0)
				end
			end
		end
	end)

	Enabled:SetPoint("TOPLEFT", 8, -4)
	if DisableInBG then DisableInBG:SetPoint("TOPLEFT", Enabled, 275, 0) end
	if EnableGladiusGloss then EnableGladiusGloss:SetPoint("TOPLEFT", Enabled, 275, -25)end
	if DisableInRaid then DisableInRaid:SetPoint("TOPLEFT", Enabled, 275, -25) end
	if ShowNPCInterrupts then ShowNPCInterrupts:SetPoint("TOPLEFT", Enabled, 450, 2);ShowNPCInterrupts:SetScale(.8) end
	if DisablePlayerTargetTarget then DisablePlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -13);DisablePlayerTargetTarget:SetScale(.8) end
	if DisableTargetTargetTarget then DisableTargetTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -28); DisableTargetTargetTarget:SetScale(.8) end
	if DisableFocusFocusTarget then DisableFocusFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -28);DisableFocusFocusTarget:SetScale(.8) end
	if DisablePlayerTargetPlayerTargetTarget then DisablePlayerTargetPlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerTargetPlayerTargetTarget:SetScale(.8) end
	if DisablePlayerFocusPlayerFocusTarget then DisablePlayerFocusPlayerFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerFocusPlayerFocusTarget:SetScale(.8) end
	if DisableTargetDeadTargetTarget then DisableTargetDeadTargetTarget:SetPoint("TOPLEFT", Enabled,450, -58);DisableTargetDeadTargetTarget:SetScale(.8) end
	if DisableFocusDeadFocusTarget then DisableFocusDeadFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -58); DisableFocusDeadFocusTarget:SetScale(.8) end

	if DuplicatePlayerPortrait then DuplicatePlayerPortrait:SetPoint("TOPLEFT", Enabled, 275, 0) end
	AnchorDropDown:SetPoint("TOPLEFT", Enabled, "BOTTOMLEFT", -13, -3)
	AnchorDropDown:SetScale(.9)
	AnchorDropDownLabel:SetPoint("BOTTOMLEFT", AnchorDropDown, "TOPRIGHT", 60,-1)
	AnchorDropDownLabel:SetScale(.8)
	SizeSlider:SetPoint("TOPLEFT", Enabled, "TOPRIGHT", 115, -20)
	AlphaSlider:SetPoint("TOPLEFT", SizeSlider, "BOTTOMLEFT", 0, -16)
	CategoriesEnabledLabel:SetPoint("TOPLEFT", AnchorDropDown, "BOTTOMLEFT", 17, -3)

	if L.CategoryEnabledInterruptLabel then L.CategoryEnabledInterruptLabel:SetPoint("TOPLEFT", CategoriesEnabledLabel, "BOTTOMLEFT", 0, -6); L.CategoryEnabledInterruptLabel:SetScale(.75) end

	if v ~= "arena" then
		local labels ={
		  L.CategoryEnabledCCLabel,L.CategoryEnabledSilenceLabel,L.CategoryEnabledRootPhyiscal_SpecialLabel,L.CategoryEnabledRootMagic_SpecialLabel,L.CategoryEnabledRootLabel,L.CategoryEnabledImmunePlayerLabel,L.CategoryEnabledDisarm_WarningLabel,L.CategoryEnabledCC_WarningLabel,L.CategoryEnabledEnemy_Smoke_BombLabel,L.CategoryEnabledStealthLabel,L.CategoryEnabledImmuneLabel,L.CategoryEnabledImmuneSpellLabel,L.CategoryEnabledImmunePhysicalLabel,L.CategoryEnabledAuraMastery_Cast_AurasLabel,L.CategoryEnabledROP_VortexLabel,L.CategoryEnabledDisarmLabel,L.CategoryEnabledHaste_ReductionLabel,L.CategoryEnabledDmg_Hit_ReductionLabel,L.CategoryEnabledAOE_DMG_ModifiersLabel,L.CategoryEnabledFriendly_Smoke_BombLabel,L.CategoryEnabledAOE_Spell_RefectionsLabel,L.CategoryEnabledTreesLabel,L.CategoryEnabledSpeed_FreedomsLabel,L.CategoryEnabledFreedomsLabel,L.CategoryEnabledFriendly_DefensivesLabel,L.CategoryEnabledCC_ReductionLabel,L.CategoryEnabledPersonal_OffensivesLabel,L.CategoryEnabledPeronsal_DefensivesLabel,L.CategoryEnabledMana_RegenLabel,L.CategoryEnabledMovable_Cast_AurasLabel,L.CategoryEnabledOtherLabel,L.CategoryEnabledPvELabel,L.CategoryEnabledSnareSpecialLabel,L.CategoryEnabledSnarePhysical70Label,L.CategoryEnabledSnareMagic70Label,L.CategoryEnabledSnarePhysical50Label,L.CategoryEnabledSnarePosion50Label,L.CategoryEnabledSnareMagic50Label,L.CategoryEnabledSnarePhysical30Label,L.CategoryEnabledSnareMagic30Label,L.CategoryEnabledSnareLabel
		  }
	  for k, catEn in ipairs(labels) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labels[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if v == "arena" then
		local labelsArena ={									L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
		              }
	  for k, catEn in ipairs(labelsArena) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
		local labelsArena ={									L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
		              }
	  for k, catEn in ipairs(labelsArena) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 381, 0); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if lossOfControl then lossOfControl:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 390, 7) end
	if lossOfControlInterrupt then lossOfControlInterrupt:SetPoint("TOPLEFT", lossOfControl, "BOTTOMLEFT", 0, -18) end
	if lossOfControlFull then lossOfControlFull:SetPoint("TOPLEFT", lossOfControlInterrupt, "BOTTOMLEFT", 0, -18) end
	if lossOfControlSilence then lossOfControlSilence:SetPoint("TOPLEFT", lossOfControlFull, "BOTTOMLEFT", 0, -18) end
	if lossOfControlDisarm then lossOfControlDisarm:SetPoint("TOPLEFT", lossOfControlSilence, "BOTTOMLEFT", 0, -18) end
	if lossOfControlRoot then lossOfControlRoot:SetPoint("TOPLEFT", lossOfControlDisarm, "BOTTOMLEFT", 0, -18) end
	if v == "player" then
		local LoCOptions = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions:SetText("Blizzard Loss of Control must be \nenabled to discover new spells \n\n|cffff00000:|r Disables Bliz LoC Type \n1: Shows icon for small duartion \n|cff00ff002:|r Shows icon for full duration \n \n ")
		LoCOptions:SetJustifyH("LEFT")
		LoCOptions:SetPoint("TOPLEFT", lossOfControlRoot, "TOPLEFT", -5, -15)
	end

	if PlayerText then PlayerText:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -85) end

  if v == "player" then
    local LoCOptions1 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    LoCOptions1:SetFont("Fonts\\FRIZQT__.TTF", 11 )
    LoCOptions1:SetText("Shows text Type of the Spell")
    LoCOptions1:SetJustifyH("LEFT")
    LoCOptions1:SetPoint("TOPLEFT", PlayerText, "BOTTOMLEFT", 25, 7)
  end

	if ArenaPlayerText then ArenaPlayerText:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -115) end

  if v == "player" then
    local LoCOptions2 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    LoCOptions2:SetFont("Fonts\\FRIZQT__.TTF", 11 )
    LoCOptions2:SetText("Disable PLayer text in Arena")
    LoCOptions2:SetJustifyH("LEFT")
    LoCOptions2:SetPoint("TOPLEFT", ArenaPlayerText, "BOTTOMLEFT", 25, 7)
  end

	if displayTypeDot then displayTypeDot:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -145) end

  if v == "player" then
    local LoCOptions3 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    LoCOptions3:SetFont("Fonts\\FRIZQT__.TTF", 11 )
    LoCOptions3:SetText("Curse/Disease/Magic/Etc..")
    LoCOptions3:SetJustifyH("LEFT")
    LoCOptions3:SetPoint("TOPLEFT", displayTypeDot, "BOTTOMLEFT", 25, 7)
  end

  if SilenceIcon then SilenceIcon:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -200) end

  if v == "player" then
    local LoCOptions4 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    LoCOptions4:SetFont("Fonts\\FRIZQT__.TTF", 11 )
    LoCOptions4:SetText("Shows Silence Icon Left of Frame \nWhen CC'd")
    LoCOptions4:SetJustifyH("LEFT")
    LoCOptions4:SetPoint("TOPLEFT", SilenceIcon, "BOTTOMLEFT", 25, 7)
  end

	for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
		checkbuttonframe.frame:SetPoint("TOPLEFT", checkbuttonframe.anchorPos, checkbuttonframe.xPos, checkbuttonframe.yPos)
	end
	if CategoriesCheckButtonsPlayer2 then
		for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
			checkbuttonframeplayer2.frame:SetPoint("TOPLEFT", checkbuttonframeplayer2.anchorPos, checkbuttonframeplayer2.xPos, checkbuttonframeplayer2.yPos)
		end
	end

	if AnchorDropDown2 then AnchorDropDown2:SetPoint("TOPLEFT", DuplicatePlayerPortrait, "BOTTOMLEFT", -13, -3); AnchorDropDown2:SetScale(.9) end
	if AnchorDropDown2Label then AnchorDropDown2Label:SetPoint("BOTTOMLEFT", AnchorDropDown2, "TOPRIGHT", 60,-2);	AnchorDropDown2Label:SetScale(.8) end
	if AlphaSlider2 then AlphaSlider2:SetPoint("TOPLEFT", AlphaSlider, "TOPRIGHT", 155, 0) end

	OptionsPanelFrame.default = OptionsPanel.default
	OptionsPanelFrame.refresh = function()
		local unitId = v
		if unitId == "party" then
			DisableInBG:SetChecked(LoseControlDB.disablePartyInBG)
			DisableInRaid:SetChecked(LoseControlDB.disablePartyInRaid)
			unitId = "party1"
		elseif unitId == "arena" then
			DisableInBG:SetChecked(LoseControlDB.disableArenaInBG)
			EnableGladiusGloss:SetChecked(LoseControlDB.EnableGladiusGloss)
			unitId = "arena1"
		elseif unitId == "player" then
			DuplicatePlayerPortrait:SetChecked(LoseControlDB.duplicatePlayerPortrait)
			AlphaSlider2:SetValue(LoseControlDB.frames.player2.alpha * 100)
      PlayerText:SetChecked(LoseControlDB.PlayerText)
      ArenaPlayerText:SetChecked(LoseControlDB.ArenaPlayerText)
      displayTypeDot:SetChecked(LoseControlDB.displayTypeDot)
      SilenceIcon:SetChecked(LoseControlDB.SilenceIcon)
			lossOfControl:SetChecked(LoseControlDB.lossOfControl)
			SetCVar("lossOfControl", LoseControlDB.lossOfControl)
			lossOfControlInterrupt:SetValue(LoseControlDB.lossOfControlInterrupt)
			SetCVar("lossOfControlInterrupt", LoseControlDB.lossOfControlInterrupt)

			lossOfControlFull:SetValue(LoseControlDB.lossOfControlFull)
			SetCVar("lossOfControlFull", LoseControlDB.lossOfControlFull)

			lossOfControlSilence:SetValue(LoseControlDB.lossOfControlSilence)
			SetCVar("lossOfControlSilence", LoseControlDB.lossOfControlSilence)

			lossOfControlDisarm:SetValue(LoseControlDB.lossOfControlDisarm)
			SetCVar("lossOfControlDisarm", LoseControlDB.lossOfControlDisarm)

			lossOfControlRoot:SetValue(LoseControlDB.lossOfControlRoot)
			SetCVar("lossOfControlRoot", LoseControlDB.lossOfControlRoot)
		elseif unitId == "target" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTarget)
		elseif unitId == "focus" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocus)
		elseif unitId == "targettarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTargetTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetTarget)
			DisableTargetTargetTarget:SetChecked(LoseControlDB.disableTargetTargetTarget)
			DisablePlayerTargetPlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetPlayerTargetTarget)
			DisableTargetDeadTargetTarget:SetChecked(LoseControlDB.disableTargetDeadTargetTarget)
		elseif unitId == "focustarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocusTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerFocusTarget)
			DisableFocusFocusTarget:SetChecked(LoseControlDB.disableFocusFocusTarget)
			DisablePlayerFocusPlayerFocusTarget:SetChecked(LoseControlDB.disablePlayerFocusPlayerFocusTarget)
			DisableFocusDeadFocusTarget:SetChecked(LoseControlDB.disableFocusDeadFocusTarget)
		end
		LCframes[unitId]:CheckGladiusUnitsAnchors(true)
    LCframes[unitId]:CheckGladdyUnitsAnchors(true)
		LCframes[unitId]:CheckSUFUnitsAnchors(true)
		for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
			if checkbuttonframe.auraType ~= "interrupt" then
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction][checkbuttonframe.categoryType])
			else
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction])
			end
		end
		if CategoriesCheckButtonsPlayer2 then
			for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
				if checkbuttonframeplayer2.auraType ~= "interrupt" then
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction][checkbuttonframeplayer2.categoryType])
				else
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction])
				end
			end
		end
		local frame = LoseControlDB.frames[unitId]
		Enabled:SetChecked(frame.enabled)
		if frame.enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Enable(lossOfControl) end
      if PlayerText then BlizzardOptionsPanel_CheckButton_Enable(PlayerText) end
      if ArenaPlayerText then BlizzardOptionsPanel_CheckButton_Enable(ArenaPlayerText) end
      if displayTypeDot then BlizzardOptionsPanel_CheckButton_Enable(displayTypeDot) end
      if SilenceIcon then BlizzardOptionsPanel_CheckButton_Enable(SilenceIcon) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.lossOfControl then
			 	if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt) end
				if lossOfControlFull then BlizzardOptionsPanel_Slider_Enable(lossOfControlFull) end
				if lossOfControlSilence then BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence) end
				if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm) end
				if lossOfControlRoot then BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot) end
				--
			else
				if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
				if lossOfControlFull then BlizzardOptionsPanel_Slider_Disable(lossOfControlFull) end
				if lossOfControlSilence then BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence) end
				if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm) end
				if lossOfControlRoot then BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot) end
			end
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Disable(lossOfControl) end
      if PlayerText then BlizzardOptionsPanel_CheckButton_Disable(PlayerText) end
      if ArenaPlayerText then BlizzardOptionsPanel_CheckButton_Disable(ArenaPlayerText) end
      if displayTypeDot then BlizzardOptionsPanel_CheckButton_Disable(displayTypeDot) end
      if SilenceIcon then BlizzardOptionsPanel_CheckButton_Disable(SilenceIcon) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
			UIDropDownMenu_DisableDropDown(AnchorDropDown)
			if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
			if lossOfControlFull then BlizzardOptionsPanel_Slider_Disable(lossOfControlFull) end
			if lossOfControlSilence then BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence) end
			if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm) end
			if lossOfControlRoot then BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot) end
			if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
			if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		SizeSlider:SetValue(frame.size)
		AlphaSlider:SetValue(frame.alpha * 100)
		UIDropDownMenu_Initialize(AnchorDropDown, function() -- called on refresh and also every time the drop down menu is opened
			AddItem(AnchorDropDown, L["None"], "None")
			AddItem(AnchorDropDown, "Blizzard", "Blizzard")
			if PartyAnchor5 then AddItem(AnchorDropDown, "Bambi's UI", "BambiUI") end
			if Gladius then AddItem(AnchorDropDown, "Gladius", "Gladius") end
      if IsAddOnLoaded("Gladdy") then AddItem(AnchorDropDown, "Gladdy", "Gladdy") end
			if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown, "Perl", "Perl") end
			if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown, "XPerl", "XPerl") end
			if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown, "LUI", "LUI") end
			if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown, "SUF", "SUF") end
			if _G[anchors["SyncFrames"][unitId]] or (type(anchors["SyncFrames"][unitId])=="table" and anchors["SyncFrames"][unitId]) then AddItem(AnchorDropDown, "SyncFrames", "SyncFrames") end

		end)
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		if AnchorDropDown2 then
			UIDropDownMenu_Initialize(AnchorDropDown2, function() -- called on refresh and also every time the drop down menu is opened
				AddItem(AnchorDropDown2, "Blizzard", "Blizzard")
				if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown2, "Perl", "Perl") end
				if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown2, "XPerl", "XPerl") end
				if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown2, "LUI", "LUI") end
				if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown2, "SUF", "SUF") end
			end)
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, LoseControlDB.frames.player2.anchor)
		end
	end

	InterfaceOptions_AddCategory(OptionsPanelFrame)
end

-------------------------------------------------------------------------------
SLASH_LoseControl1 = "/lc"
SLASH_LoseControl2 = "/losecontrol"

local SlashCmd = {}
function SlashCmd:help()
	print("|cff00ccffLoseControl|r", ": slash commands")
	print("    reset [<unit>]")
	print("    lock")
	print("    unlock")
	print("    enable <unit>")
	print("    disable <unit>")
end
function SlashCmd:debug(value)
	if value == "on" then
		debug = true
		print(addonName, "debugging enabled.")
	elseif value == "off" then
		debug = false
		print(addonName, "debugging disabled.")
	end
end
function SlashCmd:reset(unitId)
	if unitId == nil or unitId == "" or unitId == "all" then
		OptionsPanel.default()
	elseif unitId == "party" then
		for _, v in ipairs({"party1", "party2", "party3", "party4"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif unitId == "arena" then
		for _, v in ipairs({"arena1", "arena2", "arena3", "arena4", "arena5"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif LoseControlDB.frames[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId] = CopyTable(DBdefaults.frames[unitId])
		LCframes[unitId]:PLAYER_ENTERING_WORLD()
		if (unitId == "player") then
			LoseControlDB.frames.player2 = CopyTable(DBdefaults.frames.player2)
			LCframeplayer2:PLAYER_ENTERING_WORLD()
		end
		print(L["LoseControl reset."].." "..unitId)
	end
	Unlock:OnClick()
	OptionsPanel.refresh()
	for _, v in ipairs({ "player", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
		_G[O..v].refresh()
	end
end
function SlashCmd:lock()
	Unlock:SetChecked(false)
	Unlock:OnClick()
	print(addonName, "locked.")
end
function SlashCmd:unlock()
	Unlock:SetChecked(true)
	Unlock:OnClick()
	print(addonName, "unlocked.")
end
function SlashCmd:enable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = true
		local inInstance, instanceType = IsInInstance()
		local enabled = not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
		)
		LCframes[unitId]:RegisterUnitEvents(enabled)
		if enabled and not LCframes[unitId].unlockMode then
			LCframes[unitId]:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 0)
		end
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait
			LCframeplayer2:RegisterUnitEvents(LoseControlDB.duplicatePlayerPortrait)
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(unitId, isFullUpdate, updatedAuras, 0)
			end
		end
		print(addonName, unitId, "frame enabled.")
	end
end
function SlashCmd:disable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = false
		LCframes[unitId].maxExpirationTime = 0
		LCframes[unitId]:RegisterUnitEvents(false)
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = false
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(false)
		end
		print(addonName, unitId, "frame disabled.")
	end
end


SlashCmdList[addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print("|cff00ccffLoseControl|r", ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end
