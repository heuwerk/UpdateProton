#!/bin/sh
# Name: updateproton.sh
# Autor: heuwerk

# definition of needed variables
readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/tags'
readonly REGEX="<a h.*tag/.*[0-9]"
readonly PROTON_PATH="$HOME/.steam/root/compatibilitytools.d"
readonly DOWNLOAD_PATH="$HOME/Downloads"

update=""

# checks if all required directories are present
check_prerequirements() {
	# check if .steam dir is present
	[ -d "$HOME/.steam" ] || ( echo "ERROR: Steam not installed!" ; exit 1 )

	# check if compatibilitytools dir is present
	[ -d "$PROTON_PATH" ] || ( echo "Create directory..." ; mkdir -p "$PROTON_PATH" )
}

get_new_version() {
	# downloads the website, terminates the progam, if an error occures
	wget "$WEBSITE" -q || ( echo "ERROR: No internet connection!" && exit 1 )

	# extracts the newest Proton-Release from tags file
	# grep: search for the regular expression in the downloaded file
	# head: take only the first line
	# cut: cut everything before the version number
	proton_version=$(grep -o "$REGEX" tags | head -n1 | cut -d/ -f6)

	# output of newest version
	echo "Newest Version: $proton_version"

	# delete the file
	rm tags
}

download_proton() {
	if [ -n "$update" ] ; then
		# generates a Path that wget can Download
		file="${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.tar.gz"
		
		[ -e "$DOWNLOAD_PATH/Proton-$proton_version.tar.gz" ] || ( wget "$file" -q --show-progress -P "$DOWNLOAD_PATH" || ( echo "ERROR: No internet connection!" ; exit 1 ))
	else
		echo "Update aborted"; exit 1
	fi
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
	proton_archive="Proton-$proton_version.tar.gz"
	
	# [ -n "$proton_installed" ] && echo "Delete old Proton-Version? [y/N]: " ; read -r cleanup

# 	case "$cleanup" in
# 		[YyJj]|[Yy]es|[Jj]a)
# 			echo "Cleanup..."
# 			for dir in "$PROTON_PATH"/* ; do
# 				if [ "$(basename "$dir")" = *"$proton_version"* ] ; then
# 					rm -rf "$dir"
# 				fi
# 			done
# 			;;
# 	esac

	tar -xzf "$DOWNLOAD_PATH/$proton_archive" -C "$PROTON_PATH"
}

# checks, if the newest version is already installed. NOT TESTED!!!
check_installed_version() {
		
    # needs more testing!
	if [ -z "$(find "$PROTON_PATH" | tail -1)" ] ; then
		echo "Proton not installed."
    else
        for dir in "$PROTON_PATH"/* ; do
            if [ "$(basename "$dir")" = "*$proton_version*" ] ; then

                proton_installed=$(basename "$dir")
                proton_installed=${proton_installed#*-}
                break
            fi
        done
    fi
    
	[ -n "$proton_installed" ] && echo "Installed Version: $proton_installed"

	if [ "$proton_version" = "$proton_installed" ] ; then
		echo "Newest Version already installed"
		exit 0
	else
		echo "Proton not installed"
		# link to the changelog on GitHub
        echo "Changelog: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/$proton_version"
	fi

	echo -n "Install new version? [Y/n]: " ; read answer
	case "$answer" in
		[YyJj]|[Yy]es|[Jj]a|"") update="1"
		;;
	esac

}

remove_download() {
    rm -rf "$DOWNLOAD_PATH/$proton_archive"
}

check_prerequirements
get_new_version
check_installed_version
download_proton
unpack_proton
remove_download && echo -e 'Done, please restart Steam and follow these instructions:\nhttps://github.com/GloriousEggroll/proton-ge-custom#enabling'
