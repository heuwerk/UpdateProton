#!/bin/sh
# updateproton.sh - A simple shell script to update GE-Proton.
# Copyright (C) 2023  Jan Heurich

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Author e-mail address: heuwerk@mailbox.org

# definition of constant variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/releases/latest'
readonly REGEX='GE-Proton[[:digit:]]\+-[[:digit:]]\+'
readonly PROTON_PATH="${HOME}/.steam/root/compatibilitytools.d"

# checks if all required directories are present
check_requirements() {
	# check if .steam dir is present and steam is installed
    [ ! -d "${HOME}/.steam" ] && ! command -v steam && printf "ERROR: Steam not installed!\n" && exit 1

	# check if compatibilitytools dir is present
	[ -d "${PROTON_PATH}" ] || mkdir "${PROTON_PATH}"
}

get_new_version() {
	# downloads the website, terminates the program, if an error occurs
	proton_version="$(! wget "${WEBSITE}" -qO- | grep -om1 "${REGEX}")" &&
        printf "ERROR: Could not fetch latest version!\n" && exit 1

    download_size="$(! wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/expanded_assets/${proton_version}" -qO- | grep -o '[[:digit:]]\+ MB')" &&
        printf "INFO: Could not fetch download size.\n"

	# extracts the newest Proton release
    proton_version="${proton_version##*/}"

	# output of newest version
    printf "Latest version: %s\n" "${proton_version}"
}

# checks, if the newest version is already installed.
check_installed_version() {
    proton_installed="$(find "${PROTON_PATH}" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1 )"
    proton_installed="${proton_installed##*/}"

	[ "${proton_version}" = "${proton_installed}" ] && printf "Latest version already installed\n" && exit 0

	[ -n "${proton_installed}" ] && \
        printf "Installed version: %s\n" "${proton_installed}" || \
        printf "Proton not installed\n"

    printf "\nChangelog: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/%s \n" "${proton_version}"
    printf "Download size: %s\n" "${download_size}"

    printf "\nInstall new version? [Y/n]: " ; read -r answer
	case "${answer}" in
		[YyJj]|[Yy]es|[Jj]a|"") update="1" ;;
    *) exit 0 ;;
	esac
}

# download and verify the new proton version
download_proton() {
    cd "${HOME}" || exit 1

	if [ -n "${update}" ] ; then
		# generates a URI that wget can download
		file="${WEBSITE%/*}/download/${proton_version}/${proton_version}.tar.gz"
		checksum="${WEBSITE%/*}/download/${proton_version}/${proton_version}.sha512sum"
		
        ! wget "${file}" --show-progress -cqP "${HOME}" && \
        printf "ERROR: Download failed!\n" && exit 1

		wget "${checksum}" -qO- | sha512sum --quiet -c  && printf "Verification OK\n"
	else
		printf "Installation aborted\n"; exit 1
	fi
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
    proton_archive="${file##*/}"
	
	[ -n "${proton_installed}" ] && printf "Delete ALL old versions? [y/N]: " && read -r cleanup

	case "${cleanup}" in
		[YyJj]|[Yy]es|[Jj]a)
            printf "Cleanup...\n"
			rm -rf "${PROTON_PATH:?}"/* ;;
        *) ;;
	esac

	# extracts the archive to the destination and deletes everything afterwards
    printf "Extract...\n"
	tar -xzf "${HOME}/${proton_archive}" -C "${PROTON_PATH}"
	rm "${proton_archive}"
}

check_requirements && \
get_new_version && \
check_installed_version && \
download_proton && \
unpack_proton && \
printf "\nDone! Please restart Steam and follow these instructions:
https://github.com/GloriousEggroll/proton-ge-custom#enabling \n"
