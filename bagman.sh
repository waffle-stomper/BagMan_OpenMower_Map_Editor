#!/bin/bash

# This shell script can be used to run bagman on the mower, and then automatically restart OpenMower if you change
# something in the map file, (you can use the -n switch to disable the restart if you'd like).
# Note that you will need to create a virtual environment in the .venv directory and install the packages from
# requirements.txt before bagman will run.

# Handle the -n command line switch to disable automatic restart on change
NO_RELOAD=false
while getopts "n" opt;
do
    case "${opt}" in
        n) NO_RELOAD=true;;
    esac
done

if [[ $NO_RELOAD == true ]]
then
  echo "The -n switch was used so we won't restart the openmower service if this operation changes the map"
else
  echo "WARNING: THIS WILL RESTART THE OPENMOWER SERVICE IF YOU MAKE ANY CHANGES! Disable with -n"
fi

echo "Copying map file to working dir..."
sudo cp /root/ros_home/.ros/map.bag map.bag
sudo chown openmower:openmower map.bag

BEFORE_HASH=$(sha256sum map.bag)
echo "Hash before BagMan: $BEFORE_HASH"

.venv/bin/python3 bagman.py --input map.bag --output map.bag --overwrite-without-prompting

AFTER_HASH=$(sha256sum map.bag)
echo "Hash after BagMan: $AFTER_HASH"

if [[ $BEFORE_HASH == $AFTER_HASH ]]
then
  echo "No changes detected. No need to update the working map in ros_home with this one"
  exit 0
fi

echo "Map has changed!"

if [[ $NO_RELOAD == false ]]
then
  echo "Stopping OpenMower..."
  sudo service openmower stop
  sudo service openmower-debug stop
fi

echo "Copying map file back to /root/ros_home/.ros"
sudo cp map.bag /root/ros_home/.ros/map.bag
sudo chown root:root /root/ros_home/.ros/map.bag

if [[ $NO_RELOAD == false ]]
then
  echo "Starting OpenMower..."
  sudo service openmower start
else
  echo "-n flag specified. Not restarting openmower"
fi