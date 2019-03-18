#!/bin/bash

date >> ~/.menu2ctrl.log
echo menu2ctrl.bash >> ~/.menu2ctrl.log
xmodmap -e 'keycode 135 = Control_R'
xmodmap -e 'keycode 66 = Control_L'
xmodmap -e 'clear lock'
xmodmap -e 'clear control'
xmodmap -e 'add control = Control_R Control_L'
xmodmap >> ~/.menu2ctrl.log
