local debug = true
--[==[@debug@
debug = nil
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("Parrot", "enUS", true, debug)

L[" (%d crits)"] = true
L[" (%d gains)"] = true
L[" (%d heal, %d crit)"] = true
L[" (%d heal, %d crits)"] = true
L[" (%d heals)"] = true
L[" (%d heals, %d crit)"] = true
L[" (%d heals, %d crits)"] = true
L[" (%d hit, %d crit)"] = true
L[" (%d hit, %d crits)"] = true
L[" (%d hits)"] = true
L[" (%d hits, %d crit)"] = true
L[" (%d hits, %d crits)"] = true
L[" ([Amount] absorbed)"] = true
L[" ([Amount] blocked)"] = true
L[" ([Amount] overheal)"] = true
L[" ([Amount] overkill)"] = true
L[" ([Amount] resisted)"] = true
L[" ([Amount] vulnerable)"] = true
L["%s Tree"] = true
L["%s failed"] = true
L["%s stole %s"] = true
L["%s!"] = true
L["+Combat"] = true
L["-Combat"] = true
L["<Any text> or <Lua search expression>"] = true
L["<Buff name or spell id>"] = true
L["<Item name>"] = true
L["<Name>"] = true
L["<Skill name>"] = true
L["<Spell name>"] = true
L["<Spell name> or <Item name> or <Path> or <SpellId>"] = true
L["<SpellId>"] = true
L["<Tag>"] = true
L["<Text to show>"] = true
L["AP"] = true
L["Abbreviate"] = true
L["Abbreviate number values displayed (26500 -> 26.5k)"] = true
L["Action"] = true
L["Action Sticky"] = true
L["Add a new filter."] = true
L["Add a new primary condition"] = true
L["Add a new scroll area."] = true
L["Add a new secondary condition"] = true
L["Add a new suppression."] = true
L["Add a new throttle."] = true
L["Alternating"] = true
L["Always hide skill names even when present in the tag"] = true
L["Always hide unit names even when present in the tag"] = true
L["Amount"] = true
L["Amount of damage to compare with"] = true
L["Amount of health to compare"] = true
L["Amount of power to compare"] = true
L["Amount of stacks of the aura"] = true
L["Amount of the damage that was missed."] = true
L["Angled"] = true
L["Animation style"] = true
L["Animation style for normal texts."] = true
L["Animation style for sticky texts."] = true
L["Any"] = true
L["Are you sure?"] = true
L["Artifact power gains"] = true
L["Aura active"] = true
L["Aura fade"] = true
L["Aura gain"] = true
L["Aura stack gain"] = true
L["Aura type"] = true
L["Auras"] = true
L["Avoids"] = true
L["Both"] = true
L["Break up amounts"] = true
L["Break up number values with '%s' (26500 -> %s)"] = true
L["Buff"] = true
L["Buff active"] = true
L["Buff fades"] = true
L["Buff gains"] = true
L["Buff inactive"] = true
L["Buff name"] = true
L["Buff name or spell id"] = true
L["Buff stack gains"] = true
L["Cast started"] = true
L["Center of screen"] = true
L["Change event settings"] = true
L["Check periodically"] = true
L["Classes"] = true
L["Classes affected by this trigger."] = true
L["Click and drag to the position you want."] = true
L["Click to remove"] = true
L["Color"] = true
L["Color by class"] = true
L["Color in which to flash"] = true
L["Color of the text for the current event."] = true
L["Color of the text for this trigger."] = true
L["Color unit names by class"] = true
L["Combat status"] = true
L["Combo point gain"] = true
L["Combo points"] = true
L["Combo points full"] = true
L["Comparator Type"] = true
L["Configuration mode"] = true
L["Configure what the Trigger should look like"] = true
L["Control game options"] = true
L["Cooldowns"] = true
L["Create a new trigger"] = true
L["Critical hits/heals"] = true
L["Crushing blows"] = true
L["Currency gains"] = true
L["Custom font"] = true
L["Damage"] = true
L["Damage types"] = true
L["Debuff"] = true
L["Debuff active"] = true
L["Debuff fades"] = true
L["Debuff gains"] = true
L["Debuff inactive"] = true
L["Debuff stack gains"] = true
L["Direction"] = true
L["Direction for normal texts."] = true
L["Direction for sticky texts."] = true
L["Disable"] = true
L["Disable in pvp"] = true
L["Disable in raids"] = true
L["Disable this module while in a battleground"] = true
L["Disable this module while in a raid instance"] = true
L["Dispel"] = true
L["Dispel fail"] = true
L["Do not shorten spell names."] = true
L["Do not show heal events when 100% of the amount is overheal"] = true
L["DoTs and HoTs"] = true
L["Down, alternating"] = true
L["Down, center-aligned"] = true
L["Down, clockwise"] = true
L["Down, counter-clockwise"] = true
L["Down, left"] = true
L["Down, left-aligned"] = true
L["Down, right"] = true
L["Down, right-aligned"] = true
L["Druid Form"] = true
L["Edge of screen"] = true
L["Edit"] = true
L["Edit search string"] = true
L["Enable icons"] = true
L["Enable the current event."] = true
L["Enable to show crits in the sticky style."] = true
L["Enabled"] = true
L["Enemy buff fades"] = true
L["Enemy buff gains"] = true
L["Enemy debuff fades"] = true
L["Enemy debuff gains"] = true
L["Enter combat"] = true
L["Enter configuration mode, allowing you to move around the scroll areas and see them in action."] = true
L["Environmental damage"] = true
L["Event modifiers"] = true
L["Events"] = true
L["Experience gains"] = true
L["Extra attacks"] = true
L["Filter incoming spells"] = true
L["Filter outgoing spells"] = true
L["Filter when amount is lower than this value (leave blank to filter everything)"] = true
L["Filters"] = true
L["Filters that are applied to a single spell"] = true
L["Filters to be checked for a minimum amount of damage/healing/etc before showing."] = true
L["Flash screen in specified color"] = true
L["Floating Combat Text of awesomeness. Caw. It'll eat your crackers."] = true
L["Font face"] = true
L["Font outline"] = true
L["Font size"] = true
L["General"] = true
L["General settings"] = true
L["Gift of the Wild => Gift of t..."] = true
L["Gift of the Wild => GotW."] = true
L["Glancing hits"] = true
L["Heals"] = true
L["Heals over time"] = true
L["Hide events used in triggers"] = true
L["Hide full overheals"] = true
L["Hide realm"] = true
L["Hide realm in player names"] = true
L["Hide skill names"] = true
L["Hide unit names"] = true
L["Hides combat events when they were used in triggers"] = true
L["Horizontal"] = true
L["Hostility"] = true
L["How fast the text scrolls by."] = true
L["How large of an area to scroll."] = true
L["How opaque/transparent icons should be."] = true
L["How opaque/transparent the text should be."] = true
L["How or whether to shorten spell names."] = true
L["How to compare actual value with parameter"] = true
L["Icon"] = true
L["Icon side"] = true
L["Icon transparency"] = true
L["Ignore"] = true
L["Ignore Cooldown"] = true
L["In a group"] = true
L["In combat"] = true
L["In vehicle"] = true
L["Incoming"] = true
L["Incoming cast"] = true
L["Incoming crit"] = true
L["Incoming damage"] = true
L["Incoming events are events which a mob or another player does to you."] = true
L["Incoming heals"] = true
L["Incoming miss"] = true
L["Inherit"] = true
L["Inherit font size"] = true
L["Interval for collecting data"] = true
L["Item buff active"] = true
L["Item buff fade"] = true
L["Item buff fades"] = true
L["Item buff gain"] = true
L["Item buff gains"] = true
L["Item cooldown ready"] = true
L["Killing Blow!"] = true
L["Killing blows"] = true
L["Leave combat"] = true
L["Left"] = true
L["Left, clockwise"] = true
L["Left, counter-clockwise"] = true
L["Length"] = true
L["List of strings that will be squelched if found."] = true
L["Load config"] = true
L["Load configuration options"] = true
L["Loot"] = true
L["Loot +[Amount]"] = true
L["Loot [Name] +[Amount]([Total])"] = true
L["Loot items"] = true
L["Loot money"] = true
L["Low Health!"] = true
L["Low Mana!"] = true
L["Low Pet Health!"] = true
L["Lua function"] = true
L["Lua search expression"] = true
L["Main hand"] = true
L["Master font settings"] = true
L["Melee absorbs"] = true
L["Melee blocks"] = true
L["Melee damage"] = true
L["Melee deflects"] = true
L["Melee dodges"] = true
L["Melee evades"] = true
L["Melee immunes"] = true
L["Melee misses"] = true
L["Melee parries"] = true
L["Melee reflects"] = true
L["Melee resists"] = true
L["Minimum time the cooldown must have (in seconds)"] = true
L["Miss type"] = true
L["Misses"] = true
L["Monochrome"] = true
L["Mounted"] = true
L["Multiple"] = true
L["NPC killing blows"] = true
L["Name"] = true
L["Name of the currency"] = true
L["Name of the scroll area."] = true
L["Name or ID of the spell"] = true
L["New Amount of stacks of the buff."] = true
L["New Amount of stacks of the debuff."] = true
L["New condition"] = true
L["New filter"] = true
L["New scroll area"] = true
L["New suppression"] = true
L["New throttle"] = true
L["New trigger"] = true
L["None"] = true
L["Normal"] = true
L["Normal font face"] = true
L["Normal font outline"] = true
L["Normal font shadow"] = true
L["Normal font size"] = true
L["Normal inherit font size"] = true
L["Not in Druid Form"] = true
L["Not in combat"] = true
L["Not in vehicle"] = true
L["Not mounted"] = true
L["Notification"] = true
L["Notification events are available to notify you of certain actions."] = true
L["Off"] = true
L["Off hand"] = true
L["On"] = true
L["Only HoTs"] = true
L["Only direct heals"] = true
L["Only return true, if the Aura has been applied by yourself"] = true
L["Options for damage types."] = true
L["Options for event modifiers."] = true
L["Options for this scroll area."] = true
L["Options regarding scroll areas."] = true
L["Other"] = true
L["Outgoing"] = true
L["Outgoing cast"] = true
L["Outgoing crit"] = true
L["Outgoing damage"] = true
L["Outgoing events are events which you do to a mob or another player."] = true
L["Outgoing heals"] = true
L["Outgoing miss"] = true
L["Output"] = true
L["Overheals"] = true
L["Overkills"] = true
L["Own aura"] = true
L["Parabola"] = true
L["Parrot"] = true
L["Partial absorbs"] = true
L["Partial blocks"] = true
L["Partial resists"] = true
L["Pet buff fades"] = true
L["Pet buff gains"] = true
L["Pet damage"] = true
L["Pet debuff fades"] = true
L["Pet debuff gains"] = true
L["Pet dispel"] = true
L["Pet dispel fail"] = true
L["Pet heals"] = true
L["Pet heals over time"] = true
L["Pet melee absorbs"] = true
L["Pet melee blocks"] = true
L["Pet melee damage"] = true
L["Pet melee deflects"] = true
L["Pet melee dodges"] = true
L["Pet melee evades"] = true
L["Pet melee immunes"] = true
L["Pet melee misses"] = true
L["Pet melee parries"] = true
L["Pet melee reflects"] = true
L["Pet melee resists"] = true
L["Pet misses"] = true
L["Pet siege damage"] = true
L["Pet skill DoTs"] = true
L["Pet skill absorbs"] = true
L["Pet skill blocks"] = true
L["Pet skill damage"] = true
L["Pet skill deflects"] = true
L["Pet skill dodges"] = true
L["Pet skill evades"] = true
L["Pet skill immunes"] = true
L["Pet skill interrupts"] = true
L["Pet skill misses"] = true
L["Pet skill parries"] = true
L["Pet skill reflects"] = true
L["Pet skill resists"] = true
L["Player killing blows"] = true
L["Position: %d, %d"] = true
L["Position: horizontal"] = true
L["Position: vertical"] = true
L["Pow"] = true
L["Power change"] = true
L["Power gain"] = true
L["Power gain/loss"] = true
L["Power loss"] = true
L["Power type"] = true
L["Primary conditions"] = true
L["Rainbow"] = true
L["Reactive skills"] = true
L["Reason for the miss"] = true
L["Remove"] = true
L["Remove condition"] = true
L["Remove filter"] = true
L["Remove suppression"] = true
L["Remove this scroll area."] = true
L["Remove this trigger completely."] = true
L["Remove throttle"] = true
L["Remove trigger"] = true
L["Reputation"] = true
L["Reputation gains"] = true
L["Reputation losses"] = true
L["Right"] = true
L["Right, clockwise"] = true
L["Right, counter-clockwise"] = true
L["Scoll area where all events will be shown"] = true
L["Scroll area"] = true
L["Scroll area: %s"] = true
L["Scroll areas"] = true
L["Scrolling speed"] = true
L["Secondary conditions"] = true
L["Seconds for the text to complete the whole cycle, i.e. larger numbers means slower."] = true
L["Self damage"] = true
L["Self damage absorbs"] = true
L["Self damage misses"] = true
L["Self heals"] = true
L["Self heals over time"] = true
L["Semicircle"] = true
L["Send a normal test message."] = true
L["Send a sticky test message."] = true
L["Send a test message through this scroll area."] = true
L["Set the icon side for this scroll area or whether to disable icons entirely."] = true
L["Set whether icons should be enabled or disabled altogether."] = true
L["Short texts"] = true
L["Shorten amounts"] = true
L["Shorten spell names"] = true
L["Show guardian events"] = true
L["Siege damage"] = true
L["Size"] = true
L["Skill DoTs"] = true
L["Skill absorbs"] = true
L["Skill blocks"] = true
L["Skill cooldown finish"] = true
L["Skill damage"] = true
L["Skill deflects"] = true
L["Skill dodges"] = true
L["Skill evades"] = true
L["Skill gains"] = true
L["Skill immunes"] = true
L["Skill interrupts"] = true
L["Skill misses"] = true
L["Skill parries"] = true
L["Skill reflects"] = true
L["Skill resists"] = true
L["Skill you were interrupted in casting"] = true
L["Skill your pet was interrupted in casting"] = true
L["Sound"] = true
L["Spell"] = true
L["Spell filters"] = true
L["Spell name or spell id"] = true
L["Spell overlay"] = true
L["Spell ready"] = true
L["Spell steal"] = true
L["Spell throttles"] = true
L["Spell usable"] = true
L["Sprinkler"] = true
L["Stack count"] = true
L["Static"] = true
L["Sticky"] = true
L["Sticky crits"] = true
L["Sticky font face"] = true
L["Sticky font outline"] = true
L["Sticky font shadow"] = true
L["Sticky font size"] = true
L["Sticky inherit font size"] = true
L["Straight"] = true
L["Strikes"] = true
L["Style"] = true
L["Successful spell cast"] = true
L["Suppressions"] = true
L["Tag"] = true
L["Tag to show for the current event."] = true
L["Target buff gains"] = true
L["Target buff stack gains"] = true
L["Target is NPC"] = true
L["Target is player"] = true
L["Test"] = true
L["Test how the trigger will look and act."] = true
L["Text"] = true
L["Text options"] = true
L["Text transparency"] = true
L["The ability or spell take away your power."] = true
L["The ability or spell used to gain power."] = true
L["The ability or spell your pet used."] = true
L["The amount of currency gained."] = true
L["The amount of damage absorbed."] = true
L["The amount of damage blocked."] = true
L["The amount of damage done."] = true
L["The amount of damage resisted."] = true
L["The amount of experience points gained."] = true
L["The amount of gold looted."] = true
L["The amount of healing done."] = true
L["The amount of items looted."] = true
L["The amount of overhealing."] = true
L["The amount of overkill."] = true
L["The amount of power gained."] = true
L["The amount of power lost."] = true
L["The amount of reputation gained."] = true
L["The amount of reputation lost."] = true
L["The amount of skill points currently."] = true
L["The amount of vulnerability bonus."] = true
L["The character that caused the power loss."] = true
L["The character that the power comes from."] = true
L["The current number of combo points."] = true
L["The enemy that gained the buff"] = true
L["The enemy that gained the debuff"] = true
L["The enemy that lost the buff"] = true
L["The enemy that lost the debuff"] = true
L["The icon that is shown"] = true
L["The length at which to shorten spell names."] = true
L["The name of the ally that healed you."] = true
L["The name of the ally that healed your pet."] = true
L["The name of the ally you healed."] = true
L["The name of the buff gained."] = true
L["The name of the buff lost."] = true
L["The name of the debuff gained."] = true
L["The name of the debuff lost."] = true
L["The name of the enemy slain."] = true
L["The name of the enemy that attacked you."] = true
L["The name of the enemy that attacked your pet."] = true
L["The name of the enemy you attacked."] = true
L["The name of the enemy your pet attacked."] = true
L["The name of the faction."] = true
L["The name of the item buff gained."] = true
L["The name of the item buff lost."] = true
L["The name of the item, the buff has been applied to."] = true
L["The name of the item, the buff has faded from."] = true
L["The name of the item."] = true
L["The name of the pet that gained the buff"] = true
L["The name of the pet that gained the debuff"] = true
L["The name of the pet that lost the buff"] = true
L["The name of the pet that lost the debuff"] = true
L["The name of the spell or ability which is ready to be used."] = true
L["The name of the spell or ability which provided the extra attacks."] = true
L["The name of the spell that has been dispelled."] = true
L["The name of the spell that has been stolen."] = true
L["The name of the spell that has been used for dispelling."] = true
L["The name of the spell that has been used for stealing."] = true
L["The name of the spell that has not been dispelled."] = true
L["The name of the unit from which the spell has been removed."] = true
L["The name of the unit from which the spell has been stolen."] = true
L["The name of the unit from which the spell has not been removed."] = true
L["The name of the unit that dispelled the spell from you"] = true
L["The name of the unit that dispelled the spell from your pet."] = true
L["The name of the unit that failed dispelling the spell from you"] = true
L["The name of the unit that failed dispelling the spell from your pet."] = true
L["The name of the unit that gained the buff."] = true
L["The name of the unit that stole the spell from you"] = true
L["The name of the unit that your pet healed."] = true
L["The normal text."] = true
L["The number of stacks of the buff"] = true
L["The position of the box across the screen"] = true
L["The position of the box up-and-down the screen"] = true
L["The reason the spell or ability missed."] = true
L["The skill which experienced a gain."] = true
L["The spell or ability that the ally healed you with."] = true
L["The spell or ability that the ally healed your pet with."] = true
L["The spell or ability that the enemy attacked you with."] = true
L["The spell or ability that the enemy attacked your pet with."] = true
L["The spell or ability that the pet used to heal."] = true
L["The spell or ability that you used."] = true
L["The spell or ability that your pet used."] = true
L["The spell or ability used to slay the enemy."] = true
L["The spell you interrupted"] = true
L["The spell your pet interrupted"] = true
L["The text that is shown"] = true
L["The total amount of items in inventory."] = true
L["The type of damage done."] = true
L["The type of power gained (Mana, Rage, Energy)."] = true
L["The type of power lost (Mana, Rage, Energy)."] = true
L["The unit that attacked you"] = true
L["The unit that casted the spell"] = true
L["The unit that is affected"] = true
L["The unit that started the cast"] = true
L["The unit that you attacked"] = true
L["Thick"] = true
L["Thin"] = true
L["Thin, Monochrome"] = true
L["Threshold"] = true
L["Throttle events"] = true
L["Throttle time"] = true
L["Throttles that are applied to a single spell"] = true
L["Trigger cooldown"] = true
L["Triggers"] = true
L["Truncate"] = true
L["Type of power"] = true
L["Type of the aura"] = true
L["Uncategorized"] = true
L["Unit"] = true
L["Unit health"] = true
L["Unit power"] = true
L["Up, alternating"] = true
L["Up, center-aligned"] = true
L["Up, clockwise"] = true
L["Up, counter-clockwise"] = true
L["Up, left"] = true
L["Up, left-aligned"] = true
L["Up, right"] = true
L["Up, right-aligned"] = true
L["Use short throttle-texts (like \"2++\" instead of \"2 crits\")"] = true
L["Vulnerability bonuses"] = true
L["What amount to filter out. Any amount below this will be filtered.\nNote: a value of 0 will mean no filtering takes place."] = true
L["What color this damage type takes on."] = true
L["What color this event modifier takes on."] = true
L["What sound to play when the current event occurs."] = true
L["What sound to play when the trigger is shown."] = true
L["What text this event modifier shows."] = true
L["What timespan to merge events within.\nNote: a time of 0s means no throttling will occur."] = true
L["When all of these conditions apply, the trigger will be shown."] = true
L["When any of these conditions apply, the secondary conditions are checked."] = true
L["Whether Parrot should control the default interface's options below.\nThese settings always override manual changes to the default interface options."] = true
L["Whether all events in this category are enabled."] = true
L["Whether events involving your guardian(s) (totems, ...) should be displayed"] = true
L["Whether the current event should be classified as \"Sticky\""] = true
L["Whether the search string is a lua search expression or not."] = true
L["Whether the trigger is enabled or not."] = true
L["Whether the unit should be friendly or hostile"] = true
L["Whether to color damage types or not."] = true
L["Whether to color event modifiers or not."] = true
L["Whether to enable showing this event modifier."] = true
L["Whether to merge mass events into single instances instead of excessive spam."] = true
L["Whether to show this trigger as a sticky."] = true
L["Which animation style to use."] = true
L["Which direction the animations should follow."] = true
L["Which scroll area to output to."] = true
L["Which scroll area to use."] = true
L["Your total amount of the currency."] = true
L["[Num] CP"] = true
L["[Num] CP Finish It!"] = true
L["[Text] (crit)"] = true
L["[Text] (crushing)"] = true
L["[Text] (glancing)"] = true
L["[[Spell] ready!]"] = true
