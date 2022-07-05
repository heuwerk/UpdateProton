# UpdateProton
A simple shell script that checks for and installs the latest version of *GE-Proton*.

## Features
- Check for latest versions of *GE-Proton*
- Interactive usage
- Checksum verification
- Delete all old installed versions, if desired
- link to release notes
- POSIX shell compliant
- Display download size

## Usage
Place this script in any user directory and run

``./updateproton.sh`` (with e**x**ecute rights), or

``sh updateproton.sh`` in your terminal

## Dependencies
The script aims to use only native Linux tools, therefore it should work out of the box on any modern Linux machine. It is also POSIX shell compliant.
- wget
- tar
- GNU coreutils

## Planned Features

### Drop old wget tool and use wget2 instead
The problem with this approach is that wget2 is not preinstalled on most distros, so I plan to maintain
two transitional versions. However, only the wget2 version will get new features.

### Print download size
Right now, it is required to look at the GitHub Changelog to see the file size, but I want to integrate that into this tool.

## GE-Proton
GitHub Page: https://github.com/GloriousEggroll/proton-ge-custom
