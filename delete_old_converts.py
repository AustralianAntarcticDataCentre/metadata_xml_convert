import logging
import os

from settings import (
	ADD_FOLDER_TO_FILE_NAME, CONVERSIONS, EXPORT_PATH, UPLOAD_PATH
)


logger = logging.getLogger(__name__)


def get_files_in_folder(folder, ext=''):
	logger.debug('Checking for %s in %s', ext, folder)

	# Loop the contents of the folder.
	for file_name in os.listdir(folder):
		# Skip files with the wrong extension.
		if not file_name.endswith(ext):
			continue

		yield os.path.join(folder, file_name)


def get_input_path(output_path):
	"""
	Get the original file name from a converted file name.
	"""

	# ["/grandparent/parent", "file.ext"]
	folder_path, file_name = os.path.split(output_path)

	# ["/grandparent", "parent"]
	grandparent_path, parent_name = os.path.split(folder_path)

	# Check if file name is actually `file-parent.ext`.
	if ADD_FOLDER_TO_FILE_NAME:
		# ["name-parent", ".ext"]
		file_base_name, file_ext = os.path.splitext(file_name)

		dash_parent = '-{}'.format(parent_name)

		# Make sure the file name includes the parent.
		if file_base_name.endswith(dash_parent):
			file_base_name = file_base_name[:-len(dash_parent)]

		file_name = '{}{}'.format(file_base_name, file_ext)

	return os.path.join(UPLOAD_PATH, file_name)


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
