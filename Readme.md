# Utility Combinators
A set of general utility combinators. Includes: Location Combinators, Bonus Combinators, Research Combinators


## Bonus Combinator
Outputs various force bonus levels:

| Signal               | Bonus                            |
|----------------------|----------------------------------|
| lab                  | laboratory_productivity_bonus |
| logistic-robot       | worker_robots_storage_bonus |
| fast-inserter        | inserter_stack_size_bonus |
| bulk-inserter        | bulk_inserter_capacity_bonus |
| turbo-transport-belt | belt_stack_size_bonus |
| toolbelt-equipment   | character_inventory_slots_bonus |
| big-mining-drill     | mining_drill_productivity_bonus *  100 |
| locomotive           | train_braking_force_bonus |
| signal-heart         | character_health_bonus |
| signal-B             | character_build_distance_bonus |
| signal-D             | character_item_drop_distance_bonus |
| signal-R             | character_resource_reach_distance_bonus |
| signal-I             | character_item_pickup_distance_bonus |
| signal-L             | character_loot_pickup_distance_bonus |
| signal-F             | maximum_following_robot_count |

## Location Combinator

Outputs its location (signal-X and signal-Y) and the index of the current surface (signal-Z).

## Research Combinator

Outputs the science packs required for the current research, the research unit count (signal-stack-size), research time (signal-T), and the current progress in percent (signal-info).
