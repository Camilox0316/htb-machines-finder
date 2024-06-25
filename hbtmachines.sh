#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl + c
trap ctrl_c INT

# Global variables
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Usage:${endColour}" 
  echo -e "\t${purpleColour}u) ${endColour}${grayColour}Find by a machine's name${endColour}"
  echo -e "\t${purpleColour}m) ${endColour}${grayColour}Find by a machine's name${endColour}"
  echo -e "\t${purpleColour}h) ${endColour}${grayColour}Show help${endColour}\n"
}

function searchMachine (){
  machineName="$1"
  echo "$machineName"
}

function updateFiles(){

  tput civis

  sleep 2
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Downloading necessary files... ${endColour}"
    curl -s -X GET $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} All up to date, you good ;)${endColour}"
  else    

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Looking for updates...${endColour}"
    curl -s -X GET $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value="$(md5sum bundle_temp.js | awk '{print $1}')"
    md5_original_value="$(md5sum bundle.js | awk '{print $1}')"

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No updates availables${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Updating files${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js 
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} All files updated ${endColour}"
    fi
  fi
  tput cnorm
}
# Indicators
declare -i parameter_counter=0

while getopts "m:uh" arg; do 
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
else
  helpPanel
fi


