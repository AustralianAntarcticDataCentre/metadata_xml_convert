# Metadata XML conversion script

This script loops over metadata DIF XML files and converts them to other
XML formats using XSL files.


## Requirements

Paths to required folders are specified in the `settings.py` module.
This can be created by copying and renaming `settings.example.py`.

This script only uses Python 3.4 standard libraries.


## Usage

### Print available XSL files

These are located in the [xsl](./xsl/) folder by default.

	python print_xsl.py

Print each of the XSL transformations that can be performed.


### Convert XML using XSL files

	python convert_files.py

Convert each of the XML files using all of the XSL files.


#### Convert using a single XSL

You can specify a single XSL to use with `-x`:

	python convert_files.py -x 1

This only uses the first XSL for conversions.

The number is the one-based index from `python print_xsl.py`.


### Delete old files

	python delete_old_converts.py

Deletes any converted files that do not have a matching source file.

If a metadata record is deleted, then this will remove any conversions
that have been made from it.

## Automation

### Cron job
	
	crontab -e

	1 * * * * source /home/docker-data/aadc-metadata-conversion/git/deployment/deploy.sh >> /var/log/cronjobs/aadc-metadata-conversion.log 2>&1

## Notes

This script has been built to solve a specific task.E

The goal was not to create a tool that would be integrated with others,
but hopefully this may still be possible in the future (if necessary).

Docstrings follow the [NumPy documentation conventions][1].

[1]: https://github.com/numpy/numpy/blob/master/doc/HOWTO_DOCUMENT.rst.txt
