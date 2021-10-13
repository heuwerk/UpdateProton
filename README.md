# UpdateProton
This simple shell script checks for the newest Version of Proton-GE-custom and installs it.

It also askes to remove any older installed versions.
## Usage
Place this script in any user directory and run

``./updateproton.sh`` (with e**x**ecute rights), or

``sh updateproton.sh`` in your terminal

## Dependencies
The script aims to use only native GNU-Tools, therefore it should work out of the box on any modern GNU/Linux Machine. It is also POSIX shell compliant.
- wget
- tar
- GNU coreutils

## Planned Features
- implement wget2 as default and wget as fallback option

## Proton-GE-custom
GitHub-Page: https://github.com/GloriousEggroll/proton-ge-custom
