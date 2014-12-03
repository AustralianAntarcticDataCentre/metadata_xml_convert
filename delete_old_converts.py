import logging
import os

from file_checks import get_files_in_folder, get_input_path
from settings import (
	ADD_FOLDER_TO_FILE_NAME, CONVERSIONS, EXPORT_PATH, UPLOAD_PATH
)


logger = logging.getLogger(__name__)


def main():
	# Loop each conversion type, getting the folder name.
	for xsl_file_name, output_folder, checker in CONVERSIONS:
		output_path = os.path.join(EXPORT_PATH, output_folder)

		# Skip this conversion type if the folder does not exist.
		if not os.path.exists(output_path):
			logger.debug('Skipping %s', output_path)
			continue

		logger.debug('Loop XML in %s', output_path)

		# Loop the XML files in the conversion folder.
		for output_file_path in get_files_in_folder(output_path, '.xml'):
			input_file_path = get_input_path(output_file_path)

			# Make sure the original file exists.
			if os.path.exists(input_file_path):
				continue

			logger.info('Deleting %s', output_file_path)

			os.remove(output_file_path)


yaml_fmt = '''
- file: %(pathname)s
  level: %(levelname)s
  line: %(lineno)s
  message: |
    %(message)s
  time: %(asctime)s
'''.strip()


if '__main__' == __name__:
	logging.basicConfig(format=yaml_fmt, level=logging.DEBUG)

	logger.debug('File checking started')

	main()

	logger.debug('File checking complete')
