import logging
import os

from settings import ADD_FOLDER_TO_FILE_NAME, UPLOAD_PATH


logger = logging.getLogger(__name__)


def check_paths(*paths):
	"""
	Return True if all paths exist, False if any are invalid.
	"""

	for f in paths:
		if not os.path.exists(f):
			return False

	return True


def file_is_newer(newer_file, older_file):
	"""
	Return True if the first file is newer than the second.

	Make sure each argument is the full path to the file.
	"""

	return os.path.getmtime(newer_file) > os.path.getmtime(newer_file)
	#return os.path.getctime(newer_file) > os.path.getctime(newer_file)


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
