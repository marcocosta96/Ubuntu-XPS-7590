#!/bin/bash
if [ $# -eq 1 ]; then 
	while ps -p $1; do sleep 1; done ; shutdown -h
else
	echo "Insert PID to wait for shutdown"
fi
