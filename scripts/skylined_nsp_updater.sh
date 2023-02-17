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
base_origin_name="$(echo -e "$base_selected")"
###########
##### FUNCTIONS - SECTION ####
# Define a function that generates title and title keys and uhh writes?
def_title_keys() {
    var_title=$(xxd *.tik | grep -oP -m 1 "(?<=2a0: ).{39}" | sed 's/ //g')
    title_keys=$(xxd *.tik | grep -oP -m 1 "(?<=180: ).{39}" | sed 's/ //g')
    # If sed detects maching string then it'll delete the line
    sed -i "/$var_title=$title_keys/d" ~/.switch/title.keys
    echo "$var_title=$title_keys" >>~/.switch/title.keys
}
# This function adjusts decimal point to 1.
decimal_adjust() {
    if [ -n "$(echo -e "$1" | grep -o "\.")" ]; then
        echo -e "$(echo $1 | cut -d "." -f 1)"'.'"$(echo $1 | cut -d "." -f 2 | cut -c -$2)"
    else
        echo -e "$1"
    fi
}
############
###### MAIN ######
# Since this script is gonna be run by main script so it'll contain the main scripts uhhhh yeah variables
### Check if prod keys are present
clear
if [ -z "$(ls $SKYLINED_PATH/input/ | grep -oh "prod.keys")" ]; then
    echo -e "* Production keys are missing! Have you put it in the correct directory with the name 'prod.keys'?"
else
    # recheck if the provided production keys file is empty
    if [[ -z "$(cat $SKYLINED_PATH/input/prod.keys 2>/dev/null)" ]]; then
        echo -e "* Provided Production keys are empty! Please make sure you have put correct production keys."
    else
        prod_present="true"
    fi
fi
prod_present="true"
# It production keys are present then start the script
if [ "$prod_present" = "true" ]; then
    ### Print out selected base and update rom name
    echo -e "* Selected base rom: $base_selected"
    sleep 0.4
    echo -e "* Selected update rom: $update_selected"
    sleep 0.4
    # Check available space
    echo -e "* Checking for available space.."
    space_avail=$(echo -e "$(df -k ~ | sed -e "s/\ \ */ /g" -ne "2p" | cut -d " " -f 4)*0.0009765625" | bc -l | sed "s/\.*0*$//")
    # Adjust space decimal
    space_avail=$(decimal_adjust "$space_avail" 1)
    total_rom_size_origin=$(echo "$base_selected_size+$update_selected_size" | bc -l)
    total_rom_size_origin=$(decimal_adjust "$total_rom_size_origin" 1)
    total_rom_size=$(echo "$base_selected_size+$update_selected_size" | bc -l | echo -e "$(cat)*4.9" | bc -l)
    total_rom_size=$(decimal_adjust "$total_rom_size" 1)
    # Draft
    if [ $(echo "$total_rom_size>$space_avail" | bc -l) = 1 ]; then
        echo -e "* Insufficient space available! Total rom size (base + update): $total_rom_size_origin \bM\nAvailable space in storage: $space_avail \bM;"
        echo -e "* Please free up your storage and try again. Recommended space: $(echo "$space_avail+$total_rom_size" | bc -l) \bM"
        storage_sufficient="false"
    else
        echo -e "* Sufficient space is available; Total rom size (base + update): $total_rom_size_origin \bM\nAvailable space in storage: $space_avail \bM"
        storage_sufficient="true"
    fi
    if [ "$storage_sufficient" = "true" ]; then
        # Tell the user rom is being updated \\ now the main script starts from here
        echo -e "* Updating your rom please be patient.."
        # Make a temp working directory and move required files
        mkdir -p ~/.switch/
        cd ~/.switch/
        # Make temp title keys
        echo -e "* Generating temporary title keys.."
        touch title.keys
        # copy hactool and hacpack
        echo -e "* Copying hactool and hacpack..."
        cp $SKYLINED_PATH/binaries/hactool $SKYLINED_PATH/binaries/hacpack ~/.switch/
        # Then copy production keys
        echo -e "* Copying production keys.."
        cp $SKYLINED_PATH/input/prod.keys ~/.switch/
        # Copy base and update roms to temp dir
        echo -e "* Copying base and update rom to temporary directory.."
        cp $SKYLINED_PATH/input/"$base_selected" ~/.switch/base_sel.nsp
        base_selected="base_sel.nsp"
        cp $SKYLINED_PATH/input/"$update_selected" ~/.switch/update_sel.nsp
        update_selected="update_sel.nsp"
        ###### Hactool and hacpack cmds here
        # Make a temporary and build dir
        echo -e "* Making temporary directory.."
        mkdir temporary temporary_build
        # extract update nsp
        echo -e "* Extracting Update nsp.."
        ~/.switch/hactool -x -t pfs0 "$update_selected" --outdir="temporary" || {
            echo -e "* Failed to extract update nsp; aborting."
            patching_validated="false"
        }
        if [ "$patching_validated" != "false" ]; then
            cd temporary
            echo -e "* Defining keys from extracted update nsp.."
            def_title_keys
            # Move base nca to temporary_build directory
            echo -e "* Moving update nca's to temporary building directory.."
            for i in *.nca; do
                nca_type=$(~/.switch/hactool $i | grep -oP "(?<=Content Type:\s{23}).*")
                patch_prop=$(~/.switch/hactool $i | grep -o "Patch")
                # If nca type is Control and Program then move it to temporary_build dir
                if [ "$nca_type" = "Program" ] && [ -z "$nca_update" ] && [ -n "$patch_prop" ]; then
                    nca_update=$i
                    mv $i ~/.switch/temporary_build
                elif [ "$nca_type" = "Control" ] && [ -z "$nca_control" ]; then
                    nca_control=$i
                    mv $i ~/.switch/temporary_build
                fi
            done
            echo -e "* Done!"
            rm -rf ./*.tik
            cd ..
            # extract update nsp
            echo -e "* Now extracting base nsp.."
            ~/.switch/hactool -x -t pfs0 "$base_selected" --outdir="temporary" || {
                echo -e "* Failed to extract update nsp. Aborting."
                patching_validated="false"
            }
            if [ "$patching_validated" != "false" ]; then
                cd temporary
                echo -e "* Defining title keys from the base nsp.."
                def_title_keys
                # Now move nca files to temp dir
                echo -e "* Moving base nca's to temporary building directory.."
                # stuff
                # Create a folder so we can compare which base nca is larger
                mkdir check_base
                for i in *.nca; do
                    nca_type=$(~/.switch/hactool $i | grep -oP "(?<=Content Type:\s{23}).*")
                    patch_prop=$(~/.switch/hactool $i | grep -o "Patch")
                    # If nca type is program then move it to temporary_build dir
                    if [ "$nca_type" = "Program" ] && [ -z "$patch_prop" ]; then
                       mv $i ./check_base
                    elif [ "$nca_type" = "Control" ] && [ -z "$nca_control" ]; then
                        nca_control=$i
                        mv $i ~/.switch/temporary_build
                    fi
                done
                # Now check which base nca is bigger
                nca_base=$(ls ./check_base -lS --block-size=K | sed "s/\ \ */ /g" | cut -d " " -f 9 | head -n 2 | tail -n 1)
                mv ./check_base/$nca_base ~/.switch/temporary_build/
                rm -rf ~/.switch/temporary/check_base
                echo -e "* Done"
                rm -rf ~/.switch/temporary
                cd ~/.switch/temporary_build
                # Now get title id from base program nca
                echo -e "* Getting title id from base program nca;\nand making exefs and romfs directory.."
                rom_titleid=$(~/.switch/hactool "$nca_base" | grep -oP "(?<=Title ID:\s{27}).*")
                # Now make romfs and exefs directory and extract base NCA and update NCA to it
                mkdir romfs exefs
                echo -e "* Extracting base nca and update nca.."
                ~/.switch/hactool -x --basenca="$nca_base" $nca_update --romfsdir="romfs" --exefsdir="exefs"
                # Remove Update nca and base
                echo -e "* Cleaning up base and update nca.."
                rm -rf "$nca_update" "$nca_base"
                # Now pack romfs and exefs into one nca  \\
                echo -e "* Packing romfs and exefs.."
                mkdir nca
                ~/.switch/hacpack --type="nca" --ncatype="program" --plaintext --exefsdir="exefs" --romfsdir="romfs" --titleid="$rom_titleid" --outdir="nca"
                echo -e "test $(pwd)"
                patchednca=$(ls nca | sed -n "1p")
                mv ./"$nca_control" ./nca
                rm -rf ./exefs ./romfs
                # funny rm -rf cmd
                rm -rf exefs romfs
                # generate meta NCA from patched NCA and control NCA
                ~/.switch/hacpack --type="nca" --ncatype="meta" --titletype="application" --programnca="nca/$patchednca" --controlnca="nca/$nca_control" --titleid="$rom_titleid" --outdir="nca"
                # Now repack all NCAs into one nsp
                mkdir nsp
                ~/.switch/hacpack --type="nsp" --ncadir="nca" --titleid="$rom_titleid" --outdir="nsp"
                # now move updated rom to output dir \\ also check if the user preferred to save as base game name or title id to output dir
                if [ "$pref_romname" = "titleid" ]; then
                    mv ./nsp/"$rom_titleid.nsp" $SKYLINED_PATH/output/"$rom_titleid[Updated].nsp"
                elif [ "$pref_romname" = "basename" ]; then
                    mv ./nsp/"$rom_titleid.nsp" $SKYLINED_PATH/output/"$base_origin_name[Updated].nsp"
                else
                    mv ./nsp/"$rom_titleid.nsp" $SKYLINED_PATH/output/"$rom_titleid.nsp"
                fi
                rm -rf ~/.switch/
            fi
            ##### End
        fi
    # End of Sufficient storage check if statement
    fi
# End of prod key check if statement
fi
# Make a press Enter to continue
echo -e ">Press [ ENTER ] To Continue;\nPress [ N ] to exit."
while [ "$LOOP_CON" = "true" ]; do
    read -rsn 1 INPT_TEMP
    if [ "$INPT_TEMP" = "" ]; then
        # Reset selected base and update name
        base_selected="NULL"
        unset base_selected_size
        update_selected="NULL"
        unset update_selected_size
        echo -e "* Returning to menu.."
        input_valid="false"
        break
    elif [[ "$INPT_TEMP" = [nN] ]]; then
        clear
        echo -e "* Exited skylined."
        exit 0
    fi
done
