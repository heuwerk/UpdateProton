#!/bin/sh
# Name: updateproton.sh
# Autor: heuwerk

# definition of constant variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/tags'
readonly REGEX='<a c.*tag/.*[0-9]..$'
readonly PROTON_PATH="$HOME/.steam/root/compatibilitytools.d"

# checks if all required directories are present
check_prerequirements() {
	# check if .steam dir is present
	[ ! -d "$HOME/.steam" ] && printf "ERROR: Steam not installed!\n" && exit 1

	# check if compatibilitytools dir is present
	[ -d "$PROTON_PATH" ] || mkdir "$PROTON_PATH"
}

get_new_version() {
	# downloads the website, terminates the progam, if an error occures
	! wget "$WEBSITE" -q && printf "ERROR: No internet connection!\n" && exit 1

	# extracts the newest Proton release from tags file
	# grep: search for the regular expression in the downloaded file
	# head: take only the first line
	# cut: cut everything before the version number
	proton_version="$(grep -o "$REGEX" tags | head -n1 | cut -d/ -f6)"
	proton_version="${proton_version%\"*}"

	# output of newest version
	printf "Newest version: %s\n" "$proton_version"

	# delete the file
	rm tags
}

# checks, if the newest version is already installed. NOT TESTED!!!
check_installed_version() {
    proton_installed="$(find "$PROTON_PATH" -mindepth 1 -maxdepth 1 | sort -V | tail -1 | cut -d/ -f7)"
    proton_installed="${proton_installed#*-}"

	[ "$proton_version" = "$proton_installed" ] && printf "Newest version already installed\n" && exit 0

	[ -n "$proton_installed" ] && \
        printf "Installed version: %s\n" "$proton_installed" || \
        printf "Proton not installed\n"

    printf "Changelog: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/%s\n" "$proton_version"

	printf "\nInstall new version? [Y/n]: " ; read -r answer
	case "$answer" in
		[YyJj]|[Yy]es|[Jj]a|"") update="1"
		;;
	esac
}

# download and verify the new proton version
download_proton() {
    cd "$HOME" || exit 1

	if [ -n "$update" ] ; then
		# generates a Path that wget can Download
		file="${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.tar.gz"
		checksum="${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.sha512sum"
		
    ! wget "$file" --show-progress -cqP "$HOME" && \
      printf "ERROR: No internet connection!\n" && exit 1

		wget -q "$checksum" && sha512sum --quiet -c "${checksum##*/}" && printf "Verification OK\n"
	else
		printf "Installation aborted\n"; exit 1
	fi
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
	proton_archive="${file##*/}"
	
	[ -n "$proton_installed" ] && printf "Delete ALL old versions? [y/N]: " && read -r cleanup

	case "$cleanup" in
		[YyJj]|[Yy]es|[Jj]a)
            printf "Cleanup..."
			rm -rf "${PROTON_PATH:?}"/*
	esac

	# extracts the archive to the destination and deletes everything afterwards
	tar -xzf "$HOME/$proton_archive" -C "$PROTON_PATH"
	rm "${checksum##*/}"
}

check_prerequirements && \
get_new_version && \
check_installed_version && \
download_proton && \
unpack_proton && \
printf "\nDone! Please restart Steam and follow these instructions:
https://github.com/GloriousEggroll/proton-ge-custom#enabling\n"
