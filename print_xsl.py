import logging
import os

from settings import CONVERSIONS, LOGGING_FORMAT, XSL_PATH


logger = logging.getLogger(__name__)


def print_xsl_files():
	for parts in CONVERSIONS:
		file_path = os.path.join(XSL_PATH, parts[0])
		print(file_path)


if '__main__' == __name__:
	logging.basicConfig(format=LOGGING_FORMAT, level=logging.DEBUG)

	print_xsl_files()
