from settings import CONVERSIONS


def get_conversions(index):
	"""
	Get the list of conversions to be performed.

	Defaults to doing all XSL conversions for all the files.


	Parameters
	----------

	index : int
		Index of conversion to be used.
		Incorrect index will use default (all conversions).


	Returns
	-------

	list of tuples
		List of conversion detail tuples.
	"""

	if 0 <= index and index < len(CONVERSIONS):
		return [CONVERSIONS[index],]

	# Default to all conversions.
	return CONVERSIONS


def get_msxsl_call(input_file, transform_file, output_file):
	return ('msxsl.exe', input_file, transform_file, '-o', output_file), False


def get_saxon_call(input_file, transform_file, output_file):
	#return ('java', '-jar', 'saxon9.jar', input_file, transform_file), True
	return (
		'java',
		'-jar',
		'saxon9.jar',
		'-s:' + input_file,
		'-xsl:' + transform_file,
		'-o:' + output_file
	), False
