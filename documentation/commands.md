# PlayerCommands
Commands given by players, some examples include:
- Move to point A
- Go to A, pick up B, deliver to C

Each tick the highest ordered command is evaluated, resulting in 0 or more actions. The actions are passed down the rest of the tick execution system and used in various systems accordingly.
