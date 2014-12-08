import logging
import os

from settings import CONVERSIONS, LOGGING_FORMAT, OUTPUT_PATH


logger = logging.getLogger(__name__)


def main():
	"""
	Create the output folder for each of the conversion types.
	"""

	for xsl_file_name, output_folder, checker in CONVERSIONS:
		# Get the conversion output folder.
		output_path = os.path.join(OUTPUT_PATH, output_folder)

		if os.path.exists(output_path):
			logger.info('%s already exists.', output_path)
		else:
			os.makedirs(output_path)
			logger.info('Created %s.', output_path)

		# Get the conversion error folder.
		error_path = os.path.join(OUTPUT_PATH, output_folder + '_error')

		if os.path.exists(error_path):
			logger.info('%s already exists.', error_path)
		else:
			os.makedirs(error_path)
			logger.info('Created %s.', error_path)


if '__main__' == __name__:
	logging.basicConfig(format=LOGGING_FORMAT, level=logging.DEBUG)

	logger.debug('Folder creation started.')

	main()

	logger.debug('Folder creation finished.')
