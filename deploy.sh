#!/bin/sh

# Stop and remove the container
docker stop aadc-metadata-conversion
docker rm -f aadc-metadata-conversion

docker run \
	-d \
	-v /home/docker-data/metadata_xml_convert:/srv/git \
	-v /mnt/q/database/metadata/xml:/srv/data \
	-e BASE_PATH='/srv/data' \
	-e ANDS_XML_FILE_NAME='/srv/data/AAD_RegistryObjects.xml' \
	-e ANDS_XML_FOLDER_PATH='/srv/data/ands_rif-cs' \
	-e INPUT_PATH='/srv/data/dif' \
	-e OUTPUT_PATH='/srv/data/' \
	-e XSL_PATH='/srv/git/xsl' \
	-w /srv/git \
	--name aadc-metadata-conversion \
	java:latest /bin/sh -c "python -u /srv/git/delete_converts.py; python -u /srv/git/convert_files.py;"