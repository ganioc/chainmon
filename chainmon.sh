#!/bin/bash

help () {
    echo "========================="
    echo "Exp:  chainmo.sh chainmon.conf"
    echo ""
    echo "========================="
}
check_empty () {
    str=$1
    arg1=$2

    if [ -z "${arg1}" ]; then
        echo "${str}: Empty"
	help
	exit 1
    fi
}
get_from_conf () {
    PATTERN=$1
    NAME=$2

    LINE=$(awk -v var="${PATTERN}" '$0 ~ var {print $0}' ${NAME})
    check_empty "${PATTERN} empty" LINE
    VAL=${LINE##*=}
    check_empty "${PATTERN} empty" VAL
    echo ${VAL}
}
wait (){
    check_empty "wait ? seconds" $1
    echo "sleep"  $1 " seconds"
    sleep $1
}

check_container (){
    container=$1
    # echo ${container}    
    check_empty "container name" ${container}
    echo 0
}
#echo "Config file: " $1
check_empty  "Config File" $1

FILE=$1
INTERVAL=$(get_from_conf "^INTERVAL=" ${FILE})
echo "INTERVAL is: " ${INTERVAL}
CONTAINER_NAME=$(get_from_conf "^CONTAINER_NAME=" ${FILE})
echo "CONTAINER_NAME is: " ${CONTAINER_NAME}
START_LOC=$(get_from_conf "^START_LOC=" ${FILE})
echo "START_LOC is:" ${START_LOC}
START_SCRIPT=$(get_from_conf "^START_SCRIPT=" ${FILE})
echo "START_SCRIPT is:" ${START_SCRIPT}

while [ 1 ]; do
    wait ${INTERVAL}
    RET=$(check_container "${CONTAINER_NAME}")
    #RET=$?
    echo "RET: " ${RET}
    if [ ${RET} -ne 0 ]; then
        echo  "return one" ${RET}
	continue
    fi

done




