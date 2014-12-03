import argparse
import logging
import os
from subprocess import call
from uuid import uuid4

from conversion_calls import get_msxsl_call
from file_checks import append_folder_to_file_name, find_updated_files


logger = logging.getLogger(__name__)


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

	#parser.add_argument(
		#'-x',
		#'--xsl',
		#dest='xsl',
		#default='',
		#type=str,
		#help='Transformation XSL file'
	#)

	return parser


def main():
	parser = get_arg_parser()
	args = parser.parse_args()

	for paths in find_updated_files(args.force):
		input_file = paths[0]
		logger.debug('Input: %s', input_file)

		if args.print_only:
			print(input_file)

		else:
			output_file = paths[2]
			error_file = paths[3]

			call_args = get_msxsl_call(*paths[:3])
			#call_args = get_saxon_call(*paths[:3])

			logger.debug(' '.join(call_args))

			# Call and store the exit status of the process.
			result = call(call_args)

			# Move file to the error folder if an error code was returned.
			if result != 0 and error_file is not None:
				os.rename(input_file, error_file)
				logger.error('Conversion failed. Moving file to %s', error_file)

			else:
				# Insert random UUIDs into converted files.
				add_random_uuid_to_file(output_file)

				# Insert the parent folder name into the file name.
				new_output_file = append_folder_to_file_name(output_file)
				logger.info('Created: %s', new_output_file)

				# Delete the converted file if it already exists.
				if os.path.exists(new_output_file):
					os.remove(new_output_file)

				os.rename(output_file, new_output_file)

				# Ensure last modified time is older than the output file.
				os.utime(input_file, None)


if '__main__' == __name__:
	logging.basicConfig(level=logging.DEBUG)

	main()
