#!/bin/bash

## Checks if system packages are installed

function pause(){
   read -p "$*"
}

Packages=(python3-pip git libcurl4-openssl-dev libssl-dev libsdl1.2-dev gstreamer-1.0 python3-venv libgstreamer-plugins-base1.0-dev v4l-utils freeglut3-dev libgtk-3-dev libglw1-mesa libglw1-mesa-dev python-dev jq wget ffmpeg)
for i in "${Packages[@]}"
do
	if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ];	then
	apt-get install $i -y -qq;
	else
	echo "-SYSTEM- Already Has $i"
fi
done



c=`cat <<EOF
## Checks if python3 packages are installed
import subprocess
import sys
reqs = subprocess.check_output([sys.executable, '-m', 'pip', 'freeze'])
installed_packages = [r.decode().split('==')[0] for r in reqs.split()]
try:
    from pip import main as pipmain
except ImportError:
    from pip._internal import main as pipmain
PythonPackages = ['virtualenv', 'beautifulsoup4', 'chardet', 'html5lib', 'lxml', 'nose', 'numpy', 'opencv-python', 'six', 'Pillow', 'psutil', 'pyOpenSSL', 'PyYAML', 'requests', 'Send2Trash', 'service-identity', 'Twisted', 'lz4', 'pylzma', 'PySocks', 'matplotlib', 'wxPython']

for i in PythonPackages:
	if i in installed_packages:
		print ('-PYTHON3- Already Has '+ i + ' Installed')
	else:
		print ( 'Error -PYTHON3- ' + i + ' NOT Installed')
		pipmain(['install', i])
EOF`

python3 -c "$c"

for f in ./hydrus*; do
	if [ -e "$f" ]; then
		echo "-NORMAL- ALREADY HAVE HYDRUS CHECKING VERSION"

		##Will check if source.ini is available (Config File)

		if [ ! -f 'source.ini' ]
			then
			echo "Source ini not found, Generating"
			touch source.ini
			WriteList=('[__config__]' 'oldver = old_ver.txt' 'newver = new_ver.txt' '[hydrus]' 'github = hydrusnetwork/hydrus' 'use_max_tag = true')
			for i in "${WriteList[@]}"
			do
				echo $i >> source.ini
			done
			nvchecker source.ini	
		fi

		nvchecker source.ini
		read -r firstline<new_ver.txt	
		read -r oldline<old_ver.txt
		if [ "$firstline" == "$oldline" ] ;then
			echo "Hydrus is up to date, Starting"
			cd ./'hydrus network'
			. venv/bin/activate
			python ./client.py

		else

			echo "HYDRUS NOT UP TO DATE"
			cp new_ver.txt old_ver.txt
			DownloadedFile="$(curl -s https://api.github.com/repos/hydrusnetwork/hydrus/releases/latest | jq -r .tarball_url)"
			wget -O Hydrus.tar ${DownloadedFile}
			tar -xf Hydrus.tar
			rm Hydrus.tar
			sudo cp -r ./hydrusnetwork*/* ./'hydrus network' && sudo rm -R ./hydrusnetwork*/
			##sudo chmod -R 775 ./'hydrus network'
			cd ./hydrus*
			sudo rm -r ./venv
			mkdir venv
			##sudo chmod -R 775 ./venv
			python3 -m venv ./venv
			. venv/bin/activate
			pip3 install beautifulsoup4 chardet html5lib lxml nose numpy opencv-python six Pillow psutil PyOpenSSL PyYAML requests Send2Trash service_identity twisted lz4 pylzma pysocks matplotlib wxPython
			python ./client.py
			deactivate

		fi

		else
#Gonna Pull Latest Version From Github
		if [ ! -f 'source.ini' ]
			then
			echo "Source ini not found, Generating"
			touch source.ini
			WriteList=('[__config__]' 'oldver = old_ver.txt' 'newver = new_ver.txt' '[hydrus]' 'github = hydrusnetwork/hydrus' 'use_max_tag = true')
			for i in "${WriteList[@]}"
			do
				echo $i >> source.ini
			done
			nvchecker source.ini
		fi

		if [ -e "db" ];then
		echo "-SPECIAL- IM INSIDE HYDRUS"
		echo "-SPECIAL- MOVING SELF ONE FOLDER HIGHER SO I CAN RUN PROPERLY"
		mv HYUpdator.sh ../
		sudo rm new_ver.txt
		sudo rm source.ini
		sudo rm old_ver.txt
		else
			read -r firstline<new_ver.txt	
			read -r oldline<old_ver.txt
			if [ "$firstline" != "$oldline" ] ;then
				echo "-SYSTEM- Hydrus is Updating"
				##pause 'Press [Enter] key to continue...'
				cp new_ver.txt old_ver.txt
				DownloadedFile="$(curl -s https://api.github.com/repos/hydrusnetwork/hydrus/releases/latest | jq -r .tarball_url)"
				wget -O Hydrus.tar ${DownloadedFile}
				tar -xf Hydrus.tar
				rm Hydrus.tar
				mkdir 'hydrus network'
				sudo cp -r ./hydrusnetwork*/* ./'hydrus network' && sudo rm -R ./hydrusnetwork*/
				cd ./hydrus*
				sudo rm -r ./venv
				mkdir venv
				##sudo chmod -R 775 ./'hydrus network'
				python3 -m venv ./venv
				. venv/bin/activate
				pip3 install beautifulsoup4 chardet html5lib lxml nose numpy opencv-python six Pillow psutil PyOpenSSL PyYAML requests Send2Trash service_identity twisted lz4 pylzma pysocks matplotlib wxPython
				python ./client.py
				deactivate

			else

			RemoveFiles=('source.ini' 'old_ver.txt' 'new_ver.txt')
			for i in "${RemoveFiles[@]}"
			do
				sudo rm -r $i
			done
			
			clear
			echo "Cleared NON-ESSENTIAL UPDATE CONFIG FILES PLEASE RERUN. (Should redownload hydrus)"
			fi
		fi
	fi
	break
done
