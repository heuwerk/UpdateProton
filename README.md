# UpdateProton
This simple shell script checks for the newest version of *Proton-GE-custom* and installs it.

## Features
- Check for new versions of *Proton-GE-custom*
- Interactive usage
- Create the required directories if they do not exist
- Checksum verification
- Delete all old installed versions, if desired
- link to GitHub release notes
- POSIX shell compliant

## Usage
Place this script in any user directory and run

``./updateproton.sh`` (with e**x**ecute rights), or

``sh updateproton.sh`` in your terminal

## Dependencies
The script aims to use only native GNU-Tools, therefore it should work out of the box on any modern GNU/Linux machine. It is also POSIX shell compliant.
- wget
- tar
- GNU coreutils

## Planned Features
### Drop old wget tool and use wget2 instead
The problem with this approach is that wget2 is not pre-installed on most distros, so I plan to maintain
two transitional versions. However, only the wget2 version will get new features.

### Non-interactive / Script-Mode
I want to make an additional *script mode* that skips the interactive questions and uses default values. This mode would be optional and only accessible via command line parameter or variable values.

### Print download size
Right now, it is required to look at the GitHub change log to see the file size, but I want to integrate that into this tool.

## Proton-GE-custom
GitHub-Page: https://github.com/GloriousEggroll/proton-ge-custom
