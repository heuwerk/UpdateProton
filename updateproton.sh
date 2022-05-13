#!/bin/sh
# name: updateproton.sh
# author: heuwerk

# definition of constant variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/releases/latest'
readonly REGEX='tags/GE-Proton[[:digit:]]\+-[[:digit:]]\+'
readonly PROTON_PATH="${HOME}/.steam/root/compatibilitytools.d"

# checks if all required directories are present
prerequirements() {
	# check if .steam dir is present
	[ ! -d "${HOME}/.steam" ] && printf "ERROR: Steam not installed!\n" && exit 1

	# check if compatibilitytools dir is present
	[ -d "${PROTON_PATH}" ] || mkdir "${PROTON_PATH}"
}

get_new_version() {
	# downloads the website, terminates the program, if an error occurs
	proton_version="$(! wget "${WEBSITE}" -qO- | grep -m1 -o "${REGEX}")" && 
    printf "ERROR: No internet connection!\n" && exit 1

	# extracts the newest Proton release
    proton_version="${proton_version##*/}"

	# output of newest version
	printf "Newest version: %s\n" "${proton_version}"
}

# checks, if the newest version is already installed.
check_installed_version() {
    proton_installed="$(find "${PROTON_PATH}" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1 )"
    proton_installed="${proton_installed##*/}"

	[ "${proton_version}" = "${proton_installed}" ] && printf "Newest version already installed\n" && exit 0

	[ -n "${proton_installed}" ] && \
        printf "Installed version: %s\n" "${proton_installed}" || \
        printf "Proton not installed\n"

    printf "Change log: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/%s\n" "${proton_version}"

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
		# generates a Path that wget can Download
		file="${WEBSITE%/*}/download/${proton_version}/${proton_version}.tar.gz"
		checksum="${WEBSITE%/*}/download/${proton_version}/${proton_version}.sha512sum"
		
        ! wget "${file}" --show-progress -cqP "${HOME}" && \
        printf "ERROR: No internet connection!\n" && exit 1

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
            printf "Cleanup..."
			rm -rf "${PROTON_PATH:?}"/* ;;
        *) ;;
	esac

	# extracts the archive to the destination and deletes everything afterwards
	tar -xzf "${HOME}/${proton_archive}" -C "${PROTON_PATH}"
	rm "${proton_archive}"
}

# script mode, installs the latest version without disturbing the user
script_mode() {
    prerequirements

	proton_version="$(! wget "${WEBSITE}" -qO- | grep -m1 -o "${REGEX}")" && exit 1
    proton_version="${proton_version##*/}"
    proton_installed="$(find "${PROTON_PATH}" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1 )"
    proton_installed="${proton_installed##*/}"
	file="${WEBSITE%/*}/download/${proton_version}/${proton_version}.tar.gz"
	checksum="${WEBSITE%/*}/download/${proton_version}/${proton_version}.sha512sum"

	[ "${proton_version}" = "${proton_installed}" ] && exit 0

    cd "${HOME}" || exit 1
    ! wget "${file}" -cqP "${HOME}" && exit 1
	wget "${checksum}" -qO- | sha512sum --quiet -c

    proton_archive="${file##*/}"
	tar -xzf "${HOME}/${proton_archive}" -C "${PROTON_PATH}"
	rm "${proton_archive}"

    exit 0
}

# display help
usage() {
    printf "Usage: ./updateproton.sh [-s] [-h]\n"
    printf "\t-h\n\t\tDisplay this help\n\n"
    printf "\t-s\n\t\tScript-Mode: Downloads the latest version without deleting old versions; does not output any hints\n"
    printf "\n\tError Codes:\n\t\t0: Execution was successful, or latest version is already installed\n"
    printf "\t\t1: An error occurred\n"
    exit 1
}

while getopts hs flag; do
    case "${flag}" in
        h) usage ;;
        s) script_mode ;;
        *) ;;
    esac
done

prerequirements && \
get_new_version && \
check_installed_version && \
download_proton && \
unpack_proton && \
printf "\nDone! Please restart Steam and follow these instructions:
https://github.com/GloriousEggroll/proton-ge-custom#enabling\n"
