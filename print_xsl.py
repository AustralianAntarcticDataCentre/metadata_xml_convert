import logging
import os

from settings import CONVERSIONS, LOGGING_KWARGS, XSL_PATH


logger = logging.getLogger(__name__)


def print_xsl_files():
	for index, parts in enumerate(CONVERSIONS):
		file_path = os.path.join(XSL_PATH, parts[0])
		print('{}: {}'.format(index + 1, file_path))


if '__main__' == __name__:
	logging.basicConfig(**LOGGING_KWARGS)

	print_xsl_files()
