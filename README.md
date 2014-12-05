# Metadata XML conversion script

This script loops over metadata DIF XML files and converts them to other
XML formats using XSL files.

The paths to where all required files are found is specified in the
`settings.py` module.
This should be created by copying and renaming `settings.py.example`.

This script only uses Python 3.4 standard libraries.


## Usage

### Print XSL

	python print_xsl.py

Print each of the XSL transformations that can be performed.


### Convert XML

	python convert_files.py

Convert each of the XML files using all of the XSL files.


### Delete old files

	python delete_old_converts.py

Deletes any converted files that do not have a matching source file.

If a metadata record is deleted, then this will remove any conversions
that have been made from it.


## Goals

This script has been built to solve a specific task.

The goal was not to create a tool that would be integrated with others,
but hopefully this may still be possible in the future (if necessary).

Docstrings follow the [NumPy documentation conventions][1].

[1]: https://github.com/numpy/numpy/blob/master/doc/HOWTO_DOCUMENT.rst.txt
