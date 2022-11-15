
local debuffnumber = 3

DebuffFilter = CreateFrame("Frame")
DebuffFilter.cache = {}

local DEFAULT_BUFF = 9 --This Number Needs to Equal the Number of tracked Table Buffs
local DEFAULT_DEBUFF = 3

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

local SmokeBombAuras = {}
local DuelAura = {}


local PriorityBuff = {}
for i = 1, DEFAULT_BUFF do
	if not PriorityBuff[i] then PriorityBuff[i] = {} end
end

PriorityBuff[1] = {
--"Power Infusion",
"Renew",
}

PriorityBuff[2] = {
"Prayer of Mending",
}

PriorityBuff[3] = {
"Power Word: Shield",
}

--Lower Right on Icon 1
PriorityBuff[4] = {
"Power Word: Fortitude",
48162, --Power Word: Fortitude
48161, --Power Word: Fortitude AOE
}

--Lower Left on Icon 1
PriorityBuff[5] = {
"Prayer of Spirit",
"Divine Spirit",
"Arcane Intellect",
"Arcane Brilliance",
"Dalaran Brilliance",
}

--Upper Left on Icon 1
PriorityBuff[6] = {
"Prayer of Shadow Protection",
"Shadow Protection",
48170, --Prayer of Shadow Protection
}
--Upper Right on Icon 1
PriorityBuff[7] = {
"Vampiric Embrace",
15286,
}

--UPPER RIGHT PRIO COUNT
PriorityBuff[8] = {
"Inner Fire"
}
--UPPER LEFT PRIO COUNT
PriorityBuff[9] = {
"inputspellhere",
}

local Buff = {}
for i = 1, DEFAULT_BUFF do
	for k, v in ipairs(PriorityBuff[i]) do
		if not Buff[i] then Buff[i] = {} end
		Buff[i][v] = k
	end
end

-- data from LoseControl
local spellIds = {

-----------------------------------------------------------------DONT SHOWs------------------------------------------------------------------------------------
	[57723] = "Hide",  --Exhaustion
	[57724] = "Hide",  --Sated
	[264689] = "Hide", --Fatigued

-----------------------------------------------------------------PRIORITYs------------------------------------------------------------------------------------

--[Bandage Debuff] = "Priority", --First Aid CD

-----------------------------------------------------------------WARNINGs------------------------------------------------------------------------------------
--DK
	--[49194] = "Warning", --Unholy Blight

--DRUID
	[13424] = "Warning", --Faerie Fire Rank 1
	[13752] = "Warning", --Faerie Fire Rank 2
	[770] = "Warning", --Faerie Fire Rank 3
	[33600] = "Warning", --Improved Faerie Fire Rank 1
	[33601] = "Warning", --Improved Faerie Fire Rank 2
	[33602] = "Warning", --Improved Faerie Fire Rank 3
	[16857] = "Warning", --Faerie Fire (Feral)
	[60089] = "Warning", --Faerie Fire (Feral)
	[5570] = "Warning", --Insect Swarm (Rank 1)
	[24974] = "Warning", --Insect Swarm (Rank 2)
	[24975] = "Warning", --Insect Swarm (Rank 3)
	[24976] = "Warning", --Insect Swarm (Rank 4)
	[24981] = "Warning", --Insect Swarm (Rank 5)

--HUNTER
--[[[19434]  = "Warning",	--Aimed Shot (rank 1) (healing effects reduced by 50%)
	[20900]  = "Warning",	--Aimed Shot (rank 2) (healing effects reduced by 50%)
	[20901]  = "Warning",	--Aimed Shot (rank 3) (healing effects reduced by 50%)
	[20902]  = "Warning",	--Aimed Shot (rank 4) (healing effects reduced by 50%)
	[20903]  = "Warning",	--Aimed Shot (rank 5) (healing effects reduced by 50%)
	[20904]  = "Warning",	--Aimed Shot (rank 6) (healing effects reduced by 50%)
	[27065]  = "Warning",	--Aimed Shot (rank 7) (healing effects reduced by 50%)
	[49049]  = "Warning",	--Aimed Shot (rank 8) (healing effects reduced by 50%)
	[49050]  = "Warning",	--Aimed Shot (rank 9) (healing effects reduced by 50%)
	[53301] = "Warning",	--Explosive Shot Rank 1
	[60051] = "Warning",	--Explosive Shot  Rank 2
	[60052] = "Warning",	--Explosive Shot  Rank 3
	[60053] = "Warning",	--Explosive Shot  Rank 4
	[1130] = "Warning",	  --Hunter's Mark Rank 1
	[14323] = "Warning",	--Hunter's Mark  Rank 2
	[14324] = "Warning",	--Hunter's Mark  Rank 3
	[14325] = "Warning",	--Hunter's Mark  Rank 4
	[53338] = "Warning",	--Hunter's Mark  Rank 5]]


--MAGE
	[41425] = "Warning", --Hypothermia

--PALLY
	[25771] = "Warning", --Forbearance

--PRIEST
	--[34914] = "Warning", --Vampiric Touch Rank 1
	--[34916] = "Warning", --Vampiric Touch Rank 2
	--[34917] = "Warning", --Vampiric Touch Rank 3

--ROGUE
	--[25810] = "Warning", --Mind-Numbing Poison 50
	--[34615] = "Warning", --Mind-Numbing Poison 50
	--[41190] = "Warning", --Mind-Numbing Poison 50
	--[5760] = "Warning",  --Mind-Numbing Poison I 40
	--[8692] = "Warning",  --Mind-Numbing Poison II 50
	--[11398] = "Warning", --Mind-Numbing Poison III 60
	[30984] = "Warning", --Wound Poison
	[39665] = "Warning", --Wound Poison
	[36974] = "Warning", --Wound Poison
	[13218] = "Warning", --Wound Poison Rank 1 (always stacks to 50%)
	[13222] = "Warning", --Wound Poison Rank 2 (always stacks to 50%)
	[13223] = "Warning", --Wound Poison Rank 3 (always stacks to 50%)
	[13224] = "Warning", --Wound Poison Rank 4 (always stacks to 50%)
	[43461] = "Warning", --Wound Poison Rank 5 (always stacks to 50%)
	[27189] = "Warning", --Wound Poison Rank 5 (always stacks to 50%)

--SHAMAN
	[8050] = "Warning",  --Flame Shock Rank 1
	[8052] = "Warning",  --Flame Shock Rank 2
	[8053] = "Warning",  --Flame Shock Rank 3
	[10447] = "Warning", --Flame Shock Rank 4
	[10448] = "Warning", --Flame Shock Rank 5
	[29228] = "Warning", --Flame Shock Rank 6
	[25457] = "Warning", --Flame Shock Rank 7

--WARLOCK
	[1490] = "Warning",  --Curse of Elements Rank 1
	[11721] = "Warning", --Curse of Elements Rank 2
	[11722] = "Warning", --Curse of Elements Rank 3
	[27228] = "Warning", --Curse of Elements Rank 4

--OTHER
	--[46392] = "Warning", --Focused Assault (flag carrier, increasing damage taken by 10%)

-----------------------------------------------------------------DANGERs------------------------------------------------------------------------------------
--Dk
	[49206] ="Biggest", --Summon Gargoyle
	[49194] = "Big", --Unholy Blight
	[50536] = "Big", --Unholy Blight
	[53640] = "Big", --Unholy Blight
	[53641] = "Big", --Unholy Blight

--DRUID

--HUNTER
	[3674] = "Big",  --Black Arrow Rank 1
	[63668] = "Big", --Black Arrow Rank 2
	[63669] = "Big", --Black Arrow Rank 3
	[63670] = "Big", --Black Arrow Rank 4
	[63671] = "Big", --Black Arrow Rank 5
	[63672] = "Big", --Black Arrow Rank 6
	[19434]  = "Bigger",	--Aimed Shot (rank 1) (healing effects reduced by 50%)
	[20900]  = "Bigger",	--Aimed Shot (rank 2) (healing effects reduced by 50%)
	[20901]  = "Bigger",	--Aimed Shot (rank 3) (healing effects reduced by 50%)
	[20902]  = "Bigger",	--Aimed Shot (rank 4) (healing effects reduced by 50%)
	[20903]  = "Bigger",	--Aimed Shot (rank 5) (healing effects reduced by 50%)
	[20904]  = "Bigger",	--Aimed Shot (rank 6) (healing effects reduced by 50%)
	[27065]  = "Bigger",	--Aimed Shot (rank 7) (healing effects reduced by 50%)
	[49049]  = "Bigger",	--Aimed Shot (rank 8) (healing effects reduced by 50%)
	[49050]  = "Bigger",	--Aimed Shot (rank 9) (healing effects reduced by 50%)


--MAGE

--PALLY

--PRIEST
	--[2944] = "Big",  --Devouring Plague Rank 1
	--[19276] = "Big", --Devouring Plague Rank 2
	--[19277] = "Big", --Devouring Plague Rank 3
	--[19278] = "Big", --Devouring Plague Rank 4
	--[19279] = "Big", --Devouring Plague Rank 5
	--[19280] = "Big", --Devouring Plague Rank 6
	--[25467] = "Big", --Devouring Plague Rank 7
	--[48299] = "Big", --Devouring Plague Rank 8
	--[48300] = "Big", --Devouring Plague Rank 9

--ROGUE
	--[8647] = "Big",  --Expose Armor Rank 1
	--[8649] = "Big",  --Expose Armor Rank 2
	--[8650] = "Big",  --Expose Armor Rank 3
	--[11197] = "Big", --Expose Armor Rank 4
	--[11198] = "Big", --Expose Armor Rank 5
	--[26866] = "Big", --Expose Armor Rank 6
	[13218] =  "Bigger",				-- Wound Poison (rank 1) (healing effects reduced by 50%)
	[13222] =  "Bigger",				-- Wound Poison II (rank 2) (healing effects reduced by 50%)
	[13223] =  "Bigger",				-- Wound Poison III (rank 3) (healing effects reduced by 50%)
	[13224] =  "Bigger",				-- Wound Poison IV (rank 4) (healing effects reduced by 50%)
	[27189] = "Bigger",				-- Wound Poison V (rank 5) (healing effects reduced by 50%)
	[57974] =  "Bigger",				-- Wound Poison VI (rank 6) (healing effects reduced by 50%)
	[57975] = "Bigger",				-- Wound Poison VII (rank 7) (healing effects reduced by 50%)

--SHAMAN

--WARLOCK
	[18265] = "Big", --Siphon Life Rank 1
	[18879] = "Big", --Siphon Life Rank 1
	[18880] = "Big", --Siphon Life Rank 1
	[18881] = "Big", --Siphon Life Rank 1
	[27264] = "Big", --Siphon Life Rank 1
	[30911] = "Big", --Siphon Life Rank 1
	[603] = "Big",   --Curse of Doom Rank 1
	[30910] = "Big", --Curse of Doom Rank 2

--WARRIOR
	[12294] = "Bigger",					-- Mortal Strike (rank 1) (healing effects reduced by 50%)
	[21551] = "Bigger",					-- Mortal Strike (rank 2) (healing effects reduced by 50%)
	[21552] = "Bigger",					-- Mortal Strike (rank 3) (healing effects reduced by 50%)
	[21553] = "Bigger",					-- Mortal Strike (rank 4) (healing effects reduced by 50%)
	[25248] = "Bigger",					-- Mortal Strike (rank 5) (healing effects reduced by 50%)
	[30330] = "Bigger",					-- Mortal Strike (rank 6) (healing effects reduced by 50%)
	[47485] = "Bigger",					-- Mortal Strike (rank 7) (healing effects reduced by 50%)
	[47486] = "Bigger",					-- Mortal Strike (rank 8) (healing effects reduced by 50%)


--OTHER



--WARRIOR

}

local bgBiggerspellIds = {
	--CC--
	[51209] = "True",				-- Hungering Cold (talent)
	[47481] = "True",				-- Gnaw

	[9005] = "True",				-- Pounce (rank 1)
	[9823] = "True",				-- Pounce (rank 2)
	[9827] = "True",				-- Pounce (rank 3)
	[27006] = "True",				-- Pounce (rank 4)
	[49803] = "True",				-- Pounce (rank 5)
	[5211] = "True",				-- Bash (rank 1)
	[6798] = "True",				-- Bash (rank 2)
	[8983] = "True",				-- Bash (rank 3)
	[2637] = "True",				-- Hibernate (rank 1)
	[18657] = "True",				-- Hibernate (rank 2)
	[18658] = "True",				-- Hibernate (rank 3)
	[33786] = "True",				-- Cyclone
	[22570] = "True",				-- Maim (rank 1)
	[49802] = "True",				-- Maim (rank 2)

	[1513] = "True",				-- Scare Beast (rank 1)
	[14326] = "True",				-- Scare Beast (rank 2)
	[14327] = "True",				-- Scare Beast (rank 3)
	[3355] = "True",				-- Freezing Trap (rank 1)
	[14308] = "True",				-- Freezing Trap (rank 2)
	[14309] = "True",				-- Freezing Trap (rank 3)
	[60210] = "True",				-- Freezing Arrow Effect
	[19386] = "True",				-- Wyvern Sting (talent) (rank 1)
	[24132] = "True",				-- Wyvern Sting (talent) (rank 2)
	[24133] = "True",				-- Wyvern Sting (talent) (rank 3)
	[27068] = "True",				-- Wyvern Sting (talent) (rank 4)
	[49011] = "True",				-- Wyvern Sting (talent) (rank 5)
	[49012] = "True",				-- Wyvern Sting (talent) (rank 6)
	[19503] = "True",				-- Scatter Shot (talent)

	[24394] = "True",				-- Intimidation (talent)
	[50519] = "True",				-- Sonic Blast (rank 1) (Bat)
	[53564] = "True",				-- Sonic Blast (rank 2) (Bat)
	[53565] = "True",				-- Sonic Blast (rank 3) (Bat)
	[53566] = "True",				-- Sonic Blast (rank 4) (Bat)
	[53567] = "True",				-- Sonic Blast (rank 5) (Bat)
	[53568] = "True",				-- Sonic Blast (rank 6) (Bat)
	[50518] = "True",				-- Ravage (rank 1) (Ravager)
	[53558] = "True",				-- Ravage (rank 2) (Ravager)
	[53559] = "True",				-- Ravage (rank 3) (Ravager)
	[53560] = "True",				-- Ravage (rank 4) (Ravager)
	[53561] = "True",				-- Ravage (rank 5) (Ravager)
	[53562] = "True",				-- Ravage (rank 6) (Ravager)

	[118] = "True",				-- Polymorph (rank 1)
	[12824] = "True",				-- Polymorph (rank 2)
	[12825] = "True",				-- Polymorph (rank 3)
	[12826] = "True",				-- Polymorph (rank 4)
	[28271] = "True",				-- Polymorph: Turtle
	[28272] = "True",				-- Polymorph: Pig
	[61305] = "True",				-- Polymorph: Black Cat
	[61721] = "True",				-- Polymorph: Rabbit
	[61780] = "True",				-- Polymorph: Turkey
	[71319] = "True",				-- Polymorph: Turkey
	[61025] = "True",				-- Polymorph: Serpent
	[59634] = "True",				-- Polymorph - Penguin (Glyph)
	[12355] = "True",				-- Impact (talent)
	[31661] = "True",				-- Dragon's Breath (rank 1) (talent)
	[33041] = "True",				-- Dragon's Breath (rank 2) (talent)
	[33042] = "True",				-- Dragon's Breath (rank 3) (talent)
	[33043] = "True",				-- Dragon's Breath (rank 4) (talent)
	[42949] = "True",				-- Dragon's Breath (rank 5) (talent)
	[42950] = "True",				-- Dragon's Breath (rank 6) (talent)
	[44572] = "True",				-- Deep Freeze (talent)

	[853] = "True",				-- Hammer of Justice (rank 1)
	[5588] = "True",				-- Hammer of Justice (rank 2)
	[5589] = "True",				-- Hammer of Justice (rank 3)
	[10308] = "True",				-- Hammer of Justice (rank 4)
	[2812] = "True",				-- Holy Wrath (rank 1)
	[10318] = "True",				-- Holy Wrath (rank 2)
	[27139] = "True",				-- Holy Wrath (rank 3)
	[48816] = "True",				-- Holy Wrath (rank 4)
	[48817] = "True",				-- Holy Wrath (rank 5)
	[20170] = "True",				-- Stun (Seal of Justice)
	[10326] = "True",				-- Turn Evil
	[20066] = "True",				-- Repentance (talent)

	[605] = "True",				-- Mind Control
	[8122] = "True",				-- Psychic Scream (rank 1)
	[8124] = "True",				-- Psychic Scream (rank 2)
	[10888] = "True",				-- Psychic Scream (rank 3)
	[10890] = "True",				-- Psychic Scream (rank 4)
	[9484] = "True",				-- Shackle Undead (rank 1)
	[9485] = "True",				-- Shackle Undead (rank 2)
	[10955] = "True",				-- Shackle Undead (rank 3)
	[64044] = "True",				-- Psychic Horror (talent)

	[2094] = "True",				-- Blind
	[408] = "True",				-- Kidney Shot (rank 1)
	[8643] = "True",				-- Kidney Shot (rank 2)
	[1833] = "True",				-- Cheap Shot
	[6770] = "True",				-- Sap (rank 1)
	[2070] = "True",				-- Sap (rank 2)
	[11297] = "True",				-- Sap (rank 3)
	[51724] = "True",				-- Sap (rank 4)
	[1776] = "True",				-- Gouge

	[39796] = "True",				-- Stoneclaw Stun (Stoneclaw Totem)
	[51514] = "True",				-- Hex
	[58861] = "True",				-- Bash (Spirit Wolf)

	[710] = "True",				-- Banish (rank 1)
	[18647] = "True",				-- Banish (rank 2)
	[5782] = "True",				-- Fear (rank 1)
	[6213] = "True",				-- Fear (rank 2)
	[6215] = "True",				-- Fear (rank 3)
	[5484] = "True",				-- Howl of Terror (rank 1)
	[17928] = "True",				-- Howl of Terror (rank 2)
	[6789] = "True",				-- Death Coil (rank 1)
	[17925] = "True",				-- Death Coil (rank 2)
	[17926] = "True",				-- Death Coil (rank 3)
	[27223] = "True",				-- Death Coil (rank 4)
	[47859] = "True",				-- Death Coil (rank 5)
	[47860] = "True",				-- Death Coil (rank 6)
	[22703] = "True",				-- Inferno Effect
	[30283] = "True",				-- Shadowfury (rank 1) (talent)
	[30413] = "True",				-- Shadowfury (rank 2) (talent)
	[30414] = "True",				-- Shadowfury (rank 3) (talent)
	[47846] = "True",				-- Shadowfury (rank 4) (talent)
	[47847] = "True",				-- Shadowfury (rank 5) (talent)
	[60995] = "True",				-- Demon Charge (metamorphosis talent)
	[54786] = "True",				-- Demon Leap (metamorphosis talent)

	[32752] = "True",			-- Summoning Disorientation
	[6358] = "True",			-- Seduction (Succubus)
	[19482] = "True",			-- War Stomp (Doomguard)
	[30153] = "True",			-- Intercept Stun (rank 1) (Felguard)
	[30195] = "True",			-- Intercept Stun (rank 2) (Felguard)
	[30197] = "True",			-- Intercept Stun (rank 3) (Felguard)
	[47995] = "True",			-- Intercept Stun (rank 4) (Felguard)

	[7922] = "True",				-- Charge (rank 1/2/3)
	[20253] = "True",				-- Intercept
	[5246] = "True",				-- Intimidating Shout
	[20511] = "True",				-- Intimidating Shout
	[12809] = "True",				-- Concussion Blow (talent)
	[46968] = "True",				-- Shockwave (talent)

	[20549] = "True",				-- War Stomp (tauren racial)

}

local bgBigspellIds = {

[47476]= "True",		-- Strangulate
[34490]= "True",		-- Silencing Shot
[18469]= "True",			-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
[55021]= "True",			-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
[63529]= "True",			-- Silenced - Shield of the Templar (talent)
[15487]= "True",			-- Silence (talent)
[1330]= "True",		-- Garrote - Silence
[18425]= "True",			-- Kick - Silenced (talent)
[31117]= "True",		-- Unstable Affliction
[24259]= "True",		-- Spell Lock (Felhunter)
[74347]= "True",			-- Silenced - Gag Order (Improved Shield Bash talent)
[18498]= "True",			-- Silenced - Gag Order (Improved Shield Bash talent)
[25046]= "True",		-- Arcane Torrent (blood elf racial)
[28730]= "True",		-- Arcane Torrent (blood elf racial)

[339] = "True",				-- Entangling Roots (rank 1)
[1062] = "True",				-- Entangling Roots (rank 2)
[5195] = "True",				-- Entangling Roots (rank 3)
[5196] = "True",				-- Entangling Roots (rank 4)
[9852] = "True",				-- Entangling Roots (rank 5)
[9853] = "True",				-- Entangling Roots (rank 6)
[26989] = "True",				-- Entangling Roots (rank 7)
[53308] = "True",				-- Entangling Roots (rank 8)
[19975] = "True",				-- Entangling Roots (rank 1) (Nature's Grasp spell)
[19974] = "True",				-- Entangling Roots (rank 2) (Nature's Grasp spell)
[19973] = "True",				-- Entangling Roots (rank 3) (Nature's Grasp spell)
[19972] = "True",				-- Entangling Roots (rank 4) (Nature's Grasp spell)
[19971] = "True",				-- Entangling Roots (rank 5) (Nature's Grasp spell)
[19970] = "True",				-- Entangling Roots (rank 6) (Nature's Grasp spell)
[27010] = "True",				-- Entangling Roots (rank 7) (Nature's Grasp spell)
[53313] = "True",				-- Entangling Roots (rank 8) (Nature's Grasp spell)
[19675] = "True",				-- Feral Charge Effect (Feral Charge talent)
[45334] = "True",				-- Feral Charge Effect (Feral Charge talent)

[19306] = "True",				-- Counterattack (talent) (rank 1)
[20909] = "True",				-- Counterattack (talent) (rank 2)
[20910] = "True",				-- Counterattack (talent) (rank 3)
[27067] = "True",				-- Counterattack (talent) (rank 4)
[48998] = "True",				-- Counterattack (talent) (rank 5)
[48999] = "True",				-- Counterattack (talent) (rank 6)
[19185] = "True",				-- Entrapment (talent) (rank 1)
[64803] = "True",				-- Entrapment (talent) (rank 2)
[64804] = "True",				-- Entrapment (talent) (rank 3)

[4167] = "True",				-- Web
[4168] = "True",				-- Web II
[4169] = "True",				-- Web III
[25999] = "True",				-- Boar Charge

[122] = "True",				-- Frost Nova (rank 1)
[865] = "True",				-- Frost Nova (rank 2)
[6131] = "True",				-- Frost Nova (rank 3)
[10230] = "True",				-- Frost Nova (rank 4)
[27088] = "True",				-- Frost Nova (rank 5)
[42917] = "True",				-- Frost Nova (rank 6)
[12494] = "True",				-- Frostbite (talent)
[55080] = "True",				-- Shattered Barrier (talent)
[33395] = "True",				-- Freeze

[64695] = "True",				-- Earthgrab (Storm, Earth and Fire talent)
[63685] = "True",				-- Freeze (Frozen Power talent)

[23694] = "True",				-- Improved Hwamstring (talent)
[58373] = "True",				-- Glyph of Hamstring

}

local bgWarningspellIds = {

	[19434]  = "True",	--Aimed Shot (rank 1) (healing effects reduced by 50%)
	[20900]  = "True",	--Aimed Shot (rank 2) (healing effects reduced by 50%)
	[20901]  = "True",	--Aimed Shot (rank 3) (healing effects reduced by 50%)
	[20902]  = "True",	--Aimed Shot (rank 4) (healing effects reduced by 50%)
	[20903]  = "True",	--Aimed Shot (rank 5) (healing effects reduced by 50%)
	[20904]  = "True",	--Aimed Shot (rank 6) (healing effects reduced by 50%)
	[27065]  = "True",	--Aimed Shot (rank 7) (healing effects reduced by 50%)
	[49049]  = "True",	--Aimed Shot (rank 8) (healing effects reduced by 50%)
	[49050]  = "True",	--Aimed Shot (rank 9) (healing effects reduced by 50%)
	[13218] =  "True",				-- Wound Poison (rank 1) (healing effects reduced by 50%)
	[13222] =  "True",				-- Wound Poison II (rank 2) (healing effects reduced by 50%)
	[13223] =  "True",				-- Wound Poison III (rank 3) (healing effects reduced by 50%)
	[13224] =  "True",				-- Wound Poison IV (rank 4) (healing effects reduced by 50%)
	[27189] = "True",				-- Wound Poison V (rank 5) (healing effects reduced by 50%)
	[57974] =  "True",				-- Wound Poison VI (rank 6) (healing effects reduced by 50%)
	[57975] = "True",				-- Wound Poison VII (rank 7) (healing effects reduced by 50%)

	[30108] = "True", -- UA Rank 1
	[30404] = "True", -- UA Rank 2
	[30405] = "True", -- UA Rank 3
	[43522] = "True", -- UA Rank 3
	[47841] = "True", -- UA Rank 4
	[65812] = "True", -- UA Rank 5
	[47843] = "True", -- UA Rank 5

	[34914] = "True", -- Vampiric Touch Rank 1
	[34916] = "True", -- Vampiric Touch Rank 2
	[34917] = "True", -- Vampiric Touch Rank 3
	[48159] = "True", -- Vampiric Touch Rank 4
	[48160] = "True", -- Vampiric Touch Rank 5
	[65490] = "True", -- Vampiric Touch

	[12294] = "True",				-- Mortal Strike (rank 1) (healing effects reduced by 50%)
	[21551] = "True",				-- Mortal Strike (rank 2) (healing effects reduced by 50%)
	[21552] = "True",				-- Mortal Strike (rank 3) (healing effects reduced by 50%)
	[21553] = "True",				-- Mortal Strike (rank 4) (healing effects reduced by 50%)
	[25248] = "True",				-- Mortal Strike (rank 5) (healing effects reduced by 50%)
	[30330] = "True",				-- Mortal Strike (rank 6) (healing effects reduced by 50%)
	[47485] = "True",				-- Mortal Strike (rank 7) (healing effects reduced by 50%)
	[47486] = "True",				-- Mortal Strike (rank 8) (healing effects reduced by 50%)

}


function DebuffFilter:OnLoad()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	CompactRaidFrameContainer:HookScript("OnEvent", DebuffFilter.OnRosterUpdate)
	CompactRaidFrameContainer:HookScript("OnHide", DebuffFilter.ResetStyle)
	CompactRaidFrameContainer:HookScript("OnShow", DebuffFilter.OnRosterUpdate)
end

-- When roster updated, auto apply arena style or reset style
function DebuffFilter:OnRosterUpdate()
	local _,areaType = IsInInstance()
	if not CompactRaidFrameContainer:IsVisible() then return end
	local n = GetNumGroupMembers()
	if n <= 40 then DebuffFilter:ApplyStyle() else DebuffFilter:ResetStyle() end
end

-- If in raid reset style
function DebuffFilter:OnZoneChanged()
	local _,areaType = IsInInstance()
	self:ResetStyle()
	--if areaType ~= "raid" then self:ApplyStyle() end
end

hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
	DebuffFilter:ResetStyle()
	DebuffFilter:OnRosterUpdate()
end)

function DebuffFilter:ApplyStyle() ----- Find A Way to Always Show Debuffs
	if CompactRaidFrameManager.container.groupMode == "flush" then
		for i = 1,80 do
			local f = _G["CompactRaidFrame"..i]
			if f and not self.cache[f] and f.unit and not strfind(f.unit,"target") then --not strfind(f.unit,"pet") then
					f.frame = "CompactRaidFrame"..i
				self:ApplyFrame(f)
				self:UpdateAura(f.unit)
				self:UpdateBuffAura(f.unit)
			end
			if f and not f.inUse and self.cache[f] then
				self:ResetFrame(f)
			end
		end
	elseif CompactRaidFrameManager.container.groupMode == "discrete" then
		for i = 1,8 do
			for j = 1,5 do
				local f = _G["CompactRaidGroup"..i.."Member"..j]
				--CompactUnitFrame_HideAllDispelDebuffs(f)
				if f and not self.cache[f] and f.unit and not strfind(f.unit,"target") then --not strfind(f.unit,"pet") then
					f.frame = "CompactRaidGroup"..i.."Member"..j
					self:ApplyFrame(f)
					self:UpdateAura(f.unit)
					self:UpdateBuffAura(f.unit)
				end
				if f and not f.unit and self.cache[f] then
					self:ResetFrame(f)
				end
				local f = _G["CompactPartyFrameMember"..j] --- Does
				--CompactUnitFrame_HideAllDispelDebuffs(f)
				if f and not self.cache[f] and f.unit  and not strfind(f.unit,"target") then --not strfind(f.unit,"pet") then
					f.frame = "CompactPartyFrameMember"..j
					self:ApplyFrame(f)
					self:UpdateAura(f.unit)
					self:UpdateBuffAura(f.unit)
				end
				if f and not f.unit and self.cache[f] then
					self:ResetFrame(f)
				end
			end
		end
	end
end

function DebuffFilter:CLEU()
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
	-----------------------------------------------------------------------------------------------------------------
	--SmokeBomb Check
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
	end

	-----------------------------------------------------------------------------------------------------------------
	--Shaodwy Duel Enemy Check
	-----------------------------------------------------------------------------------------------------------------
	if ((event == "SPELL_CAST_SUCCESS") and (spellId == 207736)) then
		if sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			if (DuelAura[sourceGUID] == nil) then
				DuelAura[sourceGUID] = {}
			end
			if (DuelAura[destGUID] == nil) then
				DuelAura[destGUID] = {}
			end
			duration = 6
			Ctimer(duration + 1, function()
			DuelAura[sourceGUID] = nil
			DuelAura[destGUID] = nil
			end)
		end
	end
end

local function isBiggestDebuff(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	if spellIds[spellId] == "Biggest"  then
		return true
	else
		return false
	end
end

local function isBiggerDebuff(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if(instanceType =="pvp" or strfind(f.unit,"pet")) and bgBiggerspellIds[spellId] then
		return true
	elseif spellIds[spellId] == "Bigger" and instanceType ~="pvp" then
		return true
	else
		return false
	end
end

local function isBigDebuff(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if (instanceType =="pvp" or strfind(f.unit,"pet")) and bgBigspellIds[spellId] then
		return true
	elseif spellIds[spellId] == "Big"  and instanceType ~="pvp" then
		return true
	else
		return false
	end
end

local function CompactUnitFrame_UtilIsBossDebuff(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId, _, isBossDeBuff = UnitAura(unit, index, "HARMFUL");
	if isBossDeBuff then
		return true
	else
		return false
	end
end

local function CompactUnitFrame_UtilIsBossAura(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId, _, isBossDeBuff = UnitAura(unit, index, "HELPFUL");
	if isBossDeBuff then
		return true
	else
		return false
	end
end

local function isWarning(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if (instanceType=="pvp" or strfind(f.unit,"pet")) and bgWarningspellIds[spellId] then
		return true
	elseif spellIds[spellId] == "Warning"  and instanceType ~="pvp" then
		return true
	else
		return false
	end
end


local function isPriority(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
		if spellIds[spellId] == "Priority" then
		return true
	else
		return false
	end
end

local function isDebuff(unit, index, filter, f)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	if spellIds[spellId] == "Hide" then
		return false
	else
	  return true
	end
end

local function isBuff(unit, index, filter, j)
  local name, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, index, "HELPFUL");
	if Buff[j][spellId] or Buff[j][name] then
		return true
	else
	  return false
	end
end

-- Update aura for each unit
function DebuffFilter:UpdateAura(uid)
	for f,v in pairs(self.cache) do
		if f.unit == uid then
			local filter = nil
			local debuffNum = 1
			local index = 1
			local hidedebuffs = 0
			if ( f.optionTable.displayOnlyDispellableDebuffs ) then
				filter = "RAID"
			end
			--Biggest Debuffs
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, nil)
				if ( debuffName ) then
						if isBiggestDebuff(uid, index, nil, f) then
						local debuffFrame = v.debuffFrames[debuffNum]
						local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
						name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
						debuffFrame.filter = filter;
						debuffFrame.icon:SetTexture(icon);
						debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
						debuffFrame.icon:SetVertexColor(1, 1, 1);
						debuffFrame.SpellId = spellId
						debuffFrame:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
							GameTooltip:SetSpellByID(spellId)
							GameTooltip:Show()
						end)
						debuffFrame:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
						if count then
						if ( count > 1 ) then
						local countText = count;
						if ( count >= 100 ) then
						 countText = BUFF_STACKS_OVERFLOW;
						end
						debuffFrame.count:Show();
						debuffFrame.count:SetText(countText);
						else
						debuffFrame.count:Hide();
						end
						end
						debuffFrame:SetID(index);
						local enabled = expirationTime and expirationTime ~= 0;
						if enabled then
						local startTime = expirationTime - duration;
						CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
						else
						CooldownFrame_Clear(debuffFrame.cooldown);
						end
						local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
						debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
						debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.6,f.buffFrames[3]:GetSize()*1.6);
						debuffFrame:Show();
						debuffNum = debuffNum + 1
						hidedebuffs = 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--Bigger Debuff
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, filter);
				if ( debuffName ) then
						if isBiggerDebuff(uid, index, nil, f) and not isBiggestDebuff(uid, index, nil, f) then
							local debuffFrame = v.debuffFrames[debuffNum]
							local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
							name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
							debuffFrame.filter = filter;
							debuffFrame.icon:SetTexture(icon);
							debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
							debuffFrame.icon:SetVertexColor(1, 1, 1);
							debuffFrame.SpellId = spellId
							debuffFrame:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
								GameTooltip:SetSpellByID(spellId)
								GameTooltip:Show()
							end)
							debuffFrame:SetScript("OnLeave", function(self)
								GameTooltip:Hide()
							end)
							if count then
							if ( count > 1 ) then
							local countText = count;
							if ( count >= 100 ) then
							 countText = BUFF_STACKS_OVERFLOW;
							end
							debuffFrame.count:Show();
							debuffFrame.count:SetText(countText);
							else
							debuffFrame.count:Hide();
							end
							end
							debuffFrame:SetID(index);
							local enabled = expirationTime and expirationTime ~= 0;
							if enabled then
							local startTime = expirationTime - duration;
							CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
							else
							CooldownFrame_Clear(debuffFrame.cooldown);
							end
							local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
							debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
							debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.4,f.buffFrames[3]:GetSize()*1.4);
							debuffFrame:Show();
							debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--Big Debuff
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, filter);
				if ( debuffName ) then
						if isBigDebuff(uid, index, nil, f) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) then
							local debuffFrame = v.debuffFrames[debuffNum]
							local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
							name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
							debuffFrame.filter = filter;
							debuffFrame.icon:SetTexture(icon);
							debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
							debuffFrame.icon:SetVertexColor(1, 1, 1);
							debuffFrame.SpellId = spellId
							debuffFrame:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
								GameTooltip:SetSpellByID(spellId)
								GameTooltip:Show()
							end)
							debuffFrame:SetScript("OnLeave", function(self)
								GameTooltip:Hide()
							end)


							----------------------------------------------------------------------------------------------------------------------------------------------
							--SmokeBomb
							----------------------------------------------------------------------------------------------------------------------------------------------
							if spellId == 212183 then -- Smoke Bomb
								if unitCaster and SmokeBombAuras[UnitGUID(unitCaster)] then
									if UnitIsEnemy("player", unitCaster) then --still returns true for an enemy currently under mindcontrol I can add your fix.
										duration = SmokeBombAuras[UnitGUID(unitCaster)].duration --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
										expirationTime = SmokeBombAuras[UnitGUID(unitCaster)].expirationTime
										debuffFrame.icon:SetDesaturated(1) --Destaurate Icon
										debuffFrame.icon:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
									elseif not UnitIsEnemy("player", unitCaster) then --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
										duration = SmokeBombAuras[UnitGUID(unitCaster)].duration --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
										expirationTime = SmokeBombAuras[UnitGUID(unitCaster)].expirationTime
									end
								end
							end

							-----------------------------------------------------------------------------------------------------------------
							--Enemy Duel
							-----------------------------------------------------------------------------------------------------------------
							if spellId == 207736 then --Shodowey Duel enemy on friendly, friendly frame (red)
								if DuelAura[UnitGUID(uid)] then --enemyDuel
									debuffFrame.icon:SetDesaturated(1) --Destaurate Icon
									debuffFrame.icon:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
								else
								end
							end


							if count then
							if ( count > 1 ) then
							local countText = count;
							if ( count >= 100 ) then
							 countText = BUFF_STACKS_OVERFLOW;
							end
							debuffFrame.count:Show();
							debuffFrame.count:SetText(countText);
							else
							debuffFrame.count:Hide();
							end
							end
							debuffFrame:SetID(index);
							local enabled = expirationTime and expirationTime ~= 0;
							if enabled then
							local startTime = expirationTime - duration;
							CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
							else
							CooldownFrame_Clear(debuffFrame.cooldown);
							end
							local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
							debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
							debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.4,f.buffFrames[3]:GetSize()*1.4);
							debuffFrame:Show();
							debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--isBossDeBuff
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, filter);
				if ( debuffName ) then
						if CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) and not isBigDebuff(uid, index, nil, f) then
							local debuffFrame = v.debuffFrames[debuffNum]
							local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
							name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
							debuffFrame.filter = filter;
							debuffFrame.icon:SetTexture(icon);
							debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
							debuffFrame.icon:SetVertexColor(1, 1, 1);
							debuffFrame.SpellId = spellId
							debuffFrame:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
								GameTooltip:SetSpellByID(spellId)
								GameTooltip:Show()
							end)
							debuffFrame:SetScript("OnLeave", function(self)
								GameTooltip:Hide()
							end)
							if count then
							if ( count > 1 ) then
							local countText = count;
							if ( count >= 100 ) then
							 countText = BUFF_STACKS_OVERFLOW;
							end
							debuffFrame.count:Show();
							debuffFrame.count:SetText(countText);
							else
							debuffFrame.count:Hide();
							end
							end
							debuffFrame:SetID(index);
							local enabled = expirationTime and expirationTime ~= 0;
							if enabled then
							local startTime = expirationTime - duration;
							CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
							else
							CooldownFrame_Clear(debuffFrame.cooldown);
							end
							local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
							debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
								--debuffFrame.border:Hide()
								debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.4,f.buffFrames[3]:GetSize()*1.4);
							debuffFrame:Show();
							debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--isBossBuff
			while debuffNum <= debuffnumber do
				local debuffName = UnitBuff(uid, index, filter);
				if ( debuffName ) then
						if CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) and not isBigDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, nil, f) then
							local debuffFrame = v.debuffFrames[debuffNum]
							local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
							name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitBuff(uid, index, filter);
							debuffFrame.filter = filter;
							debuffFrame.icon:SetTexture(icon);
							debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
							debuffFrame.icon:SetVertexColor(1, 1, 1);
							debuffFrame.SpellId = spellId
							debuffFrame:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
								GameTooltip:SetSpellByID(spellId)
								GameTooltip:Show()
							end)
							debuffFrame:SetScript("OnLeave", function(self)
								GameTooltip:Hide()
							end)
							if count then
							if ( count > 1 ) then
							local countText = count;
							if ( count >= 100 ) then
							 countText = BUFF_STACKS_OVERFLOW;
							end
							debuffFrame.count:Show();
							debuffFrame.count:SetText(countText);
							else
							debuffFrame.count:Hide();
							end
							end
							debuffFrame:SetID(index);
							local enabled = expirationTime and expirationTime ~= 0;
							if enabled then
							local startTime = expirationTime - duration;
							CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
							else
							CooldownFrame_Clear(debuffFrame.cooldown);
							end
							local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
							debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
							debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.4,f.buffFrames[3]:GetSize()*1.4);
							debuffFrame:Show();
							debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--isWarning
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, nil)
				if ( debuffName ) then
						if  isWarning(uid, index, nil, f) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) and not isBigDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossAura(uid, index, nil, f) then
							local debuffFrame = v.debuffFrames[debuffNum]
							local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
							name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
							debuffFrame.filter = filter;
							debuffFrame.icon:SetTexture(icon);
							debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
							debuffFrame.icon:SetVertexColor(1, 1, 1);
							debuffFrame.SpellId = spellId
							debuffFrame:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
								GameTooltip:SetSpellByID(spellId)
								GameTooltip:Show()
							end)
							debuffFrame:SetScript("OnLeave", function(self)
								GameTooltip:Hide()
							end)
							if count then
							if ( count > 1 ) then
							local countText = count;
							if ( count >= 100 ) then
							 countText = BUFF_STACKS_OVERFLOW;
							end
							debuffFrame.count:Show();
							debuffFrame.count:SetText(countText);
							else
							debuffFrame.count:Hide();
							end
							end
							debuffFrame:SetID(index);
							local enabled = expirationTime and expirationTime ~= 0;
							if enabled then
							local startTime = expirationTime - duration;
							CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
							else
							CooldownFrame_Clear(debuffFrame.cooldown);
							end
							local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
							debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
							debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.15,f.buffFrames[3]:GetSize()*1.15);
							debuffFrame:Show();
							debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			--Prio
			while debuffNum <= debuffnumber do
				local debuffName = UnitDebuff(uid, index, nil)
				if ( debuffName ) then
					if isPriority(uid, index, nil, f) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) and not isBigDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossAura(uid, index, nil, f) and not isWarning(uid, index, nil, f) then
						local debuffFrame = v.debuffFrames[debuffNum]
						local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
						name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
						debuffFrame.filter = filter;
						debuffFrame.icon:SetTexture(icon);
						debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
						debuffFrame.icon:SetVertexColor(1, 1, 1);
						debuffFrame.SpellId = spellId
						debuffFrame:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
							GameTooltip:SetSpellByID(spellId)
							GameTooltip:Show()
						end)
						debuffFrame:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
						if count then
						if ( count > 1 ) then
						local countText = count;
						if ( count >= 100 ) then
						 countText = BUFF_STACKS_OVERFLOW;
						end
						debuffFrame.count:Show();
						debuffFrame.count:SetText(countText);
						else
						debuffFrame.count:Hide();
						end
						end
						debuffFrame:SetID(index);
						local enabled = expirationTime and expirationTime ~= 0;
						if enabled then
						local startTime = expirationTime - duration;
						CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
						else
						CooldownFrame_Clear(debuffFrame.cooldown);
						end
						local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
						debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
						debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1,f.buffFrames[3]:GetSize()*1);
						debuffFrame:Show();
						debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			index = 1
			while debuffNum <= debuffnumber and hidedebuffs == 0 do
				local debuffName = UnitDebuff(uid, index, filter)
				if ( debuffName ) then
					if ( isDebuff(uid, index, nil, f) and not isBiggestDebuff(uid, index, nil, f) and not isBiggerDebuff(uid, index, nil, f) and not isBigDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, nil, f) and not CompactUnitFrame_UtilIsBossAura(uid, index, nil, f) and not isWarning(uid, index, nil, f) and not isPriority(uid, index, nil, f)) then
						local debuffFrame = v.debuffFrames[debuffNum]
						local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
						name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(uid, index, filter);
						if spellId == 45524 then --Chains of Ice Dk
							--icon = 463560
							--icon = 236922
							icon = 236925
						end
						debuffFrame.filter = filter;
						debuffFrame.icon:SetTexture(icon);
						debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
						debuffFrame.icon:SetVertexColor(1, 1, 1);
						debuffFrame.SpellId = spellId
						debuffFrame:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner (debuffFrame.icon, "ANCHOR_RIGHT")
							GameTooltip:SetSpellByID(spellId)
							GameTooltip:Show()
						end)
						debuffFrame:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
						if count then
						if ( count > 1 ) then
						local countText = count;
						if ( count >= 100 ) then
						 countText = BUFF_STACKS_OVERFLOW;
						end
						debuffFrame.count:Show();
						debuffFrame.count:SetText(countText);
						else
						debuffFrame.count:Hide();
						end
						end
						debuffFrame:SetID(index);
						local enabled = expirationTime and expirationTime ~= 0;
						if enabled then
						local startTime = expirationTime - duration;
						CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
						else
						CooldownFrame_Clear(debuffFrame.cooldown);
						end
						local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
						debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
						debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1,f.buffFrames[3]:GetSize()*1);
						debuffFrame:Show();
						debuffNum = debuffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			for i = debuffNum, debuffnumber do
			local debuffFrame = v.debuffFrames[i];
				if debuffFrame then
					debuffFrame:Hide()
				end
			end
			break
		end
	end
end

function DebuffFilter:UpdateBuffAura(uid)

	for f,v in pairs(self.cache) do
		if f.unit == uid then
			local filter = nil
			local buffNum = 1
			local index, buff, backCount, X
			for j = 1, DEFAULT_BUFF do
				for i = 1, 32 do
					local buffName, _, count, _, _, _, unitCaster, _, _, spellId = UnitBuff(uid, i, nil)
					if ( buffName ) then
						if isBuff(uid, i, nil, j) then
							if (buffName == "Prayer of Mending" or buffName == "Focused Growth") and unitCaster == "player" then backCount = count end 	--Prayer of mending hack
							if Buff[j][buffName] then
								 Buff[j][spellId] =  Buff[j][buffName]
							end
							if  Buff[j][spellId] then
								if not buff or  Buff[j][spellId] <  Buff[j][buff] then
									buff = spellId
									index = i
								end
							end
						end
					else
						break
					end
				end
				if index then
					local name, icon, count, buffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitBuff(uid, index, filter);
					if j == 1 or j == 4 or j == 5 or j == 6 or j == 7 or j == 8 or j == 9 or unitCaster == "player" then
						local buffFrame = v.buffFrames[j]

						if j == 4 or j == 5 or j == 6 or j == 7 then
							if not X then
								v.buffFrames[4]:Hide();v.buffFrames[5]:Hide();v.buffFrames[6]:Hide();v.buffFrames[7]:Hide();
								j = 4
								buffFrame = v.buffFrames[j]; X = j
								--Optimize This so id doesnt fire if the buffs expiration has not changed
							Ctimer(.01, function()
								local frame = f.frame.."BuffOverlayRight"
								if _G[frame] and _G[frame].icon:IsVisible() then
									v.buffFrames[j]:ClearAllPoints()
									v.buffFrames[j]:SetPoint("RIGHT", f, "RIGHT", -5.5, 10)
									--_G[frame].icon:HookScript("OnShow",  function() v.buffFrames[j]:ClearAllPoints() v.buffFrames[j]:SetPoint("RIGHT", f, "RIGHT", -5.5, 8) end)
									--_G[frame].icon:HookScript("OnHide",  function() v.buffFrames[j]:ClearAllPoints() v.buffFrames[j]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5) end)
								else
									v.buffFrames[j]:ClearAllPoints()
									v.buffFrames[j]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
								end
							end)

							else
						   buffFrame = v.buffFrames[X+1]
							 X = X + 1
							end
						end

						buffFrame.icon:SetTexture(icon);
						buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
						buffFrame.icon:SetVertexColor(1, 1, 1);
						buffFrame.SpellId = spellId
						buffFrame:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner (buffFrame.icon, "ANCHOR_RIGHT")
							GameTooltip:SetSpellByID(spellId)
							GameTooltip:Show()
						end)
						buffFrame:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
						if count or backCount then
							if backCount then count = backCount end
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
						end
						if backCount then
							buffFrame.count:ClearAllPoints()
							buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") --, MONOCHROME")
							buffFrame.count:SetPoint("TOPRIGHT", -10, 6.5);
							buffFrame.count:SetJustifyH("RIGHT");
							buffFrame.count:SetTextColor(1, 1 ,0, 1)
						end
						if j == 8 then
							buffFrame.count:ClearAllPoints()
							buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE") --, MONOCHROME")
							buffFrame.count:SetPoint("BOTTOMRIGHT", 2, -5);
							buffFrame.count:SetJustifyH("RIGHT");
							buffFrame.icon:SetVertexColor(1, 1, 1, 0); --Hide Icon for NOW till You MERGE BOR & BOL
							--buffFrame.count:SetTextColor(0, 0 ,0, 1)
						end
						if j == 9 then
							buffFrame.count:ClearAllPoints()
							buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE") --, MONOCHROME")
							buffFrame.count:SetPoint("BOTTOMRIGHT", 2, -5);
							buffFrame.count:SetJustifyH("RIGHT");
							buffFrame.icon:SetVertexColor(1, 1, 1, 0); --Hide Icon for NOW till You MERGE BOR & BOL
							--buffFrame.count:SetTextColor(0, 0 ,0, 1)
						end
						if j == 4 or j == 5 or j == 6 or j == 7 then
							SetPortraitToTexture(buffFrame.icon, icon)
							--buffFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
						end
						buffFrame:SetID(j);
						local startTime = expirationTime - duration;
						if duration > 59.5 then
							CooldownFrame_Clear(buffFrame.cooldown);
						else
							CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
						end
						buffFrame:SetSize(f.buffFrames[3]:GetSize()*1,f.buffFrames[3]:GetSize()*1);
						buffFrame:Show();
					end
				else
					local buffFrame = v.buffFrames[j];
					if buffFrame then
						buffFrame:Hide()
					end
				end
			index = nil; buff = nil; backCount= nil
			end
		end
	end
end

-- Apply style for each frame
function DebuffFilter:ApplyFrame(f)
	self.cache[f] = {}
	local scf = self.cache[f]
	f:SetScript("OnSizeChanged",function() DebuffFilter:ResetFrame(f) DebuffFilter:ApplyFrame(f) end)
	if not scf.buffFrames then scf.buffFrames = {} end
	if not scf.debuffFrames then scf.debuffFrames = {} end
	for j = 1, debuffnumber do
		if not scf.debuffFrames[j] then
			scf.debuffFrames[j] = CreateFrame("Button", nil, UIParent,"CompactDebuffTemplate")
			scf.debuffFrames[j].unit = f.unit
			scf.debuffFrames[j].baseSize = f.buffFrames[3]:GetSize()
			if j == 1 then
				scf.debuffFrames[j]:ClearAllPoints()
				scf.debuffFrames[j]:SetParent(f)
				if strfind(f.unit,"pet") then
					scf.debuffFrames[j]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",3, 3)
				else
					scf.debuffFrames[j]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",3,10)
				end
			else
				scf.debuffFrames[j]:SetParent(f)
				scf.debuffFrames[j]:SetPoint("BOTTOMLEFT",scf.debuffFrames[j-1],"BOTTOMRIGHT",0,0)
			end
			--f.debuffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
			scf.debuffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
			scf.debuffFrames[j]:Hide()
		end
	end
	for j = 1,#f.debuffFrames do
		f.debuffFrames[j]:Hide()
		f.debuffFrames[j]:SetScript("OnShow", f.debuffFrames[j].Hide)
	end

	for j = 1, DEFAULT_BUFF do
		if not scf.buffFrames[j] then
			scf.buffFrames[j] = CreateFrame("Button" ,nil, UIParent, "CompactAuraTemplate")
			scf.buffFrames[j].unit = f.unit
			scf.buffFrames[j].baseSize = f.buffFrames[3]:GetSize()
			scf.buffFrames[j].cooldown:SetDrawSwipe(false)
			if j == 1 then --Buff One
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2.5, 3)
				else
					scf.buffFrames[j]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2.5, 9.5)
				end
			elseif j == 2 then --Buff Two
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				scf.buffFrames[j]:SetPoint("BOTTOMRIGHT", scf.buffFrames[j-1], "BOTTOMLEFT", 0, 0)
			elseif j ==3 then --Buff Three
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				scf.buffFrames[j]:SetPoint("BOTTOMRIGHT", scf.buffFrames[j-1], "BOTTOMLEFT", 0, 0)
			elseif j == 4 or j == 5 or j == 6 or j == 7 then
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if j == 4 then
					if not strfind(f.unit,"pet") then
						scf.buffFrames[j]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
					end
				else
					scf.buffFrames[j]:SetPoint("RIGHT", scf.buffFrames[j -1], "LEFT", 0, 0)
				end
					scf.buffFrames[j]:SetScale(.4)
					scf.buffFrames[j]:SetFrameLevel(3)
					scf.buffFrames[j]:SetFrameStrata("HIGH")

			--[[elseif j == 4 then --Buff Four () --Small Lower RIght
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
						scf.buffFrames[j]:SetPoint("RIGHT", f, "RIGHT", -10, 3)
				end
				scf.buffFrames[j]:SetScale(.5)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")
			elseif j ==5, then --Buff Four () --Small Lower Left
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("BOTTOMLEFT", scf.buffFrames[1], "BOTTOMLEFT", 5, 5)
				end
				scf.buffFrames[j]:SetScale(.265)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")
			elseif j ==6 then --Buff Six () --Small Upper lEft
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("TOPLEFT", scf.buffFrames[1], "TOPLEFT", 5, -5)
				end
				scf.buffFrames[j]:SetScale(.265)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")
			elseif j ==7 then --Buff Seven () Small Upper Right
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("TOPRIGHT", scf.buffFrames[1], "TOPRIGHT", -5, -5)
				end
				scf.buffFrames[j]:SetScale(.265)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")]]
			elseif j ==8 then --Upper Right Count Only
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -1.5)
				end
				scf.buffFrames[j]:SetScale(1.15)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")
			elseif j ==9 then --Upper Left Count Only
				scf.buffFrames[j]:ClearAllPoints()
				scf.buffFrames[j]:SetParent(f)
				if not strfind(f.unit,"pet") then
					scf.buffFrames[j]:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -1.5)
				end
				scf.buffFrames[j]:SetScale(1.15)
				scf.buffFrames[j]:SetFrameLevel(3)
				scf.buffFrames[j]:SetFrameStrata("HIGH")
			end
			scf.buffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
			scf.buffFrames[j]:Hide()
		end
	end
	for j = 1,#f.buffFrames do
		f.buffFrames[j]:Hide()
		f.dispelDebuffFrames[1]:SetAlpha(0); --Hides Dispel Icons in Upper Right
		f.dispelDebuffFrames[2]:SetAlpha(0); --Hides Dispel Icons in Upper Right
		f.dispelDebuffFrames[3]:SetAlpha(0); --Hides Dispel Icons in Upper Right
		f.buffFrames[j]:SetScript("OnShow", f.buffFrames[j].Hide)
	end
end
-- Reset to the original style
function DebuffFilter:ResetStyle()
	for f,_ in pairs(DebuffFilter.cache) do
		DebuffFilter:ResetFrame(f)
	end
end
-- Reset style to each cached frame
function DebuffFilter:ResetFrame(f)
	for k,v in pairs(self.cache[f].debuffFrames) do
		if v then
			v:Hide()
		end
	end
	for k,v in pairs(self.cache[f].buffFrames) do
		if v then
			v:Hide()
		end
	end
	f:SetScript("OnSizeChanged",nil)
	for j = 1,#f.debuffFrames do
		f.debuffFrames[j]:SetScript("OnShow",nil)
	end
	for j = 1,#f.buffFrames do
		f.buffFrames[j]:SetScript("OnShow",nil)
	end

	self.cache[f] = nil
end

-- Event handling
local function OnEvent(self,event,...)
	if event == "VARIABLES_LOADED" then self:OnLoad()
	elseif event == "GROUP_ROSTER_UPDATE" or event == "UNIT_PET" then self:OnRosterUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then self:ResetStyle(); self:OnRosterUpdate()
	elseif event == "ZONE_CHANGED_NEW_AREA" then 	Ctimer(1, function() self:ResetStyle(); self:OnRosterUpdate() end) self:ResetStyle(); self:OnRosterUpdate()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then self:CLEU()
	elseif event == "UNIT_AURA" then self:UpdateAura(...); self:UpdateBuffAura(...) end
end

DebuffFilter:SetScript("OnEvent",OnEvent)
DebuffFilter:RegisterEvent("VARIABLES_LOADED")
_G.DebuffFilter = DebuffFilter
