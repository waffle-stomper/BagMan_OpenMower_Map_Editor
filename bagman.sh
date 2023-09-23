#!/bin/bash

# This shell script can be used to run bagman on the mower, and then automatically restart OpenMower if you change
# something in the map file.
# Note that you will need to create a virtual environment in the .venv directory and install the packages from
# requirements.txt before bagman will run.

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

echo "Stopping OpenMower..."
sudo service openmower stop
sudo service openmower-debug stop

echo "Copying map file back to /root/ros_home/.ros"
sudo cp map.bag /root/ros_home/.ros/map.bag
sudo chown root:root /root/ros_home/.ros/map.bag
echo "Starting OpenMower..."
sudo service openmower start
