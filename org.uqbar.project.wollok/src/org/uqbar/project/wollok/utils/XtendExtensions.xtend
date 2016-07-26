package org.uqbar.project.wollok.utils

/**
 * Our extensions to basic Java/XTend classes
 */
class XtendExtensions {
	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }
}