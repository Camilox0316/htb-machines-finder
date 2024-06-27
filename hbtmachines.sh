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
  echo -e "\t${purpleColour}u) ${endColour}${grayColour}Update files${endColour}"
  echo -e "\t${purpleColour}m) ${endColour}${grayColour}Find by a machine's name${endColour}"
  echo -e "\t${purpleColour}i) ${endColour}${grayColour}Find by a machine's IP${endColour}"
  echo -e "\t${purpleColour}y) ${endColour}${grayColour}Get YT's solution${endColour}"
  echo -e "\t${purpleColour}d) ${endColour}${grayColour}Get Machines by difficulty${endColour}"
  echo -e "\t${purpleColour}o) ${endColour}${grayColour}Get Machines by Operating system${endColour}"
  echo -e "\t${purpleColour}h) ${endColour}${grayColour}Show help${endColour}\n"
}

function searchMachine (){
  machineName="$1"
  machineName_Checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  if [ "$machineName_Checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Showing${endColour} ${blueColour}$machineName ${endColour} ${grayColour}properties:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] Machine not found${endColour}\n"
  fi 
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

function searchIP(){
  ipAddr="$1"
  ip_checker="$(cat bundle.js | grep "ip: \"$ipAddr\"" -B 3 | grep "name: " | awk 'NF {print $NF}' | tr -d '"' | tr -d ",")"

  if [ "$ip_checker" ]; then
    machineName="$(cat bundle.js | grep "ip: \"$ipAddr\"" -B 3 | grep "name: " | awk 'NF {print $NF}' | tr -d '"' | tr -d ",")"
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}The machine owner of the address${endColour} ${blueColour}$ipAddr${endColour} ${grayColour}is:${endColour}${purpleColour} $machineName ${endColour}\n"

  else
    echo -e "\n${redColour}[!] IP not found${endColour}\n"
  fi
}

function getYTLink(){
  machineName="$1"
  ytLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')" 
  if [[ "$ytLink" ]]; then
    echo -e "${yellowColour}[!]${endColour} ${grayColour} The tutorial to solve this machine is here: ${endColour} ${blueColour}$ytLink${endColour}"
  else
    echo -e "\n${redColour}[!] Machine not found${endColour}\n"
    
  fi
}

function setDifficultyColor(){
  difficulty="$1"
  machines="$2"
  if [[ "$difficulty" == "Fácil" ]]; then
    color="${greenColour}"
  elif [ "$difficulty" == "Media" ]; then
    color="${yellowColour}"
  elif [ "$difficulty" == "Difícil" ]; then
    color="${redColour}"
  else
    color="${purpleColour}"  
  fi
  echo -e "${color}$machines${endColour}"
}

function getMachinesByDifficulty(){
  diff="$1"
  machines="$(cat bundle.js | grep "dificultad: \"$diff\"" -B 5 | grep name | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [[ "$machines" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Showing machines with ${endColour}${blueColour}$diff${endColour} ${grayColour}difficulty:${endColour} \n" 
    setDifficultyColorOutput=$(setDifficultyColor "$diff" "$machines")
    echo -e "$setDifficultyColorOutput"
  else
    echo -e "${redColour}[!] Wrong difficulty ${endColour}"
  fi

}

function getMachinesByOS(){
  OS="$1"
  os_checker="$(cat bundle.js | grep "so: \"$OS\"" -B 5  | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [[ "$os_checker" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Showing${endColour} ${blueColour}$OS${endColour} ${grayColour}machines${endColour}\n\n$os_checker\n"
    
  else
    echo -e "\n${redColour}[!]OS not found${endColour}\n"
    
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  OS="$2"
  check="$(cat bundle.js | grep "so: \"$OS\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: "| awk 'NF {print $NF}' | tr -d ',' | tr -d '"' | column)"
  if [ "$check" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Showing${endColour}${blueColour} $difficulty${endColour}${grayColour} machines in${endColour}${purpleColour} $OS${endColour}${grayColour} systems${endColour}\n"
    setDifficultyColorOutput=$(setDifficultyColor "$difficulty" "$check")
    echo -e "$setDifficultyColorOutput"
    #cat bundle.js | grep "so: \"$OS\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: "| awk 'NF {print $NF}' | tr -d ',' | tr -d '"' | column
  else
    echo -e "\n${redColour}[!] Wrong difficulty or OS${endColour}\n"
  fi
}
# Indicators
declare -i parameter_counter=0

# Sneak
declare -i sneak_difficulty=0
declare -i sneak_OS=0
while getopts "m:ui:y:d:o:h" arg; do 
  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; sneak_difficulty=1; let parameter_counter+=5;;
    o) OS="$OPTARG"; sneak_OS=1; let parameter_counter+=6;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYTLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getMachinesByOS $OS
elif [ $sneak_difficulty -eq 1 ] && [ $sneak_OS -eq 1 ]; then
  getOSDifficultyMachines $difficulty $OS
else
  helpPanel
fi


