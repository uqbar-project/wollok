package org.uqbar.project.wollok.validation

import org.eclipse.xtend.lib.annotations.Data

@Data
class Validation {
	
	public static boolean OK = true
	public static boolean INVALID = false
	
	boolean ok
	String message
	
	static def Validation invalid(String message) {
		new Validation(INVALID, message)
	}
	
	static def Validation ok() {
		new Validation(OK, null)
	}
}