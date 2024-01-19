#!/bin/bash

## Try to install jdk please check the needn't version
# sudo apt install openjdk-17-jre

WKDIR=$(cd $(dirname $0); pwd) 

## Start to add desktop file
#echo '[Desktop Entry' > STM32CubeMX.desktop
#echo 'Name=STM32CubeMX' > STM32CubeMX.desktop
#echo 'GenericName=STM32 Config Tool' > STM32CubeMX.desktop
cat>STM32CubeMX.desktop<<EOF
[Desktop Entry]
Name=STM32CubeMX
GenericName=STM32 Config Tool
Categories=Development
Comment=STM32CubeMX
Exec=java -jar $WKDIR/STM32CubeMX
Icon=$WKDIR/help/STM32CubeMX.ico
Path=$WKDIR
Terminal=true
Type=Application
StartupNotify=true
EOF

cp STM32CubeMX.desktop $HOME/.local/share/applications/