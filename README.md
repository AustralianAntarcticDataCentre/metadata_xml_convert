# Metadata XML conversion script

This script loops over metadata DIF XML files and converts them to other
XML formats using XSL files.

The paths to where all required files are found is specified in the
`settings.py` module.
This should be created by copying and renaming `settings.py.example`.

This script only uses Python 3.4 standard libraries.


## Goals

This script has been built to solve a specific task.

The goal was not to create a tool that would be integrated with others,
but hopefully this may still be possible in the future (if necessary).
