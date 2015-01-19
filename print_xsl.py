import logging
import os

from settings import CONVERSIONS, LOGGING_FORMAT, XSL_PATH


logger = logging.getLogger(__name__)


def print_xsl_files():
	for index, parts in enumerate(CONVERSIONS):
		file_path = os.path.join(XSL_PATH, parts[0])
		print('{}: {}'.format(index + 1, file_path))


if '__main__' == __name__:
	logging.basicConfig(format=LOGGING_FORMAT, level=logging.DEBUG)

	print_xsl_files()
