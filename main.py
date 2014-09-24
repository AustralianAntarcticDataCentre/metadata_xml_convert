import argparse
import os
from shutil import copyfile
from subprocess import call
from uuid import uuid4

from settings import CONVERSIONS, EXPORT_PATH, UPLOAD_PATH, XSL_PATH


def file_is_newer(newer_file, older_file):
	"""
	Return True if the first file is newer than the second.

	Make sure each argument is the full path to the file.
	"""

	return os.path.getmtime(newer_file) > os.path.getmtime(newer_file)
	#return os.path.getctime(newer_file) > os.path.getctime(newer_file)


def get_msxsl_call(input_file, transform_file, output_file):
	return ('msxsl.exe', input_file, transform_file, '-o', output_file)


def get_saxon_call(input_file, transform_file, output_file):
	return (
		'java',
		'-jar',
		'saxon9.jar',
		'-s:' + input_file,
		'-xsl:' + transform_file,
		'-o:' + output_file
	)


def check_paths(*paths):
	"""
	Return True if all paths exist, False if any are invalid.
	"""

	for f in paths:
		if not os.path.exists(f):
			return False

	return True


def find_updated_files(force_conversion=False):
	"""
	Generate names of XML files that need to be converted.
	"""

	xsl_path = lambda xsl: os.path.join(XSL_PATH, xsl)
	out_path = lambda folder: os.path.join(EXPORT_PATH, folder)

	# Only include conversions where the XSL and output folder exist.
	conversions = [
		(xsl_path(x), out_path(o))
		for x, o in CONVERSIONS
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
		for xsl_path, output_folder in conversions:
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


def add_random_uuid_to_file(file_name):
	with open(file_name) as h:
		content = h.read()

	parts = content.split('INSERT_RANDOM_UUID_HERE')

	if len(parts) > 1:
		new_content = ''
		for section in parts[:-1]:
			new_content = new_content + str(uuid4())

		new_content = new_content + parts[-1]

		with open(file_name, 'w') as h:
			h.write(content)


def get_arg_parser():
	parser = argparse.ArgumentParser(description='Manage application')

	parser.add_argument(
		'-f',
		'--force',
		action='store_true',
		dest='force',
		default=False,
		help='Force transformation'
	)

	#parser.add_argument(
		#'-i',
		#'--input',
		#dest='input',
		#default='',
		#type=str,
		#help='Source XML file'
	#)

	#parser.add_argument(
		#'-o',
		#'--output',
		#dest='output',
		#default='',
		#type=str,
		#help='Destination XML file'
	#)

	parser.add_argument(
		'-p',
		'--print-only',
		action='store_true',
		dest='print_only',
		default=False,
		help='Only print files to be transformed, do not transform them'
	)

	#parser.add_argument(
		#'-x',
		#'--xsl',
		#dest='xsl',
		#default='',
		#type=str,
		#help='Transformation XSL file'
	#)

	return parser


if __name__ == '__main__':
	parser = get_arg_parser()
	args = parser.parse_args()

	for paths in find_updated_files(args.force):
		input_file = paths[0]
		error_file = paths[3]

		if args.print_only:
			print(input_file)

		else:
			call_args = get_msxsl_call(*paths[:3])
			#call_args = get_saxon_call(*paths[:3])

			print(' '.join(call_args))

			# Call and store the exit status of the process.
			result = call(call_args)

			# Insert random UUIDs into converted files.
			add_random_uuid_to_file(input_file)

			# Move file to the error folder if an error code was returned.
			if result != 0 and error_file is not None:
				copyfile(input_file, error_file)
