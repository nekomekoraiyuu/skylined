#!/bin/bash
# (C) Markus tech & ez corps // Nekomekoraiyuu (Ignore this LINE LMAOAOA)
# Rewrite / revision 1 : I had accidentialy deleted my previous script
# Init
##### VARIABLES SECTION #######
CONFIG_DIR=~/.config/skylined
SKYLINED_PATH=~/skylined
TEMP_PATH=~/skylined_installer_temp
EXIT_STATUS="NULL"
ERR_STANDARD="* Failed; Perhaps try checking your\ninternet connection and try again?"
LOOPING="true"
###### canary check #####
if [ "$1" = "--canary" ];
  then
      canary_build="true"
  else 
      canary_build="false"
fi
#############
####### FUNCTIONS SECTION ####
# Make a function to check and install packages
stuff_inst () {
	# Make a variable that stores value from arg
	specified_pkg=$1
	# Check if the pkg is installed
	if [[ -z "$(apt list --installed 2> /dev/null | grep -oh "^$specified_pkg/" | cut -d "/" -f 1)" ]];
		then 
		  echo -e "$specified_pkg is not installed [ x ]; Installing"
			# If not installed  Check if that package is in the repository
			if [ "$(apt search $specified_pkg 2> /dev/null | grep -oh "^$specified_pkg/" | cut -d "/" -f 1)" = "$specified_pkg" ];
				then
					sleep 0.2
					apt install $specified_pkg -y 2> /dev/null
				else
				# If the package is not available in the repository then prompt the user to change
					echo -e "The package $specified_pkg is not available in your current repository.. Do you want to switch?\b[Enter] to switch, [no] to cancel switching; exit"
					read -re ASK_CHOICE
					if [[ -z "$ASK_CHOICE" ]];
						then
							termux-switch-repo
							apt update 2> /dev/null
							apt install $specified_pkg -y 2> /dev/null
						else
						echo -e "* Canceled switching repositories; The Package $specific_pkg is not available in current repository; Aborting installation"
						exit 1
					fi
			fi
			
	fi
	# Double check if it was installed
if [[ -z "$(apt list --installed 2> /dev/null | grep -oh "^$specified_pkg/" | cut -d "/" -f 1)" ]];
	then
 		echo -e "$specified_pkg was not installed [ x ]; aborting"
 		exit 1
 	else
 		echo -e "$specified_pkg has been installed [ √ ]"
fi
}
# Make a function that does clean up on exit
clean_exit () {
  if [ "$EXIT_STATUS" != "OK" ];
    then
       rm -rf $TEMP_PATH 2>/dev/null 
       # check if skylined was finished installing before
       if [ "$(cat $CONFIG_DIR/skylined_script.conf 2>/dev/null | grep -h "has_skylined_installer_finished_install=" | cut -d "=" -f 2)" != "true" ];
        then
         rm -rf $SKYLINED_PATH 2>/dev/null 
       fi
     else
     rm -rf $TEMP_PATH 2>/dev/null
  fi
}
################
###### [ Main ] #######
# execute cleanup on exit
trap clean_exit EXIT
# Show header (skylined indeed)
clear
echo -e "\e[1mSkylined installer $(if [ "$canary_build" = "true" ]; then echo -e "\e[33mCANARY\e[39m"; fi) - nekomekoraiyuu &\n markus tech\n____________________\e[22m"
sleep 1
## Check if skylined was finished installing before
if [ "$(cat $CONFIG_DIR/skylined_script.conf 2>/dev/null | grep -h "has_skylined_installer_finished_install" | cut -d "=" -f 2)" = "true" ];
	then
		echo -e "* Looks like you had installed skylined before do you want to force reinstall it? (Which will remove existing skylined files and start from scratch.) Press [Y] to proceed $(echo '\\') Press [N] To Cancel."
		while [ "$LOOPING" = "true" ];
		do
		read -rsn 1 ASK_INPT
		if [[ "$ASK_INPT" = [yY] ]];
			then
				# If Yes then remove skylined, config directory
				rm -rf $SKYLINED_PATH 2>/dev/null
				rm -rf $CONFIG_DIR 2>/dev/null
				rm -rf "$PATH/skylined" 2>/dev/null
				"* Successfully removed existing files, proceeding with the script!"
				break
		elif [[ "$ASK_INPT" = [nN] ]];
			then
				echo -e "* Cancelled." && exit 0
		fi
		done
fi
#####
####### Make a config directory if it simply doesnt exist
## If there is no config dir then make one
if [ -z $(ls ~/.config 2>/dev/null | grep -oh "skylined" ) ];
	then
		mkdir -p $CONFIG_DIR
fi
echo -e "---- SKYLINED-CONFIG ----\nhas_skylined_script_run_once=true\nhas_skylined_installer_finished_install=false\nhas_run_skylined_script_once=false\ncanary=false\nnameby_rom=titleid\nshow_console_logging=false" > $CONFIG_DIR/skylined_script.conf
echo -e "* Created config directory."
if [ "$1" = "--canary" ];
	then
		sed -i 's/canary=false/canary=true/' $CONFIG_DIR/skylined_script.conf
fi
##### 
# Now do main stuff 
echo -e "* Updating available lists and installed packages [...]"
sleep 0.7
# Update termux packages since lets assume user has installed for the first time
apt update &> /dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
apt upgrade -y &> /dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
# Then Start installing some required binaries
echo -e "* Installing required binaries; please wait [...]"
sleep 1
stuff_inst git
stuff_inst vim
stuff_inst micro
stuff_inst clang
stuff_inst make
stuff_inst cmake
stuff_inst binutils
stuff_inst ncurses-utils
stuff_inst tar
echo -e "* Done!"
sleep 0.3
echo -e "* Downloading skylined script.. $(if [ "$canary_build" = "true" ]; then echo -e "\e[33mCANARY-BRANCH\e[39m"; fi) [Please be patient]"
sleep 0.6
# clone skylined script from github
if [ "$canary_build" = "true" ];
  then
    git -C ~ clone -b canary https://github.com/nekomekoraiyuu/skylined --depth 1 &>/dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
  else
    git -C ~ clone -b main https://github.com/nekomekoraiyuu/skylined --depth 1 &>/dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
fi
###
echo -e "* Done!" && sleep 0.4
### todo
echo -e "* Now setting up skylined..."
# Setup a temporary directory
mkdir -p $TEMP_PATH
cd $TEMP_PATH
# clone hacpack and hactool 
echo -e "* Cloning hactool and hacpack..."
git clone https://github.com/SciresM/hactool ./hactool_source &>/dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
git clone https://github.com/The-4n/hacPack ./hacpack_source &>/dev/null || { echo -e "$ERR_STANDARD"; exit 1; }
echo -e "* Done!" && sleep 0.4
# Setup hactool
echo -e "* Setting up hactool.."
sleep 0.4
cd ./hactool_source
git checkout c2c907430e674614223959f0377f5e71f9e44a4a &>/dev/null
mv config.mk.template config.mk
sed -i "372d" main.c
# start building
make || { echo -e "* Failed to build hactool! Please try again?"; exit 1; }
chmod +x hactool
mv hactool $SKYLINED_PATH/binaries/
echo -e "* Successfully set up hactool!"
cd ..
sleep 0.3
# Now setup hacpack
echo -e "* Setting up hacpack.."
cd ./hacpack_source
git checkout 7845e7be8d03a263c33430f9e8c2512f7c280c88 &>/dev/null
mv config.mk.template config.mk
# Start building hacpack
make || { echo -e "* Failed to build hacpack! Please try again?"; exit 1; }
chmod +x hacpack
mv hacpack $SKYLINED_PATH/binaries/
cd ~
# finished setting up now remove temp directory
rm -rf $TEMP_PATH
# setup skylined shortcut
echo -e "#!/bin/bash\nbash ~/skylined/skylined_main.sh" > "$PATH/skylined"
chmod +x "$PATH/skylined"
echo -e "* Everything is done!\nYou can now launch the script by typing\n\e[34mskylined\e[39m in the terminal!"
# Update config file and Exit since the script is finished
sed -i 's/has_skylined_installer_finished_install=false/has_skylined_installer_finished_install=true/' $CONFIG_DIR/skylined_script.conf
exit 0
# Done installing
