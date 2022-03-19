#!/bin/sh
# name: updateproton.sh
# author: heuwerk

# definition of constant variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/releases/latest'
readonly REGEX='tags/GE-Proton[0-9]*-[0-9]*'
readonly PROTON_PATH="${HOME}/.steam/root/compatibilitytools.d"

# checks if all required directories are present
prerequirements() {
	# check if .steam dir is present
	[ ! -d "${HOME}/.steam" ] && printf "ERROR: Steam not installed!\n" && exit 1

	# check if compatibilitytools dir is present
	[ -d "${PROTON_PATH}" ] || mkdir "${PROTON_PATH}"
}

get_new_version() {
	# downloads the website, terminates the progam, if an error occures
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

    printf "Changelog: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/%s\n" "${proton_version}"

	printf "\nInstall new version? [Y/n]: " ; read -r answer
	case "${answer}" in
		[YyJj]|[Yy]es|[Jj]a|"") update="1"
		;;
    *) exit 0
    ;;
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
			rm -rf "${PROTON_PATH:?}"/*
    ;;
    *) ;;
	esac

	# extracts the archive to the destination and deletes everything afterwards
	tar -xzf "${HOME}/${proton_archive}" -C "${PROTON_PATH}"
	rm "${proton_archive}"
}

prerequirements && \
get_new_version && \
check_installed_version && \
download_proton && \
unpack_proton && \
printf "\nDone! Please restart Steam and follow these instructions:
https://github.com/GloriousEggroll/proton-ge-custom#enabling\n"
