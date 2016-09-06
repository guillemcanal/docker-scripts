#!/bin/bash

####################
# Docker functions #
####################

CONTEXT=""
CONTEXT_VALUE=""

# Initialize a container name context
function container
{
    CONTEXT="container"
    CONTEXT_VALUE=$1
    ${@:2}
}

# Initialize a docker volume name context
function volume
{
    CONTEXT="volume"
    CONTEXT_VALUE=$1
    ${@:2}
}

# Initialize a docker network name context
function network
{
    CONTEXT="network"
    CONTEXT_VALUE=$1
    ${@:2}
}

# Check if one container is running
# usage: container CONTAINER_NAME is_running
function is_running
{
    # this expression is only compatible with the container context
    _check_context "container"

    local OUT=1
    local STATE=$(docker inspect -f {{.State.Running}} $CONTEXT_VALUE 2> /dev/null || echo "undefined")

    if [ $STATE == "undefined" ]; then
        echo "container $CONTEXT_VALUE does not exist"
        exit 1
    fi
    
    [ "$STATE" == "true" ] && OUT=0
    
    _clear_context

    return $OUT
}

# Check if one container is stopped
# usage: container CONTAINER_NAME is_stopped
function is_not_running
{
    is_running
    [ "$?" -eq 0 ] && return 1 || return 0
}

# Check if one container exist
# usage: container CONTAINER_NAME exist
function exist
{
    local INSPECT_ARG=""
    local OUT=1

    _check_context "container|volume|network"

    [[ $CONTEXT =~ volume|network ]] && INSPECT_ARG=$CONTEXT
    docker $INSPECT_ARG inspect $CONTEXT_VALUE > /dev/null 2>&1
    OUT=$?
    
    _clear_context

    return $OUT
}

# Check if one container don't exist
# usage: container CONTAINER_NAME dont_exist
function dont_exist()
{
    exist
    [ "$?" -eq 0 ] && return 1 || return 0
}

# Check if one container was created from a given image name
# usage: container CONTAINER_NAME is_an_image_of IMAGE_NAME
function created_from_image
{
    _check_context "container"

    if [ -z ${1+x} ];then
        echo "is_an_image_of expect one argument IMAGE_NAME"
        exit 1
    fi

    local IMAGE=$(docker inspect -f "{{.Config.Image}}" $CONTEXT_VALUE 2> /dev/null || echo "undefined")

    if [ $IMAGE == "undefined" ];then
        echo "container $CONTEXT_VALUE does not exist"
        exit 1
    fi

    _clear_context

    [ "$IMAGE" == $1 ] && return 0 || return 1
}

# Check if one container was not created from a given image name
# usage: container CONTAINER_NAME is_not_an_image_of IMAGE_NAME
function not_created_from_image
{
    created_from_image $1
    [ "$?" -eq 0 ] && return 1 || return 0
}

function _check_context
{
    if [ "$CONTEXT_VALUE" == "" ];then
        echo "you must set a context using expression container, volume or network"
        exit 1
    fi

    if [ ! -z ${1+x} ] && [[ ! $CONTEXT =~ $1 ]];then
        echo "using expression with the wrong context"
        exit 1
    fi
}

function _clear_context
{
    CONTEXT=""
    CONTEXT_VALUE=""
}