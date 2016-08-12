#!/bin/sh

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
		-v /mnt/aadc/database/metadata/xml:/srv/data \
		-e BASE_PATH='/srv/data' \
		-e ANDS_XML_FILE_NAME='/srv/data/AAD_RegistryObjects.xml' \
		-e ANDS_XML_FOLDER_PATH='/srv/data/ands_rif-cs' \
		-e INPUT_PATH='/srv/data/dif' \
		-e OUTPUT_PATH='/srv/data/' \
		-e XSL_PATH='/srv/git/xsl' \
		-w /srv/git \
		--name aadc-metadata-conversion \
		java:latest /bin/sh -c "python -u /srv/git/delete_converts.py; python -u /srv/git/convert_files.py;"
}

echo -e '\n----------------------------------------------------------'
echo -e 'Creating directory'
echo -e '----------------------------------------------------------'
mkdir -p /home/docker-data/aadc-metadata-conversion
mkdir -p /home/docker-data/aadc-metadata-conversion/log

# Call the function to deploy the application
deploy_application

# List the Docker containers
docker ps


