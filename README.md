# About
This repository contains Matlab scripts for Benes networks.
- `BenesNet_IO2S.m`: finds switch states of a Benes network, given its output.
- `BenesNet_S2IO.m`: finds the output of a Benes networks, given its switch states.
- `benes_test.m`: test script for functionality and speed of `BenesNet_IO2S.m` and `BenesNet_S2IO.m`.

# Notes
- We consider [Benes networks][BN1] that contain only 2-2 switches.
- Input of a Benes network is always `[1:N]`, where `N` is a power of `2`.
- Output of a Benes network is a permutation of `[1:N]`.
- Given a Benes network's output, there can be several sets of switch states that generate that output, `BenesNet_IO2S.m` finds one of them.
- Given a Benes network' switch states, there can be only one output. `BenesNet_S2IO.m` finds that output.

[//]: # (References)

[BN1]: <https://eng.libretexts.org/Bookshelves/Computer_Science/Programming_and_Computation_Fundamentals/Mathematics_for_Computer_Science_(Lehman_Leighton_and_Meyer)/02%3A_Structures/10%3A_Communication_Networks/10.09%3A_Benes_Network>
