"""
Convert metadata using XSL files.


Links
-----

- https://docs.python.org/3/library/io.html

- https://docs.python.org/3/library/subprocess.html
"""

import argparse
import logging
import os
from subprocess import call
from uuid import uuid4

from conversion_calls import get_conversions, get_msxsl_call, get_saxon_call
from file_checks import append_folder_to_file_name, find_updated_files
from settings import CONVERSIONS, LOGGING_KWARGS


logger = logging.getLogger(__name__)


def add_random_uuid_to_file(file_name):
	"""
	Insert UUIDs into the given file.

	Replace each instance of `INSERT_RANDOM_UUID_HERE` with a UUID.


	Parameters
	----------

	file_name : str
		Path to file to be modified.


	Returns
	-------

	None
	"""

	with open(file_name) as h:
		content = h.read()

	parts = content.split('INSERT_RANDOM_UUID_HERE')

	# Make sure the insert statement appears at least once.
	if len(parts) > 1:
		new_content = ''

		# Loop each section that wraps the insert UUID text.
		# Loop continues until the second last section.
		for section in parts[:-1]:
			# Add section and UUID to new content text.
			new_content = new_content + section + str(uuid4())

		# Add the last section of content.
		new_content = new_content + parts[-1]

		# Save the new content back to the original file.
		with open(file_name, 'w') as h:
			h.write(new_content)


def get_arg_parser():
	"""
	Return an argument parser for this script.

	Does not include any subparsers.


	Returns
	-------

	argparse.ArgumentParser
		Argument parser that has the `parse_args()` statement.
	"""

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

	parser.add_argument(
		'-x',
		'--xsl',
		dest='xsl',
		default=0,
		type=int,
		help='Index of XSL transform to use.'
	)

	return parser


def convert_files(args):
	"""
	Loop each of the XML files and apply the XSL transforms to them.


	Parameters
	----------

	args : argparse.Namespace
		Class containing arguments from `argparse.ArgumentParser`.


	Returns
	-------

	None
	"""

	conversions = get_conversions(args.xsl - 1)

	# Loop over each of the files to be converted.
	for paths in find_updated_files(args.force, conversions):
		# Get the XSL transform command to be run.
		#call_args, has_output = get_msxsl_call(*paths[:3])
		call_args, has_output = get_saxon_call(*paths[:3])

		# Store the call as a string for debugging and printing.
		call_args_str = ' '.join(call_args)

		# If requested, print the command then skip to the next.
		if args.print_only:
			print(call_args_str)
			continue

		# Log the XSL command to be run.
		logger.debug(call_args_str)


		if has_output:
			# check_output will raise CalledProcessError if the call fails.
			output = check_output(call_args, universal_newlines=True)

			result = 0

		else:
			# Call and store the exit status of the XSL command.
			result = call(call_args)

			output = ''


		input_file = paths[0]
		output_file = paths[2]
		error_file = paths[3]


		if output != '':
			with open(output_file, 'w') as w:
				w.write(output)

		# Make sure the new (converted) file was created.
		if not os.path.exists(output_file):
			logger.error('Output file was not created at %s.', output_file)
			continue


		# Move file to the error folder if an error code was returned.
		if result != 0:
			logger.error('Conversion failed for %s.', input_file)

			if error_file is not None:
				# If an output file was created, move it to the error folder.
				if os.path.exists(output_file):
					logger.error('Moving output file to %s.', error_file)

					# Rename/move the output file to an error file.
					os.rename(output_file, error_file)

			# Skip to the next file after a conversion failure.
			continue

		# Insert random UUIDs into converted files.
		add_random_uuid_to_file(output_file)

		# Ensure last modified time is newer than the input file.
		os.utime(output_file, None)


if '__main__' == __name__:
	logging.basicConfig(**LOGGING_KWARGS)

	parser = get_arg_parser()
	args = parser.parse_args()

	convert_files(args)
