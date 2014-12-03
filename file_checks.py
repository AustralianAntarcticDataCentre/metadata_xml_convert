import os


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
