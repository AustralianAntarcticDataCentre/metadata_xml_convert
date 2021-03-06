def check_ands_rif_cs(file_path):
	folder_path, file_name = os.path.split(file_path)
	base_name, ext_name = os.path.splitext(file_name)
	return not base_name.endswith('AAD_RIFCS_ISO')


def check_iso_mcp(input_file):
	"""
	Checks if MCP conversion is allowed for the given file.

	MCP files are only created if the DIF has an ISO Topic Category of
	"OCEANS".

	Also makes sure the record is not private.
	"""

	allowed = False

	# Cannot use the following check:
	# oceans_tag = '<ISO_Topic_Category>OCEANS</ISO_Topic_Category>'
	# This is because some of these tags include a "uuid" attribute, so they
	# will not be marked OK for conversion.
	oceans_tag = '>OCEANS</ISO_Topic_Category>'

	private_tag = '<Private>TRUE</Private>'

	with open(input_file) as r:
		content = r.read()

		if 0 <= content.find(oceans_tag):
			allowed = True

		if 0 <= content.find(private_tag):
			allowed = False

	return allowed


def check_not_private(input_file):
	"""
	Check file does not include the Private tag.
	"""

	allowed = True
	private_tag = '<Private>TRUE</Private>'

	with open(input_file) as r:
		content = r.read()
		if 0 <= content.find(private_tag):
			allowed = False

	return allowed
