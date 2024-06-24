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
  exit 1
}

# Ctrl + c
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Usage:${endColour}" 
  echo -e "\t${purpleColour}m) ${endColour}${grayColour}Find by a machine's name${endColour}"
  echo -e "\t${purpleColour}h) ${endColour}${grayColour}Show help${endColour}\n"
}

function searchMachine (){
  machineName="$1"
  echo "$machineName"
}
# Indicators
declare -i parameter_counter=0

while getopts "m:h" arg; do 
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter+=1;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
else
  helpPanel
fi


