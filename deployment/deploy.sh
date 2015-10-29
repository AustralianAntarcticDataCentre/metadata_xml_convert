#!/bin/sh

source /home/docker-data/aadc-metadata-conversion/git/deployment/variables.sh

build_images () {
	echo -e '\n----------------------------------------------------------'
	echo -e 'Building the aadc/metadata-conversion image'
	echo -e '----------------------------------------------------------'
	docker build -t aadc/metadata-conversion .
}

# Function to deploy the metadata conversion container.
deploy_application () {
	# Stop and remove the container
	docker stop aadc-metadata-conversion
	docker rm aadc-metadata-conversion

	echo -e '\n----------------------------------------------------------'
	echo -e 'Running the aadc-metadata-conversion container with persistent storage on the host'
	echo -e '----------------------------------------------------------'
	docker run \
		-d \
		-v /home/docker-data/aadc-metadata-conversion/git:/srv/git \
		-v /mnt/metadata/xml:/srv/data \
		-e BASE_PATH=$BASE_PATH \
		-e ANDS_XML_FILE_NAME=$ANDS_XML_FILE_NAME \
		-e ANDS_XML_FOLDER_PATH=$ANDS_XML_FOLDER_PATH \
		-e INPUT_PATH=$INPUT_PATH \
		-e OUTPUT_PATH=$OUTPUT_PATH \
		-e XSL_PATH=$XSL_PATH \
		-w /srv/git \
		--name aadc-metadata-conversion \
		aadc/metadata-conversion
}

# Build the Docker image
build_images

echo -e '\n----------------------------------------------------------'
echo -e 'Creating directory'
echo -e '----------------------------------------------------------'
mkdir -p /home/docker-data/aadc-metadata-conversion
mkdir -p /home/docker-data/aadc-metadata-conversion/log

# Call the function to deploy the application
deploy_application

# List the Docker containers
docker ps