"""
Create an ANDS RIF-CS XML file.


Links
-----

- http://ands.org.au/guides/cpguide/cpgrifcs.html

- http://ands.org.au/resource/rif-cs.html

- http://services.ands.org.au/documentation/rifcs/guidelines/rif-cs.html
"""

import logging
import os

from settings import (
	ANDS_XML_FILE_NAME, ANDS_XML_FOLDER_PATH, ANDS_XML_START, ANDS_XML_STOP,
	LOGGING_FORMAT
)


logger = logging.getLogger(__name__)


def main():
	with open(ANDS_XML_FILE_NAME, 'w') as w:
		w.write(ANDS_XML_START)

		for file_path in os.listdir(ANDS_XML_FOLDER_PATH):
			with open(file_path) as r:
				w.write(r.read())

		w.write(ANDS_XML_STOP)


if '__main__' == __name__:
	logging.basicConfig(format=LOGGING_FORMAT, level=logging.DEBUG)

	main()
