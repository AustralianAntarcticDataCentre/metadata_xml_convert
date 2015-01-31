import argparse
import logging
import os

from file_checks import get_files_in_folder, get_input_path
from settings import CONVERSIONS, LOGGING_KWARGS, OUTPUT_PATH


logger = logging.getLogger(__name__)


def get_arg_parser():
	"""
	Return an argument parser for this script.

	Does not include any subparsers.


	Returns
	-------

	argparse.ArgumentParser
		Argument parser that has the `parse_args()` statement.
	"""

	parser = argparse.ArgumentParser(description='Delete conversions.')

	parser.add_argument(
		'-f',
		'--force',
		action='store_true',
		dest='force',
		default=False,
		help='Force deletion of converted files.'
	)

	return parser


def main(args):
	full_deletion_count = 0

	# Loop each conversion type, getting the folder name.
	for xsl_file_name, output_folder, checker in CONVERSIONS:
		# Get the conversion output folder.
		output_path = os.path.join(OUTPUT_PATH, output_folder)

		# Skip this conversion type if the folder does not exist.
		if not os.path.exists(output_path):
			logger.debug('Skipping %s', output_path)
			continue

		# Loop the converted XML files in the output folder.
		logger.debug('Loop XML in %s', output_path)

		deletion_count = 0

		# Loop the XML files in the conversion output folder.
		for output_file_path in get_files_in_folder(output_path, '.xml'):
			if not args.force:
				# Get the input file path from the output file path.
				input_file_path = get_input_path(output_file_path)

				# Skip deletion if the original file exists.
				if os.path.exists(input_file_path):
					continue

			logger.info('Deleting %s', output_file_path)

			deletion_count += 1
			full_deletion_count += 1

			# Remove the converted file.
			os.remove(output_file_path)

		logger.info('Deleted %s files in "%s".', deletion_count, output_folder)

	logger.info('Deleted %s files in total.', full_deletion_count)


if '__main__' == __name__:
	logging.basicConfig(**LOGGING_KWARGS)

	logger.debug('File checking started.')

	parser = get_arg_parser()
	args = parser.parse_args()

	main(args)

	logger.debug('File checking complete.')
