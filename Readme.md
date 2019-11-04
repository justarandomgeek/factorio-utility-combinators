# Utility Combinators
A set of general utility cominators. Includes: Location Combinators, Bonus Combinators, Player Combinators, Research Combinators


## Bonus Combinator
Outputs various force bonus levels:

|Bonus                                        |Signal    |
|---------------------------------------------|----------|
|force.worker_robots_storage_bonus            | signal-R |
|force.inserter_stack_size_bonus              | signal-I |
|force.stack_inserter_capacity_bonus          | signal-J |
|force.character_logistic_slot_count          | signal-L |
|force.character_trash_slot_count             | signal-T |
|force.quickbar_count                         | signal-Q |
|force.maximum_following_robot_count          | signal-F |
|force.mining_drill_productivity_bonus * 100  | signal-P |

## Location Combinator

Outputs its location (signal-X and signal-Y) and the index of teh current surface (signal-Z).

## Player Combinator

With no input, outputs the total player count (signal-blue) and total online player count (signal-green). With input signal-grey=index, outputs that player's online (signal-green) and admin (signal-red) status, and if the Signal Strings Library is isntalled, the players name.

## Research Combinator

Outputs the science packs required for the current research, the number of reserach cycles (signal-black), and the current progress in percent (signal-grey). If the Signal Strings Library is installed, also outputs the name of the current research.

## Large Combinator

A normal constant combinator with 1000 slots for signals.
