import logging
import os

from settings import (
	ADD_FOLDER_TO_FILE_NAME, CONVERSIONS, INPUT_PATH, OUTPUT_PATH, XSL_PATH
)


logger = logging.getLogger(__name__)


def append_folder_to_file_name(file_path):
	"""
	Add the parent folder name between the file name and extension.

	So "/grandparent/parent/name.ext"
	Becomes "/grandparent/parent/name-parent.ext".

	This allows the file names to be unique if the parent folders are
	merged into one folder.


	Parameters
	----------

	file_path : str
		Path to file to be modified.


	Returns
	-------

	str
		Return the modified file path.
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
	Check if all file paths are valid.


	Returns
	-------

	bool
		Return True if all paths exist, False if any are invalid.
	"""

	for f in paths:
		if not os.path.exists(f):
			return False

	return True


def file_is_newer(older_file, newer_file):
	"""
	Return True if the first file is newer than the second.

	Make sure each argument is the full path to the file.


	Returns
	-------

	bool
		True if the first file is newer than the second.
	"""

	#newer_file_stat = os.stat(newer_file)
	#older_file_stat = os.stat(older_file)
	#return older_file_stat.st_mtime < newer_file_stat.st_mtime

	#if 1 == len(args):
		#return True
	#last_file_path = args[0]
	#for file_path in args[1:]:
		#if os.path.getmtime(file_path) < os.path.getmtime(last_file_path):
			#return False
	#return True

	return os.path.getmtime(older_file) < os.path.getmtime(newer_file)
	#return os.path.getctime(older_file) < os.path.getctime(newer_file)


def find_updated_files(force_conversion=False, conversions=None):
	"""
	Generate names of XML files that need to be converted.

	The "allowed" function still applies even if `force_conversion` is True.


	Parameters
	----------

	force_conversion : bool, optional
		Perform conversion even if the converted file is newer.

	conversions : list, optional
		List of conversions to perform.
		Each is a tuple containing the XSL name, output folder and a function to
		check if conversion is allowed.


	Yields
	------

	tuple of str
		Yields a tuple of file paths required for the XSL conversion.
		In order: input, XSL, output, error.
	"""

	full_conversion_details = get_full_conversion_details(conversions)

	# Loop the contents of the input folder.
	for file_name in os.listdir(INPUT_PATH):
		# Skip files with the wrong extension.
		if not file_name.endswith('.xml'):
			continue

		# Get the path to the current input file.
		input_file = os.path.join(INPUT_PATH, file_name)

		# Loop each of the conversion types.
		for xsl_path, output_folder, allowed in full_conversion_details:
			# Check for a function to check if conversion is allowed.
			if allowed is not None:
				# If conversion not allowed, skip to next item.
				if not allowed(input_file):
					continue

			# File path that will be output by the conversion.
			output_file = os.path.join(output_folder, file_name)

			# Insert the parent folder name into the file name.
			# This returns a new file path that the function creates.
			output_file = append_folder_to_file_name(output_file)

			# Folder to store any failed conversions.
			err_file = os.path.join(output_folder + '_error', file_name)

			# Tuple with file paths used in the conversion.
			paths = (input_file, xsl_path, output_file, err_file)

			# Do conversion if it is forced.
			if force_conversion:
				logger.debug('Forced conversion of %s.', input_file)
				yield paths

			# Do conversion if it has not been done before.
			elif not os.path.exists(output_file):
				logger.debug('Creating new conversion %s.', output_file)
				yield paths

			# Do conversion if the input file is newer.
			elif file_is_newer(output_file, input_file):
				logger.debug('Converting newer input %s.', input_file)
				yield paths


def get_files_in_folder(folder, ext=''):
	"""
	Generate names of files in a folder.


	Parameters
	----------

	folder : str
		Path to the folder to generate file names from.

	ext : str, optional
		File extension filter.


	Yields
	------

	str
		Yields the full path of files found.
	"""

	logger.debug('Checking for "%s" in %s', ext, folder)

	# Loop the contents of the folder.
	for file_name in os.listdir(folder):
		# Skip files with the wrong extension.
		if not file_name.endswith(ext):
			continue

		yield os.path.join(folder, file_name)


def get_full_conversion_details(conversions=None):
	"""
	Update the conversion file names to use the path settings.


	Parameters
	----------

	conversions : list of tuples, optional
		List of the conversion details.
		Uses all conversions by default.


	Returns
	-------

	list
		Returns an updated list of tuples in the same structure as passed in.
	"""

	xsl_path = lambda xsl: os.path.join(XSL_PATH, xsl)
	out_path = lambda folder: os.path.join(OUTPUT_PATH, folder)

	if conversions is None:
		conversions = CONVERSIONS

	# Only include conversions where the XSL and output folder exist.
	return [
		(xsl_path(x), out_path(o), f)
		for x, o, f in conversions
		if check_paths(xsl_path(x), out_path(o))
	]


def get_input_path(output_path):
	"""
	Get the original file name from a converted file name.


	Parameters
	----------

	file_path : str
		Path to file to be modified.


	Returns
	-------

	str
		Return the modified file path.
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

	return os.path.join(INPUT_PATH, file_name)
