# UpdateProton
A simple shell script that checks for and installs the latest version of *GE-Proton*.

## Features
- Check for latest versions of *GE-Proton*
- Interactive usage
- Checksum verification
- Delete all old installed versions, if desired
- link to release notes
- POSIX shell compliant

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
### Drop old wget tool and use curl instead
The problem with this approach is that curl is not pre-installed on most distros, so I plan to maintain
two transitional versions. However, only the curl version will get new features.

### Print download size
Right now, it is required to look at the GitHub Changelog to see the file size, but I want to integrate that into this tool.

### Remove as many GNU tools, as possible
I would like to keep this program as universal as possible. Therefore, in the long run, as many GNU tools as possible will be removed.

## GE-Proton
GitHub Page: https://github.com/GloriousEggroll/proton-ge-custom
