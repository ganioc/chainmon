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
    LINE=$(docker ps | grep "${container}")
    SEARCH_NAME=$(echo $LINE | awk '/ruffchain1$/{print $NF}')
    if [ "${SEARCH_NAME}" == "${container}" ]; then
        echo 0
    else
        echo 1
    fi

}
check_connection() {
    container=$1
    # docker exec -it ruffchain1 netstat -anpt | grep tcp | awk '{print $2  "#" $3}'
    LINES=$(docker exec -it "${container}" netstat -anpt | grep tcp | awk '{print $2  "#" $3}') 
    counter=0
    problems=0
    for value in $LINES
    do
        if [ $value == "0#0" ]; then
	    counter=$((counter+1))
	else
	    counter=$((counter+1))
	    problems=$((problems+1))
	fi
    done 
    half_counter=$((counter/2))
    if [ ${problems} -gt ${half_counter} ]; then
        echo 1
    else
	echo 0
    fi
}
restart () {

    # stop container
    echo "stop container ${CONTAINER_NAME}"
    sleep 3
    docker stop ${CONTAINER_NAME}

    # rm container
    echo "rm container ${CONTAINER_NAME}"
    sleep 3
    docker rm ${CONTAINER_NAME}

    # restart container
    echo "start container ${CONTAINER_NAME}"
    echo "cd ${START_LOC}"
    sleep 3
    cd ${START_LOC}
    pwd
    ./${START_SCRIPT}
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
CHECK_TIMES=0
MAX_CHECK_TIMES=4

#restart
#exit 0

while [ 1 ]; do
    wait ${INTERVAL}
    RET=$(check_container "${CONTAINER_NAME}")
    #RET=$?
    echo "RET: " ${RET}
    if [ ${RET} -ne 0 ]; then
        echo  "check_container return one" ${RET}
	continue
    fi

    RET=$(check_connection "${CONTAINER_NAME}")
    echo "RET: " ${RET}
    if [ ${RET} -ne 0 ]; then
        echo  "check_connection return one" ${RET}
	CHECK_TIMES=$((CHECKTIMES+1))
    else
	echo "check_connection return zero" ${RET}
	CHECK_TIMES=$((CHECKTIMES-1))
	if [ ${CHECK_TIMES} -lt 0 ]; then
	    CHECK_TIMES=0
	fi
    fi


    if [ ${CHECK_TIMES} -gt ${MAX_CHECK_TIMES} ]; then
    #if [ ${CHECK_TIMES} -gt -5 ]; then
        CHECK_TIMES=0
	restart
    fi

done




