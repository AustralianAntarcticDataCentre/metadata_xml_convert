#!/bin/sh

#export BASE_PATH='/home/docker-data/aadc-metadata/data'
#export ANDS_XML_FILE_NAME='${BASE_PATH}/AAD_RegistryObjects.xml'
#export ANDS_XML_FOLDER_PATH='${BASE_PATH}/ands_rif-cs'
#export INPUT_PATH='${BASE_PATH}/dif'
#export OUTPUT_PATH='${BASE_PATH}/'
#export XSL_PATH='/home/docker-data/aadc-metadata-conversion/git/xsl'

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
		-v /home/docker-data/aadc-metadata/data/dif:/srv/dif \
		-e BASE_PATH=$BASE_PATH \
		-e ANDS_XML_FILE_NAME=$ANDS_XML_FILE_NAME \
		-e ANDS_XML_FOLDER_PATH=$ANDS_XML_FOLDER_PATH \
		-e INPUT_PATH=$INPUT_PATH \
		-e OUTPUT_PATH=$OUTPUT_PATH \
		-e XSL_PATH=$XSL_PATH \
		--name aadc-metadata-conversion \
		--restart=always \
		aadc/metadata-conversion \
		cp /srv/git/deployment/settings.py /srv/git/settings.py
}

# Build the Docker image
build_images

echo -e '\n----------------------------------------------------------'
echo -e 'Creating directory'
echo -e '----------------------------------------------------------'
mkdir -p /home/docker-data/aadc-metadata-conversion/git

# Call the function to deploy the application
deploy_application

# List the Docker containers
docker ps