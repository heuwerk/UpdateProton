# UpdateProton
A simple shell script that checks for and installs the latest version of *GE-Proton*.

---

**Note:**
Due to the renaming of the upstream project from `Proton-x.xx-GE` to `GE-Proton`, 
the query of the installed versions is not performed correctly.  
It is recommended to delete all Proton-GE versions prior GE-Proton7 for the script to work as expected.

---

## Features
- Check for latest versions of *GE-Proton*
- Interactive usage
- Checksum verification
- Delete all old installed versions, if desired
- Link to release notes
- No GitHub API dependency
- Continue download after interruption
- POSIX shell compliant
- Should run on all major GNU/Linux Distributions  
  (tested with [Fedora Linux](https://fedoraproject.org/) and [Debian GNU/Linux](https://debian.org))
- ~Display download size~ temporarily not available
- Complies with the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) (`$XDG_CACHE_HOME`)

## Usage
1. Download the latest version of the script from the [release page](https://github.com/heuwerk/UpdateProton/releases).  
  You can also download the latest version from the [main branch](https://github.com/heuwerk/UpdateProton/blob/main/updateproton.sh). This version may be under **active development** and may **contain bugs or be non-functional**. **Testers are very welcome!**

1. Place this script in any user directory and run  
``./updateproton.sh`` (with e**x**ecute rights), or  
``sh updateproton.sh`` in your terminal

## Dependencies
The script aims to use only common CLI tools, therefore it should work out of the box on any modern GNU/Linux machine. It is also POSIX shell compliant.
- curl
- find
- grep
- tar
- GNU coreutils
  - `cut`
  - `mkdir`
  - `printf`
  - `rm`
  - `sha512sum`
  - `sort`
  - `tail`
  - `test`
  - `tr`

## Planned Features
*Sorted by priority*

### ~[Support for the Steam Flatpak](https://github.com/heuwerk/UpdateProton/issues/15)~

At this time, Steam is only supported as a distro package (~/.steam must be present).
I would like to support the flatpak version of Steam in the future.

### [Steam restart support](https://github.com/heuwerk/UpdateProton/issues/16)

At the end of the script, the user is alerted to restart Steam.
It should be possible to restart Steam automatically.

### Create non-user version for systemd unit
I plan to create a version of this script that the user does not interact with directly, but which can be used as a systemd unit.
This will be a separate file, since a lot of code that is currently used mainly for user queries is not needed.

## GE-Proton
GitHub Page: https://github.com/GloriousEggroll/proton-ge-custom
