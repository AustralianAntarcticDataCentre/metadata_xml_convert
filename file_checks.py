import logging
import os

from settings import (
	ADD_FOLDER_TO_FILE_NAME, CONVERSIONS, EXPORT_PATH, UPLOAD_PATH, XSL_PATH
)


logger = logging.getLogger(__name__)


def append_folder_to_file_name(file_path):
	"""
	Add the parent folder name between the file name and extension.

	So "/grandparent/parent/name.ext"
	Becomes "/grandparent/parent/name-parent.ext".

	This allows the file names to be unique if the parent folders are
	merged into one folder.
	"""

	# ["/grandparent/parent", "name.ext"]
	folder_path, file_name = os.path.split(file_path)

	# ["/grandparent", "parent"]
	grandparent_path, parent_name = os.path.split(folder_path)

	# ["name", ".ext"]
	file_base_name, file_ext = os.path.splitext(file_name)

	# ["name", "-", "parent", ".ext"]
	new_name = ''.join([file_base_name, '-', parent_name, file_ext])

	# ["/grandparent/parent", "name-parent.ext"]
	return os.path.join(folder_path, new_name)


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


def find_updated_files(force_conversion=False):
	"""
	Generate names of XML files that need to be converted.

	The "allowed" function still applies if `force_conversion` is True.
	"""

	xsl_path = lambda xsl: os.path.join(XSL_PATH, xsl)
	out_path = lambda folder: os.path.join(EXPORT_PATH, folder)

	# Only include conversions where the XSL and output folder exist.
	conversions = [
		(xsl_path(x), out_path(o), f)
		for x, o, f in CONVERSIONS
		if check_paths(xsl_path(x), out_path(o))
	]

	# Loop the contents of the input folder.
	for file_name in os.listdir(UPLOAD_PATH):
		# Ignore non-xml files.
		if not file_name.endswith('.xml'):
			continue

		# Get the path to the current file.
		input_file = os.path.join(UPLOAD_PATH, file_name)

		# Loop each of the conversion types.
		for xsl_path, output_folder, allowed in conversions:
			# Check for a function to check if conversion is allowed.
			if allowed is not None:
				# If conversion not allowed, skip to next item.
				if not allowed(input_file):
					continue

			# File path that will be output by the conversion.
			output_file = os.path.join(output_folder, file_name)

			# Folder to store any failed conversions.
			err_file = os.path.join(output_folder + '-error', file_name)

			# Tuple with file paths used in the conversion.
			paths = (input_file, xsl_path, output_file, err_file)

			# Do conversion if it is forced.
			if force_conversion:
				yield paths

			# Do conversion if it has not been done before.
			elif not os.path.exists(output_file):
				yield paths

			# Do conversion if the input file is newer.
			elif file_is_newer(input_file, output_file):
				yield paths


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
