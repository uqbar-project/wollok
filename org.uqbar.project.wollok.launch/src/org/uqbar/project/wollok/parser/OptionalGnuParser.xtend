package org.uqbar.project.wollok.parser

import org.apache.commons.cli.GnuParser
import java.util.ListIterator
import org.apache.commons.cli.ParseException

/**
 * https://stackoverflow.com/questions/6049470/can-apache-commons-cli-options-parser-ignore-unknown-command-line-options
 * 
 * GnuParser fails if an option is not present. This is annoying when dealing with "optional options"
 * 
 */
class OptionalGnuParser extends GnuParser {
	
	override protected processOption(String optionName, ListIterator it) throws ParseException {
		try {
			super.processOption(optionName, it)
		} catch (ParseException e) {
			// nothing as we want to be able to parse all options - present or not
		}
	}
	
}