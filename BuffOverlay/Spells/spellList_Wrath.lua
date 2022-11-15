BuffOverlay = LibStub("AceAddon-3.0"):NewAddon("BuffOverlay", "AceConsole-3.0")

--[[------------------------------------------------

 If you are editing this file, you should be aware
 that everything can now be done from the in-game
 interface, including adding custom buffs.

 Use the /buffoverlay or /bo command.

------------------------------------------------]]--

-- Lower prio = shown above other buffs

-- Lower prio = shown above other buffs
BuffOverlay.defaultSpells = {
    [58984] = { class = "MISC", prio = 1 }, --Shadow Meld
    [19753] = { class = "PALADIN", prio = 1 }, --Divine Intervention (Paladin)

    -- Death Knight
    [48707] = { class = "DEATHKNIGHT", prio = 10 }, --Anti-Magic Shell
    [48792] = { class = "DEATHKNIGHT", prio = 11 }, --Icebound Fortitude
    [49039] = { class = "DEATHKNIGHT", prio = 12 }, --Lichborne
    [55233] = { class = "DEATHKNIGHT", prio = 13 }, --Vampirir Blood
    [42650] = { class = "DEATHKNIGHT", prio = 14 }, --Army of the Dead
    [49222] = { class = "DEATHKNIGHT", prio = 15 }, --Bone Shield
    [51271] = { class = "DEATHKNIGHT", prio = 16 }, --Unbrekable Armor
    [48263] = { class = "DEATHKNIGHT", prio = 17 }, --Frost Presence

    [47484] = { class = "DEATHKNIGHT", prio = 18 }, --Huddle (Ghoul)

    -- Druid
    [22812] = { class = "DRUID", prio = 20 }, --Barkskin
    [22842] = { class = "DRUID", prio = 21 }, --Frenzied Regeneration
    [61336] = { class = "DRUID", prio = 22 }, --Survival Instincts

    -- Hunter
    [5384] = { class = "HUNTER", prio = 30 }, --Feign Death
    [53476] = { class = "HUNTER", prio = 31 }, --Intervene (Pet)
    [19263] = { class = "HUNTER", prio = 32 }, --Deterrence
    [34471] = {class = "HUNTER", prio = 33}, --The Beast Within (Hunter)

    [1742] = { class = "HUNTER", prio = 39 }, --Cower (Pet)
    [26064] = { class = "HUNTER", prio = 39 }, --Shell Shield (Pet)

    -- Mage
    [66] = { class = "MAGE", prio = 40 }, --Invisibility
    [45438] = { class = "MAGE", prio = 40 }, --Ice Block

    -- Paladin
    [642] = { class = "PALADIN", prio = 50 }, --Divine Shield (Paladin)
    [498] = { class = "PALADIN", prio = 51 }, --Divine Protection
    [20236] = { class = "PALADIN", prio = 52}, --Lay on Hnads
              ["Lay on Hands"] = { parent = 20236 }, --Suffering 10% Miss Chance
    [31852] = { class = "PALADIN", prio = 53 }, --Ardent Defender
    [31884] = { class = "PALADIN", prio = 54 }, --Avenging Wrath

    -- Priest
    [27827] = { class = "PRIEST", prio = 60 }, --Spirit of Redemption
    [20711] = { class = "PRIEST", prio = 61 }, --Spirit of Redemption
    [47585] = { class = "PRIEST", prio = 62 }, --Dispersion


    -- Rogue
    [26889] = { class = "ROGUE", prio = 70}, --Vanish
          ["Vanish"] = { parent = 26889 },
    [45182] = { class = "ROGUE", prio = 71}, --Cheating Death
    [31224] = { class = "ROGUE", prio = 72 }, --Cloak of Shadows (Rogue)
    [5277] = { class = "ROGUE", prio = 73 }, --Evasion
        [26669] = { parent = 5277 },
    [14278] = { class = "ROGUE", prio = 74 }, --Ghostly Strike
    [51713] = { class = "ROGUE", prio = 75 }, --Shadow Dance


    -- Shaman
    [8178] = { class = "SHAMAN", prio = 80}, --Grounding
    [30823] = { class = "SHAMAN", prio = 81 }, --Shamanistic Rage
    [52179] = { class = "SHAMAN", prio = 82 }, --Astral Shift

    -- Warlock
    [47241] = { class = "WARLOCK", prio = 90 }, --Meta
    [7812] = { class = "WARLOCK", prio = 91 }, --Voidwalker Sac
        [19438] = { parent = 7812 },
        [19440] = { parent = 7812 },
        [19441] = { parent = 7812 },
        [19442] = { parent = 7812 },
        [19443] = { parent = 7812 },
    [18708] = { class = "WARLOCK", prio = 92 }, --Fel Dom

    [4511] = { class = "WARLOCK", prio = 99 }, --Phase Shift (Pet)

    -- Warrior
    [3411] = { class = "WARRIOR", prio = 100 }, --Intervene
    [23920] = { class = "WARRIOR", prio = 101 }, --Spell Reflection
        [59725] = { parent = 23920 },
    [46924] = { class = "WARRIOR", prio = 102 }, --Bladestorm (Warrior)
    [871] = { class = "WARRIOR", prio = 103 }, --Shield Wall
    [55694] = { class = "WARRIOR", prio = 104 }, --Enrage Regn
    [20230] = { class = "WARRIOR", prio = 105 }, --Retaliation
    [12975] = { class = "WARRIOR", prio = 106 }, --Last Stand
          ["Last Stand"] = { parent = 12975 }, --Last Stand
    [2565] = { class = "WARRIOR", prio = 107 }, --Shield Block
    [18499] = { class = "WARRIOR", prio = 108 }, --Berserker Rage



    -- Misc



    ---Oh Shit Warning
    [65925]= { class = "MISC", prio = 150 }, --Unrelenting Assault
          ["Unrelenting Assault"] = { parent = 65925 }, --Unrelenting Assault
    [3034] = { class = "MISC", prio = 150 }, --Viper Sting (Mana Drain)
    [11198] = { class = "MISC", prio = 151 }, --Expose Armor
          ["Expose Armor"] = { parent = 11198 }, --Expose Armor
    [7386] = { class = "MISC", prio = 152 }, --Sunder Armor
          ["Sunder Armor"] = { parent = 7386 }, --Expose Armor
    [59161] = { class = "MISC", prio = 152 }, --Haunt
          ["Haunt"] = { parent = 59161 }, --Haunt


    --Reduced Cast
    [5760] = { class = "MISC", prio = 160 }, --"Mind-numbing Poison"
            ["Mind-numbing Poison"] = { parent = 5760 }, --"Mind-numbing Poison"
    [11719] = { class = "MISC", prio = 161 }, --"Curse of Tongues"
            ["Curse of Tongues"] = { parent = 11719 }, --Curse of Tongues"

    --Reduced DMG
    [47990] = { class = "MISC", prio = 170}, --Suffering 10% Miss Chance
            ["Suffering"] = { parent = 47990 }, --Suffering 10% Miss Chance
    [51693] = { class = "MISC", prio = 171}, --Waylay DANCING*
    [14251] = { class = "MISC", prio = 172}, --Riposte
    [89] = { class = "MISC", prio = 172}, --Criple

    [702] = { class = "MISC", prio = 175 }, --Curse of Weakness
            ["Curse of Weakness"] = { parent = 702 }, --Curse of Weakness

}
