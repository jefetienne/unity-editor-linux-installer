#!/bin/bash

html=$(curl "https://unity3d.com/get-unity/download/archive" | grep -Po 'unityhub:.+?(?=\")')

resultNum="0"
TMPNAME=unitytmp

while [ "$resultNum" == "0" ]
do
	echo "------------"
	echo Enter your desired Unity version \(e.g. 20XX.X.XXfX\), or \'exit\' to quit:
	read uinput

	# If user types in exit, exit the application
	if [[ ${uinput,,} = exit ]]; then
		break
	fi

	# Stores the entire version string with the hash internally
	search=$(echo "$html" | grep -Po "\Q${uinput}\E.+")

	# Greps for search keyword inside each result's version name
	displaySearch=$(echo "$html" | grep -P "\Q${uinput}\E.*?(?=\/)")
	# Displays whole version name scoped out from the keyword
	# so searching '17' gives you '2017.X.Y' and not '17.X.Y'
	displaySearch=$(echo "$displaySearch" | grep -Po "(?<=\Q//\E).+?(?=\/)")

	# Get search result count
	resultNum=$(echo -n "$displaySearch" | grep -c '^')

	echo ""
	if [ "$resultNum" = "0" ]; then
		echo "No results found."
		resultNum="0"
	elif [ "$resultNum" = "1" ]; then
		echo "Version found:"
		echo "$displaySearch"
		download="-"
		while [ "$download" = "-" ]; do
			echo "Would you like to download it? (y/n)"
			
			read download

			if [[ ${download,,} = y ]] || [[ ${download,,} = yes ]]; then
				echo "Downloading.."

				# Get *only* the version hash
				versionHash=$(echo "$search" | grep -Po "\/.+")

				link="http://beta.unity3d.com/download${versionHash}/UnitySetup"
				
				echo "$link"

				exitcode=$(wget "$link" -O "$TMPNAME")
				if [ $? -ne 0 ]; then
					echo "An error occurred while attempting to download $displaySearch"
					resultNum="0"
				fi
				chmod +x "$TMPNAME"
				filename="UnitySetup-${displaySearch//./_}"
				mv "$TMPNAME" "${filename}"
				echo "------------"
				echo "Unity Setup installer file '${filename}' downloaded"
			elif [[ ${download,,} = n ]] || [[ ${download,,} = no ]]; then
				resultNum="0"
			else
				download="-"
			fi
		done
	else
		echo "$resultNum results found:"
		echo "$displaySearch"
		resultNum="0"
	fi
done

