#!/bin/sh
# Name: updateproton.sh
# Autor: heuwerk

# definition of needed variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/tags'
readonly REGEX="<a h.*tag/.*[0-9]"
readonly PROTON_PATH="$HOME/.steam/root/compatibilitytools.d"
readonly PROTON_DOWNLOAD_PATH="$HOME/Downloads/vagrant_share"

update=""

# checks if all required directories are present
check_prerequirements() {
	# check if .steam dir is present
	[ -d "$HOME/.steam" ] || ( printf "ERROR: Steam not installed!\n" && exit 1 )

	# check if compatibilitytools dir is present
	[ -d "$PROTON_PATH" ] || mkdir -p "$PROTON_PATH"
}

get_new_version() {
	# downloads the website, terminates the progam, if an error occures
	wget "$WEBSITE" -q || ( printf "ERROR: No internet connection!\n" && exit 1 )

	# extracts the newest Proton release from tags file
	# grep: search for the regular expression in the downloaded file
	# head: take only the first line
	# cut: cut everything before the version number
	proton_version=$(grep -o "$REGEX" tags | head -n1 | cut -d/ -f6)

	# output of newest version
	printf "Newest version: %s\n" "$proton_version"

	# delete the file
	rm tags
}

# checks, if the newest version is already installed. NOT TESTED!!!
check_installed_version() {

    # needs more testing!
	if [ "$(find "$PROTON_PATH" -maxdepth 1 | wc -l )" -le 1 ] ; then
		printf "Proton not installed\n"
    else
        for dir in "$PROTON_PATH"/* ; do
			case "$(basename "$dir")" in
				*"$proton_version"*) proton_installed=$(basename "$dir")
					proton_installed=${proton_installed#*-}
					echo hallo2
					break
				;;
			esac
        done
    fi

    echo $proton_installed

	[ "$proton_version" = "$proton_installed" ] && echo "Newest Version already installed" && exit 0

	[ -n "$proton_installed" ] && \
        printf "Installed Version: %s\n" "$proton_installed" || \
        printf "Proton not installed\n"

    printf "Changelog: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/%s\n" "$proton_version"

	printf "Install new version? [Y/n]: " ; read -r answer
	case "$answer" in
		[YyJj]|[Yy]es|[Jj]a|"") update="1"
		;;
	esac
}

# download and verify the new proton version
download_proton() {
    cd "$HOME/Downloads" || exit 1

     # check if download dir is present
	[ -d "$PROTON_DOWNLOAD_PATH" ] || mkdir -p "$PROTON_DOWNLOAD_PATH"

	if [ -n "$update" ] ; then
		# generates a Path that wget can Download
		file="${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.tar.gz"
		checksum="${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.sha512sum"
		
		[ -e "$PROTON_DOWNLOAD_PATH/${file##*/}" ] || \
            ( wget "$file" -q --show-progress -P "$PROTON_DOWNLOAD_PATH" || \
            ( echo "ERROR: No internet connection!" && exit 1 ))

		wget -q "$checksum" && sha512sum --quiet -c "${checksum##*/}" && printf "Verification OK"
	else
		echo "Installation aborted"; exit 1
	fi
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
	proton_archive="${file##*/}"
	
	[ -n "$proton_installed" ] && echo "Delete old entries? [y/N]: " && read -r cleanup

	case "$cleanup" in
		[YyJj]|[Yy]es|[Jj]a)
			printf "Cleanup..."
			for dir in "$PROTON_PATH"/* ; do
                case "$(basename "$dir")" in
                    *"$proton_version"*) rm -rf "$dir"
                    ;;
                esac
			done
			;;
	esac

	tar -xzf "$PROTON_DOWNLOAD_PATH/$proton_archive" -C "$PROTON_PATH"
	rm -rf "$PROTON_DOWNLOAD_PATH"
	rm "${checksum##*/}"
}

check_prerequirements && \
get_new_version && \
check_installed_version && \
download_proton && \
unpack_proton && \
printf '\nDone, please restart Steam and follow these instructions:\nhttps://github.com/GloriousEggroll/proton-ge-custom#enabling\n'
