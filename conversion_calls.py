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
