package org.uqbar.project.wollok.utils

import java.util.List
import java.util.Random

/**
 * Our extensions to basic Java/XTend classes
 */
class XtendExtensions {
	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }
	
	/**
	 * Returns an random element  
	 */
	static def random(List<Integer> it) {
		val index = new Random().nextInt(size)
		get(index)
	}
}