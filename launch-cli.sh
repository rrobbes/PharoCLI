#! /bin/bash


export PHARO_CLI_PORT=$2
echo $PHARO_CLI_PORT

/Applications/PharoLauncher.app/Contents/Resources/pharo-launcher image launch $1 --script pharo-cli.st --detached
sleep 1
echo "3 + 4" | nc localhost $PHARO_CLI_PORT
