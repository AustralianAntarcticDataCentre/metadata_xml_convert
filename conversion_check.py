def check_iso_mcp(input_file):
	"""
	Checks if MCP conversion is allowed for the given file.

	MCP files are only created if the DIF has an ISO Topic Category of
	"OCEANS".
	"""

	allowed = False
	oceans_tag = '<ISO_Topic_Category>OCEANS</ISO_Topic_Category>'

	with open(input_file) as r:
		content = r.read()
		if 0 <= content.find(oceans_tag):
			allowed = True

	return allowed
