import argparse
import logging
import os
from subprocess import call
from uuid import uuid4

from conversion_calls import get_msxsl_call
from file_checks import append_folder_to_file_name, find_updated_files
from settings import CONVERSIONS


logger = logging.getLogger(__name__)


def add_random_uuid_to_file(file_name):
	"""
	Insert UUIDs into the given file.

	Replace each instance of `INSERT_RANDOM_UUID_HERE` with a UUID.


	Parameters
	----------

	file_name : str
		Path to file to be modified.
	"""

	with open(file_name) as h:
		content = h.read()

	parts = content.split('INSERT_RANDOM_UUID_HERE')

	if len(parts) > 1:
		new_content = ''
		for section in parts[:-1]:
			new_content = new_content + str(uuid4())

		new_content = new_content + parts[-1]

		with open(file_name, 'w') as h:
			h.write(new_content)


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

	parser.add_argument(
		'-x',
		'--xsl',
		dest='xsl',
		default=-1,
		type=int,
		help='Index of XSL transform to use.'
	)

	return parser


def get_conversions(index):
	"""
	Get the list of conversions to be performed.

	Defaults to doing all XSL conversions for all the files.
	"""

	if 0 <= index and index < len(CONVERSIONS):
		return [CONVERSIONS[index],]

	# Default to all conversions.
	return CONVERSIONS


def main(args):
	conversions = get_conversions(args.xsl)

	# Loop over each of the files to be converted.
	for paths in find_updated_files(args.force, conversions):
		# Get the XSL transform command to be run.
		call_args = get_msxsl_call(*paths[:3])
		#call_args = get_saxon_call(*paths[:3])

		# Store the call as a string for a debug message and printing.
		call_args_str = ' '.join(call_args)

		# Print the command and skip to the next.
		if args.print_only:
			print(call_args_str)
			continue
		else:
			# Log the XSL command to be run.
			logger.debug(call_args_str)

		# Call and store the exit status of the XSL command.
		result = call(call_args)

		input_file = paths[0]
		output_file = paths[2]
		error_file = paths[3]

		# Move file to the error folder if an error code was returned.
		if result != 0 and error_file is not None:
			logger.error('Conversion failed. Moving file to %s', error_file)
			os.rename(output_file, error_file)
			continue

		# Insert random UUIDs into converted files.
		add_random_uuid_to_file(output_file)

		# Insert the parent folder name into the file name.
		# This returns a new file path that the function creates.
		new_output_file = append_folder_to_file_name(output_file)

		# Delete the converted file if it already exists.
		if os.path.exists(new_output_file):
			logger.info('Delete existing %s', new_output_file)
			os.remove(new_output_file)

		logger.info('Created %s', new_output_file)

		os.rename(output_file, new_output_file)

		# Ensure last modified time is older than the output file.
		os.utime(input_file, None)


if '__main__' == __name__:
	logging.basicConfig(level=logging.DEBUG)

	parser = get_arg_parser()
	args = parser.parse_args()

	main(args)
