# UpdateProton
A simple shell script that checks for and installs the latest version of *GE-Proton*.

## Features
- Check for latest versions of *GE-Proton*
- Interactive usage
- Checksum verification
- Delete all old installed versions, if desired
- link to release notes
- POSIX shell compliant
- Should run on all major Linux Distributions (tested with Fedora and Debian)
- Display download size

## Usage
1. Download the latest version of the script from the [release page](https://github.com/heuwerk/UpdateProton/releases).
You can also download the latest version from the [main branch](https://github.com/heuwerk/UpdateProton/blob/main/updateproton.sh). This version may be under **active development** and may **contain bugs or be non-functional**.

1. Place this script in any user directory and run

``./updateproton.sh`` (with e**x**ecute rights), or

``sh updateproton.sh`` in your terminal

## Dependencies
The script aims to use only native Linux tools, therefore it should work out of the box on any modern Linux machine. It is also POSIX shell compliant.
- wget
- tar
- GNU coreutils

## Planned Features
*Sorted by priority*

### Support for the Steam Flatpak
At this time, Steam is only supported as a distro package (~/.steam must be present).
I would like to support the flatpak version of Steam in the future.

### Steam restart support
At the end of the script, the user is alerted to restart Steam.
It should be possible to restart Steam automatically.

### Drop old wget tool and use wget2 instead
The problem with this approach is that wget2 is not pre-installed on most distros, so I plan to maintain
two transitional versions. However, only the wget2 version will get new features.

## GE-Proton
GitHub Page: https://github.com/GloriousEggroll/proton-ge-custom
