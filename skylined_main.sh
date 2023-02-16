#!/bin/bash
### Skylined main script
# (C) Nekomekoraiyuu & markustech + sponsored by ez instruments (IGNORE THIS LINE LMAO again pls-)
####### VARIABLE (X) section #########
# Specify some variables
state_back=0
#### VERSION VAR
VERSION_INFO=$(grep -h "^skylined_vers=" < ~/.config/skylined/skylined_script.conf | cut -d "=" -f 2)
# Configuration directory stuff
CONFIG_DIR=~/.config/skylined
MISC_PATH=~/skylined/misc
SKYLINED_PATH=~/skylined
canary_mode=$(cat $CONFIG_DIR/skylined_script.conf 2>/dev/null | grep -h "canary=" | cut -d "=" -f 2)
# This variable below uhh precalculated whats in the input rom directory // to do: put desc
pre_calculated_romdir="false"
# Variables that store base and update meta
base_selected="NULL"
update_selected="NULL"
#### This variable decides whether to save terminal content and restore it or not
term_contnt_SAR="false"
### Logging config \\ Need to rename this (TO-DO)
log_blw=$(cat $CONFIG_DIR/skylined_script.conf 2>/dev/null | grep -h "show_console_logging=" | cut -d "=" -f 2)
#### this variable below controlls how the updated nsp should be named
pref_romname=$(cat $CONFIG_DIR/skylined_script.conf 2> /dev/null | grep -h "nameby_rom=" | cut -d "=" -f 2)
# This variable below here shows the page like which page are you on
selection_screen="main"
selection_option=1
# The variable below validiates an input
input_valid="true"
# These variable below holds the condition of while (might be useful if you dont wanna start from beginning again)
first_loop="true"
second_loop="false"
third_loop="false"
fourth_loop="false"
### Pages
# Lets make a main menu page
main_menu_page_options=$(echo -e "* Update nsp\n* Instruction manual\n* Settings\n* About")
###
# Specify arrow inputs for reference
# INPUT UP = "^[[A"
# INPT DOWN="^[[B"
# INPUT RIGHT="^[[C"
# INPUT LEFT="^[[D"
# Null is default
INPUT_LAST="NULL"
# this must be empty since enter is empty
# Main menu options
menu_header=$(echo -e "\e[1m-- \e[34mSkylined\e[39m -- $(if [ "$canary_mode" = "true" ]; then echo -e "\e[33mCANARY\e[39m"; fi) \nUse Arrow keys (↑) (↓) to move up and down;\nPress [Enter] to select\e[22m")
# Default selection limit
limit_options=9
###################################
######## FUNCTION (x) section #########
# This function displays logs located in skylined_dir/logs/
logs_show () {
	echo -e "\n\n\n\n\n\n>console<;logs"
	tail -n 10 $SKYLINED_PATH/logs/log_last.txt
}
# Make a function that saves logs to skylined directory // log folder
logs_print () {
	echo -e "$(date +"[ %r ]; ")*" "$1" >> $SKYLINED_PATH/logs/log_last.txt
}
# Make function that'll return the cursor to normal and other stuff on exit
on_interrupt () {
	clear
	tput cnorm
	# export TEMP_SKYLINE_VARIABLE="exit_norm"
	rm -rf $SKYLINED_PATH/temp_stuff 2> /dev/null
  rm -rf $SKYLINED_PATH/script_update_temp
  if [ "$update_status" != "OKAY" ];
    then
      mv ~/skylined/skylined_main.sh.bak ~/skylined/skylined_main.sh 2>/dev/null
      mv ~/skylined/scripts/skylined_nsp_updater.sh.bak  ~/skylined/scripts/skylined_nsp_updater.sh 2>/dev/null
  fi 
  if [ "$term_contnt_SAR" = "true" ];
    then
      tput rmcup
  fi
}
# This function below detects input keys like arrows..?
read_input_key () {
	read -rsn1 input_thing
	# If theres an escape seq then assume arrow key
	if [ "$input_thing" = $'\x1B' ];
		then
			# Now read one word again
			read -rsn1 -t 0.1 input_thing
			if [ "$input_thing" = "[" ];
				then
					read -rsn1 -t 0.1 input_thing
					case $input_thing in
					A) # This input this UP ↑ arrow input
					 if [ "$selection_option" -gt 1 ];
					 	then
					 		selection_option=$(($selection_option-1))
					 	fi
						;;
					B) # This input is DOWN ↓ arrow input
						if [ "$selection_option" -lt "$limit_options" ];
							then
								selection_option=$(($selection_option+1))
						fi					
						;;
					esac
			fi
	# End of arrow check now check for normal keywords
		# Assume it normal key
		else
			case "$input_thing" in
			# Check if its an enter key
			"")
			# If then mark last input as enter
			INPT_LAST="ENTER"
			;;
			# Check for q key
			[qQ])
			# Mark it as back key (q key is back)
			INPT_LAST="qBACK"
			;;
			# Check for r key
			[rR])
			# Mark it as "refresh" key (r key is refresh)
			INPT_LAST="rRefresh"
			;;
			[fF])
			# Mark it as "force" key (f key is force only in settings)
			INPT_LAST="fFKEY"
			;;		
			esac
	fi
}
# This is the main menu function
menu_main () {
# Lets validate the input just in case
input_valid="true"
clear
# Max selections
limit_options=4
echo -e "$menu_header\nPress Q To Exit"
selection_option=$(echo -e "$selection_option")
case "$selection_option" in
    	# Bookmark // erase this
    	1) echo -e "$(echo -e "$main_menu_page_options" | sed "$selection_option s/^/\\\e[32m➔ /" | sed "$selection_option s/$/\\\e[39m/")"
    		if [ "$INPT_LAST" = "ENTER" ];
    			then 
    				# Reset input last to null
    				INPT_LAST="NULL"
    				# Then change select screen to nsp updater since its the one selected
    				selection_screen="nsp_update"
    				# Invalidate input then so the screen currently switches to nsp update 
    				input_valid="false"
    				second_loop="true"
    		fi ;;
    	2) echo -e "$(echo -e "$main_menu_page_options" | sed "$selection_option s/^/\\\e[32m➔ /" | sed "$selection_option s/$/\\\e[39m/")"
    		if [ "$INPT_LAST" = "ENTER" ];
    			then
    			# Reset input last
    			INPT_LAST="NULL"
    			less $MISC_PATH/manual.txt
    		fi
    		;;
    	3) echo -e "$(echo -e "$main_menu_page_options" | sed "$selection_option s/^/\\\e[32m➔ /" | sed "$selection_option s/$/\\\e[39m/")"
    		if [ "$INPT_LAST" = "ENTER" ];
    			then
    			# Reset input last
    			INPT_LAST="NULL"
    			# Change menu into Settings
    			selection_screen="settings"
    			selection_option=1
    			# Invalidate input
    			input_valid="false"
    		fi
    		;;
    	4) echo -e "$(echo -e "$main_menu_page_options" | sed "$selection_option s/^/\\\e[32m➔ /" | sed "$selection_option s/$/\\\e[39m/")"
    		if [ "$INPT_LAST" = "ENTER" ];
    			then
    				INPUT_LAST="NULL"
    				selection_screen="about"
    				selection_option=1
    				input_valid="false"
    				echo -e "a"
    		fi
    		;;
esac		
}
##### versioning 
versioning_calc () {
    ##### Version Checking #####
    # Fetch stuff from the update file
      # Check if canary mode is true
      if [ "$canary_mode" = "true" ];
        then
          versioning=$(cat $SKYLINED_PATH/script_update_temp/main_canary.updat | grep -h "^*Version=" | cut -d "=" -f 2 | cut -d "/" -f 1)
          first_flag=$(cat $SKYLINED_PATH/script_update_temp/main_canary.updat | grep -h "^*Version=" | cut -d "=" -f 2 | cut -d "/" -f 2)
          line_first=$(cat $SKYLINED_PATH/script_update_temp/main_canary.updat 2>/dev/null | grep -on "<-----EXECUTE----->" | cut -d ":" -f 1 | head -n 1)
          line_last=$(cat $SKYLINED_PATH/script_update_temp/main_canary.updat 2>/dev/null | grep -on "<-----EXECUTE----->" | cut -d ":" -f 1 | tail -n 1)
        else
          versioning=$(cat $SKYLINED_PATH/script_update_temp/main_normal.updat | grep -h "^*Version=" | cut -d "=" -f 2 | cut -d "/" -f 1)
          first_flag=$(cat $SKYLINED_PATH/script_update_temp/main_normal.updat | grep -h "^*Version=" | cut -d "=" -f 2 | cut -d "/" -f 2)
          line_first=$(cat $SKYLINED_PATH/script_update_temp/main_normal.updat 2>/dev/null | grep -on "<-----EXECUTE----->" | cut -d ":" -f 1 | head -n 1)
          line_last=$(cat $SKYLINED_PATH/script_update_temp/main_normal.updat 2>/dev/null | grep -on "<-----EXECUTE----->" | cut -d ":" -f 1 | tail -n 1)
      fi
    ### now calculate versioning mode
    ### Check if the last key was Force key \\ if then force redownload
    if [ "$forced_dwnload" = "true" ];
      then 
        echo -e "* Are you sure you want to redownload current version?\n(Useful if maintainer repushes an update on the current version)\n[Press Y to proceed / N to cancel.]"
        read -rsn1 ASK_ANS
        case $ASK_ANS in
        [yY])
          echo -e "* Downloading please wait.."
          forced_dwnload="false"
          unset ASK_ANS
          versioning_type=4
          return
          ;;
        [nN])
          echo -e "* Canceled."
          forced_dwnload="false"
          unset ASK_ANS
          return
          ;;
        *)
          echo -e "* Invalid input; assuming its no?"
          forced_dwnload="false"
          unset ASK_ANS
          return
          ;;
        esac
    fi
    #####
    if [[ "$versioning" -gt "$VERSION_INFO" && "$first_flag" = "o" ]];
      then 
        ### Optional flag 
        echo -e "* An optional update is available. Do you want to updare?\npress [Y/N]"
        read -rsn1 ASK_ANS
        case $ASK_ANS in
        [yY])
        echo -e "* Updating please wait.."
        versioning_type=1
        ;;
        [nN])
        echo -e "* Cancelled updating; returning to settings.."
        sleep 0.4
        ;;
        *)
        echo -e "* Invalid input; assuming its no? Returning to settings.."
        sleep 0.4
        ;;
        esac
    elif [[ "$versioning" -gt "$VERSION_INFO" && "$first_flag" = "n" ]];
      then 
        ### Normal flag 
        echo -e "* An update is available. Do you want to update?\npress [Y/N]"
        read -rsn1 ASK_ANS
        case $ASK_ANS in
        [yY])
        echo -e "* Updating please wait.."
        versioning_type=2
        ;;
        [nN])
        echo -e "* Cancelled updating; returning to settings.."
        sleep 0.4
        ;;
        *)
        echo -e "* Invalid input; assuming its no? Returning to settings.."
        sleep 0.4
        ;;
        esac
    elif [[ "$versioning" -gt "$VERSION_INFO" && "$first_flag" = "f" ]];
      then 
        #### force flag - Basically updates without any prompts
        echo -e "* Update available!; updating your script...\n[Forced]"
        versioning_type=3
      #### if there are no updates available
      else
        echo -e "* You're up to date!;press [ Any key ]\nto return to settings."
        read -rsn1 ASK_CHOICE
        unset ASK_CHOICE
    fi
  }
# Make a function that shows nsp updater menu
menu_nsp () {
	clear
	# Revalidate input just in case invalidated
	input_valid="true"
	echo -e "$menu_header press q to go back; press r to refresh list\nPlease select base game to update:"
	# Check if 
	if [[ -z $(ls $SKYLINED_PATH/input/ 2>/dev/null | grep .nsp) ]];
	  	then
	  		echo -e "* There are no nsp files in input directory;Please put your nsp roms in the input directory."
	  		pre_calculated_romdir=true
	fi	
	# Make pre-calculations for rom once names to prevent 1 sec delay // users might need to manually refresh so iam adding r key
	if [ "$pre_calculated_romdir" = "false" ];
		then
			# A variable that stores how many options are there
			limit_options="$(ls $SKYLINED_PATH/input/ | grep -c .nsp)"
			# A variable that stores the value of how many files were there
			list_test="$(ls $SKYLINED_PATH/input/ | grep .nsp)"
			list_origin="$(ls $SKYLINED_PATH/input/ | grep .nsp)"
			for i_stuff in $(seq $limit_options)
			  do
			  calc_rom_size="$(ls -hl "$HOME/skylined/input/$(echo -e "$list_test" | sed -n "$i_stuff p")" | cut -d " " -f 5)"
			  list_test=$(echo -e "$list_test" | sed "$i_stuff s/$/ \\\ Size: $calc_rom_size/")
			  done
			# Make temp directory to store temporary commands
			mkdir -p $SKYLINED_PATH/temp_stuff
			echo -e "#!/bin/bash\ncase $(echo -e '"$selection_option"') in\n# Insert here\nesac" > $SKYLINED_PATH/temp_stuff/temp_command.sh
			chmod +x $SKYLINED_PATH/temp_stuff/temp_command.sh
			# Make a for statement that makes a case statement so we can execute the case statement in the temp file later
			for i_stuff in $(seq $limit_options)
				do
				# Find the line number of the "Insert here" comment and store it
				num_order=$(cat $SKYLINED_PATH/temp_stuff/temp_command.sh | grep -n "# Insert here" | cut -d ":" -f 1 | tail -n 1)
				# Then append statement after that line // this command below is insane           add quotation mark#          #make the variable execute																								End mark of sed
				#                                                                                                                                        		cat $SKYLINED_PATH/temp_stuff/temp_command.sh | sed -e "$num_order a $i_stuff) echo -e $(echo -e '"''$(echo -e ''"$list_test" | sed -e "$selection_option s/^/\\\e[32m➔" -e "$selection_option s/$/\\\e[39m")"')\n$(echo -e 'if [ "$INPT_LAST" = "ENTER" ];')\nthen\n$(echo -e 'input_valid="false"')\n$(echo -e 'base_selected=$(echo -e $list_test | sed "$selection_option p")')\n;;\n# Insert here" | echo -e $(cat) > $SKYLINED_PATH/temp_stuff/temp_command.s
				sed -i -e "$num_order a $i_stuff) echo -e $(echo -e '"''$(echo -e ''"$list_test" | sed -e "$selection_option s/^/\\\e[32m➔/" -e "$selection_option s/$/\\\e[39m/")"')\n$(echo -e 'if [ "$INPT_LAST" = "ENTER" ];')\nthen\n$(echo -e 'input_valid="false"')\n$(echo -e 'base_selected=$(echo -e "$list_origin" | sed -n "$selection_option p")')\n$(echo -e 'base_selected_size=$(ls -hl "$HOME/skylined/input/$base_selected" | cut -d " " -f 5 | sed "s/[A-Za-z]//g")')\n$(echo -e 'selection_option=1')\nfi\n;;\n# Insert here" $SKYLINED_PATH/temp_stuff/temp_command.sh
				done
			# At last set precalculation to true since done calculating
			pre_calculated_romdir="true"
# End if statement
	fi
	# Then execute the temporary command stored in a file
	source $SKYLINED_PATH/temp_stuff/temp_command.sh 2>/dev/null
	if [ "$base_selected" != "NULL" ];
		then
			# Set selection screen to update rom picking
			selection_screen="nsp_update_pick"
			third_loop="true"
			INPT_LAST="NULL"
			pre_calculated_romdir="false"
	fi
}
# Make a function that lets you pick update roms
menu_nsp_update_pick () {
	clear
	# Revalidate input
	input_valid="true"
	echo -e "$menu_header \npress q to go back; press r to refresh\nPlease select update nsp rom:"
	if [ -z "$(ls $SKYLINED_PATH/input | grep .nsp | grep -v "$base_selected")" ];
	  then
      echo -e "* There are no available roms to update; Please put your update roms in the input directory."
      pre_calculated_romdir="true"
  fi
	# Precalculate rom dir again like the previous section
		if [ "$pre_calculated_romdir" = "false" ];
		then
			# A variable that stores how many options are there
			limit_options=$(ls $SKYLINED_PATH/input/ | grep -v "$base_selected" | grep -c .nsp)
			# A variable that stores the value of how many files were there
			list_test="$(ls $SKYLINED_PATH/input/ | grep -v "$base_selected" | grep .nsp)"
			list_origin="$(ls $SKYLINED_PATH/input/ | grep -v "$base_selected" | grep .nsp)"
	    for i_stuff in $(seq $limit_options)
			  do
			  calc_rom_size="$(ls -hl "$HOME/skylined/input/$(echo -e "$list_test" | sed -n "$i_stuff p")" | cut -d " " -f 5)"
			  list_test=$(echo -e "$list_test" | sed "$i_stuff s/$/ \\\ Size: $calc_rom_size/")
			  done
			# Make temp directory to store temporary commands
			mkdir -p $SKYLINED_PATH/temp_stuff
			echo -e "#!/bin/bash\ncase $(echo -e '$selection_option') in\n# Insert here\nesac" > $SKYLINED_PATH/temp_stuff/temp_command.sh
			chmod +x $SKYLINED_PATH/temp_stuff/temp_command.sh
			# Make a for statement that makes a case statement so we can execute the case statement in the temp file later
			for i_stuff in $(seq "$limit_options")
				do
				# Find the line number of the "Insert here" comment and store it
				num_order=$(cat $SKYLINED_PATH/temp_stuff/temp_command.sh | grep -n "# Insert here" | cut -d ":" -f 1 | tail -n 1)
				# Then append statement after that line // this command below is insane           add quotation mark#          #make the variable execute																								End mark of sed
				sed -i -e "$num_order a $i_stuff) echo -e $(echo -e '"''$(echo -e ''"$list_test" | sed -e "$selection_option s/^/\\\e[32m➔/" -e "$selection_option s/$/\\\e[39m/")"')\n$(echo -e 'if [ "$INPT_LAST" = "ENTER" ];')\nthen\n$(echo -e 'input_valid="false"')\n$(echo -e 'update_selected=$(echo -e "$list_origin" | sed -n "$selection_option p")')\n$(echo -e 'update_selected_size=$(ls -hl "$HOME/skylined/input/$update_selected" | cut -d " " -f 5 | sed "s/[A-Za-z]//g")')\nfi\n;;\n# Insert here" $SKYLINED_PATH/temp_stuff/temp_command.sh
				done
			# At last set precalculation to true since done calculating
			pre_calculated_romdir="true"
# End if statement
	fi
  # now execute commands again from the temporary stored file
  source $SKYLINED_PATH/temp_stuff/temp_command.sh
  if [ "$update_selected" != "NULL" ];
    then 
      selection_screen="nsp_update_sum"
      INPT_LAST="NULL"
      fourth_loop="true"
      pre_calculated_romdir="false"
  fi
}
# Make a function that shows you the selected roms and updates // 
menu_nsp_sum () {
  clear
  # Revalidate input because why not :stretchreaction: ( if you get this skyline emulador ref )
  limit_options=2
  input_valid="true"
  # Show header
  echo -e "$menu_header\n"
  echo -e "Selected base rom: $base_selected;\n\nSelected Update rom: $update_selected\n\nIs this correct?\n"
  case $selection_option in
  1) echo -e "\e[32m➔ * Yes, proceed to updating.\e[39m\n* No, go back."
	if [ "$INPT_LAST" = "ENTER" ];
		then
			INPT_LAST="NULL"
			selection_option=1
			source $SKYLINED_PATH/scripts/skylined_nsp_updater.sh
			second_loop="false"
			third_loop="false"
			fourth_loop="false"
			selection_screen="main"
	fi
  ;;
  2) echo -e "\e[39m* Yes, proceed to updating.\n\e[32m➔ * No, go back.\e[39m"
    if [ "$INPT_LAST" = "ENTER" ];
      then
        # A
        input_valid="false"
        selection_option=1
        third_loop="false"
        fourth_loop="false"
        INPT_LAST="NULL"
        base_selected="NULL"
        update_selected="NULL"
        selection_screen="nsp_update"
    fi
  ;;
  esac
}
# Settings function
menu_settings () {
  clear
  limit_options=3
  # Revalidate input
  input_valid="true"
  echo -e "$menu_header\n\n< Settings > (W.I.P) Version: $VERSION_INFO"
  case $selection_option in
  1) 
  echo -e "\e[32m➔ $(if [ "$log_blw" = "true" ]; then echo -e "* Show Console Log Below : [√]"; else echo -e "Show Console Log Below : [×]"; fi)\e[39m"
  echo -e "$(if [ "$pref_romname" = "titleid" ]; then echo -e "* Name Updated Nsp File By : TitleID"; else echo -e "* Name Updated Nsp File By : Base_Name"; fi)"
  echo -e "* Check for updates"
  if [ "$INPT_LAST" = "ENTER" ];
  	then
  		# If console logging is true then set false if not do the opposite
  		if [ "$log_blw" = "true" ];
  			then
  				log_blw="false"
  				sed -i "s/show_console_logging=true/show_console_logging=false/" $CONFIG_DIR/skylined_script.conf
  			else
  			log_blw="true"
  			sed -i "s/show_console_logging=false/show_console_logging=true/" $CONFIG_DIR/skylined_script.conf
  		fi
  		# At last set input last to null 
  		INPT_LAST="NULL"
      input_valid="false"
  fi
  ;;
  2)
  echo -e "$(if [ "$log_blw" = "true" ]; then echo -e "* Show Console Log Below : [√]"; else echo -e "Show Console Log Below : [×]"; fi)"
  echo -e "\e[32m➔ $(if [ "$pref_romname" = "titleid" ]; then echo -e "* Name Updated Nsp File By : TitleID"; else echo -e "* Name Updated Nsp File By : Base_Name"; fi)\e[39m"
  echo -e "* Check for updates"
  if [ "$INPT_LAST" = "ENTER" ];
  	then
  		if [ "$pref_romname" = "titleid" ];
  			then
  				pref_romname="base_name"
  				sed -i "s/nameby_rom=titleid/nameby_rom=base/" $CONFIG_DIR/skylined_script.conf
  			else
  				pref_romname="titleid"
  	  			sed -i "s/nameby_rom=base/nameby_rom=titleid/" $CONFIG_DIR/skylined_script.conf
  		fi
  		# set inpt last to null
  		INPT_LAST="NULL"
  		input_valid="false"
  fi
  ;;
  3)
  echo -e "$(if [ "$log_blw" = "true" ]; then echo -e "* Show Console Log Below : [√]"; else echo -e "Show Console Log Below : [×]"; fi)"
  echo -e "$(if [ "$pref_romname" = "titleid" ]; then echo -e "* Name Updated Nsp File By : TitleID"; else echo -e "* Name Updated Nsp File By : Base_Name"; fi)\e[39m"
  echo -e "\e[32m➔ * Check for updates\n[Press F To Force Update]\e[39m" 
  if [ "$INPT_LAST" = "ENTER" ];
    then 
    # change the screen to script updater
      selection_screen="script_update"
      INPT_LAST="NULL"
      input_valid="false"
  elif [ "$INPT_LAST" = "fFKEY" ];
    then 
      selection_screen="script_update"
      INPT_LAST="NULL"
      input_valid="false"
      # Since F key is pressed the script will redownload update
      forced_dwnload="true"
  fi
  ;;
  esac
}
menu_update_script () {
  #### Define a Function that caculates versioning type
  # show header
  echo -e "\e[1m-- \e[34mSkylined\e[39m -- $(echo -e "\e[33mCANARY")\e[22;39m"
  echo -e "* Checking for script updates please wait..."
  rm -rf $SKYLINED_PATH/script_update_temp 2>/dev/null
  mkdir -p $SKYLINED_PATH/script_update_temp
  git clone -b update https://github.com/nekomekoraiyuu/skylined --depth=1 $SKYLINED_PATH/script_update_temp &>/dev/null
  # Invoke versioning var
  versioning_calc
  echo -e "$versioning_type"
  if [[ $versioning_type = 1 ]] || [[ $versioning_type = 2 ]] || [[ $versioning_type = 3 ]] || [[ $versioning_type = 4 ]];
    then
      if [ "$canary_mode" = "true" ];
        then
          # Now save execution commands in a temp file
          cat $SKYLINED_PATH/script_update_temp/main_canary.updat 2>/dev/null | sed -n "$(($line_first+1)),$(($line_last-1))p" > $SKYLINED_PATH/script_update_temp/update_execution.sh 
          chmod +x $SKYLINED_PATH/script_update_temp/update_execution.sh
          source $SKYLINED_PATH/script_update_temp/update_execution.sh
        else 
          cat $SKYLINED_PATH/script_update_temp/main_normal.updat 2>/dev/null | sed -n "$(($line_first+1)),$(($line_last-1))p" > $SKYLINED_PATH/script_update_temp/update_execution.sh 
          chmod +x $SKYLINED_PATH/script_update_temp/update_execution.sh
          source $SKYLINED_PATH/script_update_temp/update_execution.sh
      fi
      unset versioning_type
  fi
}
menu_about () {
	echo -e "* This section is in w.i.p!"
	INPT_LAST="NULL"
	selection_screen="main"
}
########### END FUNCTION #########
######
#####
###### MAIN (x) script section ######
# Print log if initiated
#logs_print "Init"
# Hide the cursor at first
tput civis
# Then make a signal so if there interruption cursor will return to normal
trap on_interrupt EXIT
# Save terminal content and restore it later
if [ "$term_contnt_SAR" = "true" ];
    then
      tput smcup
fi
# Check if the script was run before; if not then show manual instruction page
if [ "$(cat $CONFIG_DIR/skylined_script.conf 2>/dev/null | grep -h "has_run_skylined_script_once=" | cut -d "=" -f 2)" = "false" ];
	then
		sed -i 's/has_run_skylined_script_once=false/has_run_skylined_script_once=true/' $CONFIG_DIR/skylined_script.conf
		less $MISC_PATH/manual.txt
fi
# Lets make a while loop so that the program doesnt exit
while [ $first_loop = "true" ];
	do
	###### Main menu #######
		# If the selection screen is in default // menu then show main menu // home
		if [ "$selection_screen" = "main" ];
			then
				if [ "$INPT_LAST" = "qBACK" ];
					then
					exit 0
				fi
				# Show main menu
				menu_main
				# Use if statement to check keys to avoid the same text printed being twice from main menu function
				if [ "$input_valid" = "true" ];
					then
						read_input_key
				fi
		fi
		###### Settings #####
		# If selection screen in settings then invoke settings function
		if [ "$selection_screen" = "settings" ];
			then
        if [ "$INPT_LAST" = "qBACK" ];
          then 
            INPT_LAST="NULL"
            selection_screen="main"
            input_valid="false"
        else 
				# Show settings
				menu_settings
				# If input valid Ask for input
        if [ "$input_valid" = "true" ];
          then 
            read_input_key
        fi 
      if [ "$selection_screen" = "script_update" ];
        then
          clear
          menu_update_script 
          selection_screen="settings"
          sleep 1 
      fi
		fi
		#### End settings
        # uhhh
        fi
      ##### Aaaa About section maybe
      if [ "$selection_screen" = "about" ];
      	then
      		clear
      		menu_about
      		sleep 1
      fi
      ##### End section
      ###### End first loop thing
		 ### NSP UPDATER SCREEN
			while [ $second_loop = true ];
				do
					# If selection screen variable is in nsp then show nsp updater screen
					if [ "$selection_screen" = "nsp_update" ];
						then
							if [ "$INPT_LAST" = "qBACK" ];
								then
									INPT_LAST="NULL"
									second_loop="false"
									selection_screen="main"
									# Unset precalculated rom dir
									pre_calculated_romdir="false"
									selection_option=1
									break
							fi
              # Check if input refresh 
							if [ "$INPT_LAST" = "rRefresh" ];
								then 
						      INPT_LAST="NULL"
						      pre_calculated_romdir="false"
						      break
							fi
							# Show nsp updater screen//page
							menu_nsp
							# Then check for input
							if [ "$input_valid" = "true" ];
								then
									read_input_key
							fi
					fi
						### Nsp updater screen (Select rom update file)
						while [ "$third_loop" = true ];
							do
							# If statement (nsp_update_pick)
								if [ "$selection_screen" = "nsp_update_pick" ];
									then
										# If statement (Second_nsp_base_pick)
                    					if [ "$INPT_LAST" = "qBACK" ];
                   						   then 
                   						     INPT_LAST="NULL"
                   						     third_loop="false"
                   						     pre_calculated_romdir="false"
                     					  	 base_selected="NULL"
                       						 selection_screen="nsp_update"
                       						 break
                   						 fi
								##### NSP ROM UPDATE PICK MENU //
									menu_nsp_update_pick
									if [ "$input_valid" = "true" ];
										then
											read_input_key
									fi
								### NSP ROM UPDATE SUMMERY MENU // Make a fourth loop here
									while [ "$fourth_loop" = "true" ];
									  do
							       		 if [ "$selection_screen" = "nsp_update_sum" ];
							         		 then
							          			 menu_nsp_sum
							          			 if [ "$input_valid" = "true" ];
							          			 	then
							          			 		read_input_key
							          			 fi
							      		 fi
							      # End Fourth Loop here
							     	 done
							# End of If statement (nsp_update_pick)
								fi
						# End third loop here
							done
			# End Second loop Here
				done
# End first loop here
done
