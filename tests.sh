#!/bin/bash

source docker-functions.sh

TEST_CONTAINER_NAME="test-container-$RANDOM"
TEST_VOLUME_NAME="test-volume-$RANDOM"
TEST_NETWORK_NAME="test-network-$RANDOM"
TEST_STATUS_CODE=0

##############################
# TEST CONTAINER EXPRESSIONS #
##############################

if container $TEST_CONTAINER_NAME dont_exist;then
	echo "✓ test container dont exist"
else
	echo "✗ test container dont exist"
	TEST_STATUS_CODE=1
fi

# Run docker container
docker run -d --name $TEST_CONTAINER_NAME alpine top > /dev/null

if container $TEST_CONTAINER_NAME exist;then
	echo "✓ test container exist"
else
	echo "✗ test container exist"
	TEST_STATUS_CODE=1
fi

if container $TEST_CONTAINER_NAME is_running;then
	echo "✓ container is running"
else
	echo "✗ container is running"
	TEST_STATUS_CODE=1
fi

docker stop $TEST_CONTAINER_NAME > /dev/null

if container $TEST_CONTAINER_NAME is_not_running;then
	echo "✓ container is not running"
else
	echo "✗ container is not running"
	TEST_STATUS_CODE=1
fi

if container $TEST_CONTAINER_NAME created_from_image "alpine";then
	echo "✓ container created from image"
else
	echo "✗ container created from image"
	TEST_STATUS_CODE=1
fi

if container $TEST_CONTAINER_NAME not_created_from_image "ubuntu";then
	echo "✓ container not created from image"
else
	echo "✗ container not created from image"
	TEST_STATUS_CODE=1
fi

###########################
# TEST VOLUME EXPRESSIONS #
###########################

if volume $TEST_VOLUME_NAME dont_exist;then
	echo "✓ volume dont exist"
else
	echo "✗ volume dont exist"
	TEST_STATUS_CODE=1
fi

docker volume create --name $TEST_VOLUME_NAME > /dev/null

if volume $TEST_VOLUME_NAME exist;then
	echo "✓ volume exist"
else
	echo "✗ volume exist"
	TEST_STATUS_CODE=1
fi

############################
# TEST NETWORK EXPRESSIONS #
############################

if network $TEST_NETWORK_NAME dont_exist;then
	echo "✓ network dont exist"
else
	echo "✗ network dont exist"
	TEST_STATUS_CODE=1
fi

docker network create $TEST_NETWORK_NAME > /dev/null

if network $TEST_NETWORK_NAME exist;then
	echo "✓ network exist"
else
	echo "✗ network exist"
	TEST_STATUS_CODE=1
fi

# Cleanup
docker rm -f $TEST_CONTAINER_NAME > /dev/null
docker volume rm $TEST_VOLUME_NAME > /dev/null
docker network rm $TEST_NETWORK_NAME > /dev/null

exit $TEST_STATUS_CODE

