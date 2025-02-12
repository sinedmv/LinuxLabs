#!/bin/bash

if [ -f "work3.log" ]; then
    logFile='work3.log'
    rm $logFile
    echo 'Deleted' $logFile
fi