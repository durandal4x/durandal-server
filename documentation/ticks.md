# Ticks
A tick refers to a single iteration of the game execution cycle; a tick is when "stuff happens".

Ticks are broken up into a series of systems, each is executed sequentially and a context is passed through all of them allowing a system further up the chain to relay to those further down the chain (e.g. a command to shoot something will change what happens when the combat system is reached).

