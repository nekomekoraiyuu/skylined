#!/bin/bash
#### SKYLINED UPDATER SCRIPT ####
# ^ Author (Nekomekoraiyuu) note \\
# Please note that the script is not that very original, and it was revised on existing updater scripts to make it more user friendly?.
# This updater script was based on Willfaust's script.
#### VARIABLES - SECTION ####
# this variable below defines the state of if production keys are present or not
prod_present="false"
# these variables below hold the values of rom title and rom keys
var_title="NULL"
title_keys="NULL"
INPT_TEMP="NULL"
LOOP_CON="true"
###########
##### FUNCTIONS - SECTION ####
# Define a function that generates title and title keys and uhh writes?
def_title_keys () {
  var_title=$(xxd *.tik | grep -oP -m 1 "(?<=2a0: ).{39}" | sed 's/ //g')
  title_keys=$(xxd *.tik | grep -oP -m 1 "(?<=180: ).{39}" | sed 's/ //g')
  # If sed detects maching string then it'll delete the line
  sed -i "/$title=$key/d" $SKYLINED_PATH/temp/title.keys
  echo "$title=$key" >> $SKYLINED_PATH/temp/title.keys
}
############
###### MAIN ######
# Since this script is gonna be run by main script so it'll contain the main scripts uhhhh yeah variables
### Check if prod keys are present
if [ -z "$(ls $SKYLINED_PATH/input/ | grep -oh "prod.keys")" ];
  then 
    echo -e "* Production keys are missing! Have you put it in the correct directory with the name 'prod.keys'?"
  else 
      # recheck if the provided production keys file is empty
      if [ -z $(cat $SKYLINED_PATH/input/prod.keys 2>/dev/null) ]; 
        then 
          echo -e "* Provided Production keys are empty! Please make sure you have put correct production keys."
        else 
        prod_present="true" 
      fi
fi
# It production keys are present then start the script
if [ "$prod_present" = "true" ];
  then
    ### Print out selected base and update rom name
    echo -e "* Selected base rom: $base_selected"
    sleep 0.4
    echo -e "* Selected update rom: $update_selected"
    sleep 0.4
    # Tell the user rom is being updated \\ now the main script starts from here
    echo -e "* Updating your rom please be patient.."
    # Make a temp working directory and move required files
    mkdir -p $SKYLINED_PATH/temp
    cd $SKYLINED_PATH/temp
    # Make temp title keys
    touch title.keys
    # copy hactool and hacpack
    cp $SKYLINED_PATH/binaries/hactool $SKYLINED_PATH/binaries/hacpack $SKYLINED_PATH/temp/
    # Then copy production keys 
    cp $SKYLINED_PATH/input/prod.keys $SKYLINED_PATH/temp
    # Copy base and update roms to temp dir
    cp $SKYLINED_PATH/input/$base_selected $SKYLINED_PATH/input/$update_selected $SKYLINED_PATH/temp 
    ###### Hactool and hacpack cmds here 
    # Make a temporary and build dir
    mkdir temporary temporary_build
    # extract base nsp
    ./hactool -t pfs0 $base_selected --outdir ./temporary
    cd temporary
    def_title_keys
    # Move base nca to temporary_build directory
    for i in *.nca 
      do
        nca_type=$(../hactool $i | grep -oP "(?<=Content Type:\s{23}).*")
        # If nca type is program then move it to temporary_build dir 
        if [ "$nca_type" = "Program" ]; 
          then 
            nca_base=$i
            mv $i ../temporary_build
        fi
      done
    rm -rf ./* && cd ..
    # extract update nsp
    ./hactool -t pfs0 $update_selected --outdir ./temporary
    cd temporary
    def_title_keys
    # Now move nca files to temp dir
    for i in *.nca 
      do
        nca_type=$(../hactool $i | grep -oP "(?<=Content Type:\s{23}).*")
        # If nca type is Control and Program then move it to temporary_build dir 
        if [ "$nca_type" = "Program" ]; 
          then 
            nca_update=$i
            mv $i ../temporary_build
        elif [ "$nca_type" = "Control" ];
          then 
            nca_control=$i
            mv $i ../temporary_build
        fi
      done
    rm -rf ./* && cd ..
    # Move hacpack and hacktool to temp build dir
    mv ./hacpack ./hactool ./temporary_build/
    cd ./temporary_build
    # Now get title id from base program nca 
    rom_titleid=$(./hactool "$nca_base" | grep -oP "(?<=Title ID:\s{27}).*") 
    # Now make romfs and exefs directory and extract base NCA and update NCA to it
    mkdir romfs exefs 
    ./hactool --basenca="$nca_base" $nca_update --romfsdir="romfs" --exefsdir="exefs"
    # Remove Update nca and base
    rm $nca_update $nca_base
    # Now pack romfs and exefs into one nca  \\ 
    mkdir nca
    ./hacpack --type="nca" --ncatype="program" --plaintext --exefsdir="exefs" --romfsdir="romfs" --titleid="$rom_titleid" --outdir="nca"
    mv $nca_control nca 
    patchednca=$(ls nca)
    # funny rm -rf cmd 
    rm -rf exefs romfs 
    # generate meta NCA from patched NCA and control NCA 
    ./hacpack --type="nca" --ncatype="meta" --titletype="application" --programnca="nca/$patchednca" --controlnca="nca/$nca_control" --titleid="$rom_titleid" --outdir="nca" 
    # Now repack all NCAs into one nsp 
    mkdir nsp 
    ./hacpack --type="nsp" --ncadir="nca" --titleid="$rom_titleid" --outdir="nsp"
    
    # now move updated rom to output dir \\ also check if the user preferred to save as base game name or title id to output dir 
   if [ "$pref_romname" = "titleid" ];
    then
      mv ./nsp/$rom_titleid.nsp $SKYLINED_PATH/output/$rom_titleid[Updated].nsp
    elif [ "$pref_romname" = "basename" ];
      then
        mv ./nsp/$rom_titleid.nsp $SKYLINED_PATH/output/$base_selected[Updated].nsp
   fi 
   rm -rf $SKYLINED_PATH/temp
    ##### End
fi
# Make a press Enter to continue
echo -e ">Press [ ENTER ] To Continue;\nPress [ N ] to exit."
while [ "$LOOP_CON" = "true" ];
  do 
    read -rsn 1 INPT_TEMP
    if [ "$INPT_TEMP" = "" ];
      then
        # Reset selected base and update name
        base_selected="NULL"
        update_selected="NULL"
      elif [[ "$INPT_TEMP" = [nN] ]];
        then 
          clear
          echo -e "* Exited skylined."
          exit 0
    fi
  done
