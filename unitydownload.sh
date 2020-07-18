#!/bin/bash

html=$(curl "https://unity3d.com/get-unity/download/archive" | grep -Po 'unityhub:.+?(?=\")')

resultNum="0"

while [ "$resultNum" == "0" ]
do
	echo "------------"
	echo Enter your desired Unity version \(e.g. 20XX.X.XXfX\):
	read uinput

	if [[ ${uinput,,} = exit ]]; then
		break
	elif [ -z ${uinput} ]; then
		echo "$html"
	fi

	#echo "$html"
	grepcommand="\Q${uinput}\E.+"

	search=$(echo "$html" | grep -Po "$grepcommand")
	
	#echo "$search"

	resultNum=$(echo -n "$search" | grep -c '^')

	echo ""
	if [ "$resultNum" = "0" ]; then
		echo "No results found."
		resultNum="0"
	elif [ "$resultNum" = "1" ]; then
		echo "Version found:"
		echo "$search" | grep -Po ".+?(?=\/)"
		download="-"
		while [ "$download" = "-" ]; do
			echo "Would you like to download it? (y/n)"
			
			read download

			if [[ ${download,,} = y ]] || [[ ${download,,} = yes ]]; then
				echo "Downloading.."

				versionHash=$(echo "$search" | grep -Po "\/.+")

				link="http://beta.unity3d.com/download${versionHash}/UnitySetup"
				
				echo "$link"
				wget "$link"
			elif [[ ${download,,} = n ]] || [[ ${download,,} = no ]]; then
				resultNum="0"
			else
				download="-"
			fi
		done
	else
		echo "$resultNum results found:"
		echo "$search" | grep -Po ".+?(?=\/)"
		resultNum="0"
	fi
done

