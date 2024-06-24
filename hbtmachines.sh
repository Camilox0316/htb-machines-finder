#!/bin/bash

function ctrl_c(){
  echo -e "\n\n [!] Exiting...\n"
  exit 1
}

# Ctrl + c
trap ctrl_c INT
