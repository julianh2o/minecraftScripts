#!/bin/bash

S=`basename "$0"`

if [ "$1" = "-w" ]; then
    echo "Watching the directory and uploading on changes..."
    chsum1=""

    while [[ true ]] ; do
        chsum2=`find . -type f -exec md5 {} \;`
        if [[ $chsum1 != $chsum2 ]] ; then
            echo "Filesystem updated, uploading files..."
            ./upload.sh > /dev/null
            chsum1=$chsum2
        fi
        sleep 2
    done
else

    FILES=$(ls | grep -v $S)
    echo "$FILES" > files.txt

    scp * julianh2o@julianhartline.com:/home/julianh2o/julianhartline.com/minecraft/

    cat files.txt

    rm files.txt
fi
