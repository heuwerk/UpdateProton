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
# Project repository: https://www.github.com/heuwerk/UpdateProton

# definition of constant variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/releases/latest'
readonly PROTON_NATIVE_PATH="${HOME}/.steam/root/compatibilitytools.d"
readonly PROTON_FLATPAK_PATH="${HOME}/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d"

# checks if all required directories are present
check_requirements() {
    # check if .steam dir is present and steam is installed
    [ -d "${HOME}/.steam" ] &&
        command -v steam >/dev/null &&
        printf "Detected native Steam Installation\n" &&
        proton_path="${PROTON_NATIVE_PATH}"

    # check for flatpak
    command -v flatpak > /dev/null &&
        flatpak info com.valvesoftware.Steam >/dev/null 2>&1 &&
        printf "Detected Steam Flatpak\n" &&
        proton_path="${PROTON_FLATPAK_PATH}"

    # exit if no Installation was found
    [ -z "${proton_path}" ] &&
        printf "ERROR: No Steam Installation found!\n" && exit

    # create compatibilitytools.d directory, if not present
    [ -d "${proton_path}" ] || mkdir "${proton_path}"
}

get_new_version() {
    # downloads the website, terminates the program, if an error occurs
    proton_version="$(curl -Ssw "%{redirect_url}" "${WEBSITE}")" || exit

    # extracts the newest Proton release
    proton_version="${proton_version##*/}"

    # disabled download size because GitHub broke it
    #download_size="$(curl -Lsw "%{size_download}" "${WEBSITE}/download/${proton_version}.tar.gz")"

    # output of newest version
    printf "Latest version: %s\n" "${proton_version}"
}

# checks, if the newest version is already installed.
check_installed_version() {
    proton_installed="$(find "${proton_path}" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1 )"
    proton_installed="${proton_installed##*/}"

    [ "${proton_version}" = "${proton_installed}" ] && printf "Latest version already installed\n" && exit 0

    [ -n "${proton_installed}" ] &&
        printf "Installed version: %s\n" "${proton_installed}" ||
        printf "GE-Proton is not installed\n"

        printf "\nChangelog: %s \n" "${WEBSITE}"
        # printf "Download size: %s\n" "${download_size}"

        printf "\nInstall new version? [Y/n]: "
        read -r answer
    case "${answer}" in
        [YyJj]|[Yy]es|[Jj]a|"") ;;
        *)
        printf "Installation aborted\n"
        exit 1
    esac
}

# download and verify the new proton version
download_proton() {
    # generates a URI that curl can download
    file="${WEBSITE}/download/${proton_version}.tar.gz"
    checksum="${WEBSITE}/download/${proton_version}.sha512sum"

    [ -z "${XDG_CACHE_HOME}" ] && XDG_CACHE_HOME="${HOME}/.cache"
    mkdir -p "${XDG_CACHE_HOME}/updateproton" &&
        cd "${XDG_CACHE_HOME}/updateproton" &&
        curl -#LOC- --http2 "${file}"  || exit

    printf "Verify Checksum...\n"
    curl -LSs "${checksum}" | sha512sum -c
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
    proton_archive="${file##*/}"

    [ -n "${proton_installed}" ] &&
        printf "Delete ALL old versions? [y/N]: " &&
        read -r cleanup

    case "${cleanup}" in
        [YyJj]|[Yy]es|[Jj]a)
        printf "Cleanup...\n"
        rm -rf "${proton_path:?}"/* ;;
        *) ;;
    esac

    # extracts the archive to the destination and deletes everything afterwards
    printf "Extract..."
    tar xzf "${proton_archive}" -C "${proton_path}" &&
        rm "${proton_archive}"
}

check_requirements &&
get_new_version &&
check_installed_version &&
download_proton &&
unpack_proton &&
printf "\n\nDone! Please restart Steam and follow these instructions:
https://github.com/GloriousEggroll/proton-ge-custom#enabling \n"
