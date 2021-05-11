Raspberry Pi temperature testing setup
======================================

This is my standard scripts for testing and plotting Raspberry Pi temperatures.
It is also a trial of Julia for me.

## Requirement

- A Raspberry Pi installed with:
  - `stress-ng`
  - If plotting is desired:
    - `python3-matplotlib`
    - Julia
    - Pluto.jl

## How to

- Download this repo on a Raspberry Pi.
- Launch tmux if over ssh (to ensure the process doesn't die if your connection
  is closed).
- Run `./measure | tee data/<filename>.csv`. This will take about 20 - 30 minutes.
- For plotting:
  - Run `echo 'import Pluto; Pluto.run()' | julia` in this repository with the
    data.
  - Load plot.jl
