#!/bin/bash
# Name: updateproton.sh
# Autor: heuwerk

release=$1

get_new_version() {
	# definition of needed variables
	readonly WEBSITE='https://github.com/GloriousEggroll/proton-ge-custom/tags'

	echo "Checking for new Proton Version..."
	
	# selection Release-Level with parameter
	case "$release" in
        ST|st) release_level='ST'
        ;;
    	*) release_level=''
        ;;
 	esac
		
	# regular expression for extraction of the Proton-Version out of HTML-Code
	regex="*Link--muted.*tag/[[:digit:]]+\.[[:digit:]]+-GE-[[:digit:]]-?($release_level)"

	# downloads the website
    # checks for wget exit codes an terminates the progam, if an error occured
    if ! wget $WEBSITE --quiet ; then
        echo "ERROR: No internet connection!"
        exit 1
    fi
    
	# extracts the newest Proton-Release
	# egrep for regex
	# sort for getting only one item per version 
	# cut to only get the Version-Number out of regex 
	# tail to only get the latest version
	proton_version=$(grep -E "$regex" tags -o | sort --unique --version-sort | cut --delimiter=/ --fields=6 | tail -1)

	# output of newest version
    if [ -z $release_level ] ; then
        echo "Newest Version: $proton_version"
    else
        echo "Newest $release_level-Version: $proton_version"
    fi

	# deletes the file
	rm tags
}

download_proton() {
	if [ "$update" = "true" ] ; then
		download_path="$HOME/Downloads"

		# generates a Path that wget can Download
		file=${WEBSITE%/*}/releases/download/$proton_version/Proton-$proton_version.tar.gz
		
		if [ ! -e "$download_path/Proton-$proton_version.tar.gz" ] ; then
			# Downloads the new Proton-Version
			if ! wget "$file" --quiet --show-progress --directory-prefix="$download_path" ; then
                echo "ERROR: No internet connection!"
                exit 1
            fi
		fi
	else
		echo "Update aborted"
		exit 1
	fi
}

check_prerequirements() {
	proton_path="$HOME/.steam/root/compatibilitytools.d"
	
	# is steam installed?
	if [ ! -d "$HOME/.steam" ] ; then
		echo "ERROR: Steam not installed!"
		exit 1
	fi

	# is the path created?
	if [ ! -d "$proton_path" ] ; then
		echo "Create directory..."
		mkdir -p "$proton_path"
	fi
}

# Extracts the .tar.gz archive to the destination
unpack_proton() {
	proton_archive="Proton-$proton_version.tar.gz"
# 	proton_directory="Proton-$proton_version"
	
	if [ -n "$proton_installed" ] ; then
		read -rp "Delete old Proton-Version? [y/N]: " cleanup
	fi

	case "$cleanup" in
		[YyJj]|[Yy]es|[Jj]a)
			echo "Cleanup..."
			for dir in "$proton_path"/* ; do
				if [[ $(basename "$dir") == *$release_level* ]] ; then
					rm -rf "$dir"
				fi
			done
			;;
		*)
			;;
	esac

	cd "$download_path" || return
	tar --extract --file "$proton_archive" --directory "$proton_path"
}

# checks, if the newest version is already installed. NOT TESTED!!!
check_installed_version() {
		
    # needs more testing!
	if [ -z "$(ls -A "$proton_path")" ] ; then
        echo "Proton not installed."
    else
        for dir in "$proton_path"/* ; do
            if [[ $(basename "$dir") == *$release_level* ]] ; then
                proton_installed=$(basename "$dir")
                proton_installed=${proton_installed#*-}
                break
            fi
        done
    fi
    
	if [ -n "$proton_installed" ] ; then
		echo "Installed Version: $proton_installed"
	fi

	if [[ "$proton_version" == "$proton_installed" ]] ; then
		echo "Newest Version already installed"
		exit 0
	else
		echo "Update available"
		# link to the changelog on GitHub
        echo "You may want to read the changelog first: https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/$proton_version"
	fi

	read -rp "Install new version? [Y/n]: " answer
	case "$answer" in
		[Nn]|[Nn]o|[Nn]ein) update=false
		;;
		[YyJj]|[Yy]es|[Jj]a|*) update=true
		;;
	esac
}

# work in progress
remove_download() {
    rm -f "$download_path/$proton_archive"
}

check_prerequirements
get_new_version
check_installed_version
download_proton
unpack_proton
remove_download

echo 'Done, please restart Steam and follow these instructions:'
echo 'https://github.com/GloriousEggroll/proton-ge-custom#enabling'
