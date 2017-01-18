package org.uqbar.project.wollok.utils

/**
 * 
 * @author jfernandes
 */
class StringUtils {
	
	def static splitCamelCase(String s) {
   		s.replaceAll(
	      String.format("%s|%s|%s",
	         "(?<=[A-Z])(?=[A-Z][a-z])",
	         "(?<=[^A-Z])(?=[A-Z])",
	         "(?<=[A-Za-z])(?=[^A-Za-z])"
	      ),
	      " "
	   )
	}
	def static firstUpper(String s) {
		Character.toUpperCase(s.charAt(0)) + s.substring(1)
	}
	
	
	def static String padRight(String s, int n) {
     return String.format("%1$-" + n + "s", s);  
	}
}