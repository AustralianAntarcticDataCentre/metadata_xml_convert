import logging
import os

from conversion_check import check_ands_rif_cs, check_iso_mcp


BASE_PATH = os.getcwd()
#BASE_PATH = os.path.normpath(BASE_PATH)


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
	('ANDS_RIF-CS.xsl', 'ands_rif-cs', check_ands_rif_cs),
	('DIF-ISO-3.3.xsl', 'iso', None),
	('DIF-ISO-ANDS-3.3.xsl', 'iso-ands', None),
	('DIF-ISO-ANZLIC-3.3.xsl', 'iso-anzlic', None),
	('DIF-ISO-MCP-3.3.xsl', 'iso-mcp', check_iso_mcp),
)

#- file: %(pathname)s
#  function: %(funcName)s
LOGGING_FORMAT = '''
- level: %(levelname)s
  line: %(lineno)s
  logger: %(name)s
  message: |
    %(message)s
  time: %(asctime)s
'''.strip()

LOGGING_KWARGS = dict(
	fromat=LOGGING_FORMAT,
	level=logging.DEBUG
)


ANDS_XML_FILE_NAME = os.path.join(BASE_PATH, 'AAD_RegistryObjects.xml')

ANDS_XML_FOLDER_PATH = os.path.join(EXPORT_PATH, 'ands_rif-cs')

# Where the DIF XML files can be found.
INPUT_PATH = os.path.join(BASE_PATH, 'input')

# Base path of where the converted XML should go.
OUTPUT_PATH = os.path.join(BASE_PATH, 'output')

# Base path of where the XML conversion files can be found.
XSL_PATH = os.path.join(BASE_PATH, 'xsl')
