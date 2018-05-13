package org.uqbar.project.wollok.utils

import java.io.IOException
import java.util.ArrayList
import java.util.List
import java.util.Locale
import java.util.Properties

/**
 * Utility class for i18n.
 * As the default eclipse mechanism was thought to work as statically typed
 * constantes in Messages classes, but many times we want to access it dynamically
 * since we have some small DSL-like API's and stuff
 * 
 * @author jfernandes
 */
class WNLS {
	static val String EXTENSION = ".properties"
	static List<String> nlSuffixes
	
	def static load(String bundleName, Class toGetClassLoader) {
		val loader = toGetClassLoader.classLoader

		val props = buildVariants(bundleName).map [v| 
			// loader==null if we're launched off the Java boot classpath
			val input = if (loader === null) ClassLoader.getSystemResourceAsStream(v) else loader.getResourceAsStream(v)
			if (input !== null) {
				try {
					val properties = new Properties
					properties.load(input);
					properties
				} 
				catch (IOException e) {
					throw new RuntimeException("Error loading i18n file", e)
				} finally {
					if (input !== null)
						try {
							input.close
						} catch (IOException e) {
							// ignore
						}
				}
			}
		]
		
		// jfernandes: I'm using just the first one. I don't think we need the defaulting mechanism.
		//    it would make it more difficult 
		props.findFirst[ it !== null]
	}
	
	/*
	 * Build an array of property files to search.  The returned array contains
	 * the property fields in order from most specific to most generic.
	 * So, in the FR_fr locale, it will return file_fr_FR.properties, then
	 * file_fr.properties, and finally file.properties.
	 */
	def static String[] buildVariants(String root) {
		if (nlSuffixes === null) {
			//build list of suffixes for loading resource bundles
			var nl = Locale.getDefault.toString
			nlSuffixes = new ArrayList<String>(4);
			var int lastSeparator
			var condition = true
			while (condition) {
				nlSuffixes.add('_' + nl + EXTENSION);
				lastSeparator = nl.lastIndexOf('_');
				if (lastSeparator == -1)
					condition = false
				else 
					nl = nl.substring(0, lastSeparator);
			}
			//add the empty suffix last (most general)
			nlSuffixes.add(EXTENSION);
		}
		val rootA = root.replace('.', '/');
		nlSuffixes.map[ rootA + it]
	}
	
	
}