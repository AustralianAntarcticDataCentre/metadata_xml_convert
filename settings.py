import logging
import os

from conversion_check import check_ands_rif_cs, check_iso_mcp, check_not_private


# Use `file-parent.ext` for converted files.
ADD_FOLDER_TO_FILE_NAME = True

ANDS_XML_START = """
<registryObjects xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
	xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
"""

ANDS_XML_STOP = '</registryObjects>'

# XSL types and where the output files should go.
# Both are relative to the base paths above.
CONVERSIONS = (
	#('ANDS_RIF-CS.xsl', 'ands_rif-cs', check_ands_rif_cs),
	#('ANDS_RIF-CS.xsl', 'ands_rif-cs', check_not_private),
	('DIF-ISO-3.3.xsl', 'iso', check_not_private),
	('DIF-ISO-ANDS-3.3.xsl', 'iso-ands', check_not_private),
	('DIF-ISO-ANZLIC-3.3.xsl', 'iso-anzlic', check_not_private),
	('DIF-ISO-MCP-3.3.xsl', 'iso-mcp', check_iso_mcp),
)

LOGGING_FORMAT = '''
- file: %(pathname)s
  level: %(levelname)s
  line: %(lineno)s
  message: |
    %(message)s
  time: %(asctime)s
'''.strip()

LOGGING_KWARGS = dict(
	format=LOGGING_FORMAT,
	level=logging.DEBUG
)

# Flag to defined if the Saxon parser
USE_SAXSON = True


#
# File paths
#

BASE_PATH = os.environ['BASE_PATH']

ANDS_XML_FILE_NAME = os.environ['ANDS_XML_FILE_NAME']

ANDS_XML_FOLDER_PATH = os.environ['ANDS_XML_FOLDER_PATH']

# Where the DIF XML files can be found.
INPUT_PATH = os.environ['INPUT_PATH']

# Base path of where the converted XML should go.
OUTPUT_PATH = os.environ['OUTPUT_PATH']

# Base path of where the XML conversion files can be found.
XSL_PATH = os.environ['XSL_PATH']



