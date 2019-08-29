#!/bin/bash
#


# Define the data storage directory, default is "/data".
DATA=${DATA:=/data}

WORK="/usr/local/mm-wiki"
OCFG="$WORK/conf"
CONF="$DATA/conf"

if [ ! -L "$OCFG" ]; then
    if [ ! -d $CONF ]; then
        mkdir -p $CONF
        mv $OCFG/* $CONF
    fi
    rm -fr $OCFG
    ln -s $CONF $OCFG
fi

if [ ! -f "$OCFG/mm-wiki.conf" ]; then
    exec $WORK/install/install -port 8080
else
    exec $WORK/mm-wiki -conf $OCFG/mm-wiki.conf
fi


