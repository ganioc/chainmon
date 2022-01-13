#!/bin/bash

if [ -z $1 ]; then
    echo "Error:"
    echo "./reset.sh arg"
    exit 1
fi

FILE_NAME="./chainmon.conf"
COMMENT_INTERVAL="# checking interval, in seconds"
COMMENT_CONTAINER="# docker container name"
COMMENT_LOC="# start script location"
COMMENT_SCRIPT="# start script"
INTERVAL=240


check_empty () {
    COMMENT=$1
    VAL=$2
    if [ -z ${VAL} -o -z ${COMMENT} ]; then
        echo "Empty arg ${COMMENT} ${VAL}"
	exit 1
    fi    
}
create_header (){
    echo "# chainmon script" > ${FILE_NAME}
    echo "# auto generated" >> ${FILE_NAME}
    echo "" >> ${FILE_NAME}
}
create_interval () {

    create_header
    echo "Use interval: ${INTERVAL}"

    echo "${COMMENT_INTERVAL}" >> ${FILE_NAME}
    echo "INTERVAL=${INTERVAL}" >> ${FILE_NAME}
    echo " " >> ${FILE_NAME}
}

create_container () {
    check_empty "CONTAINER" $1
    CONTAINER=$1
    echo "Use container name: ${CONTAINER}"
    
    echo "${COMMENT_CONTAINER}" >> ${FILE_NAME}
    echo "CONTAINER_NAME=${CONTAINER}" >> ${FILE_NAME}
    echo " " >> ${FILE_NAME}
}
create_loc () {
    check_empty "LOC" $1
    LOC=$1

    echo "Use start LOC: ${LOC}"

    echo "${COMMENT_LOC}" >> ${FILE_NAME}
    echo "START_LOC=${LOC}" >> ${FILE_NAME}
    echo " " >> ${FILE_NAME}
}
create_script () {
    check_empty "SCRIPT" $1
    SCRIPT=$1

    echo "Use start SCRIPT: ${SCRIPT}"

    echo "${COMMENT_SCRIPT}" >> ${FILE_NAME}
    echo "START_SCRIPT=${SCRIPT}" >> ${FILE_NAME}
    echo " " >> ${FILE_NAME}
}
create_node1 () {
    create_interval
    create_container ruffchain1
    create_loc /mnt/disk/chainnode
    create_script runtestnode1.sh
}
create_node3 () {
    create_interval
    create_container ruffchain1
    create_loc /mnt/disk/chainnode
    create_script runtestnode3.sh
}
create_peer1 () {
    create_interval
    create_container ruffchainpeer1
    create_loc /mnt/disk/chainnode
    create_script runtestpeer.sh
}

if [ $1 == "peer1" ]; then
    echo "reset peer1"
    create_peer1
    echo "reset done"

else
    echo "unknown type"
fi

