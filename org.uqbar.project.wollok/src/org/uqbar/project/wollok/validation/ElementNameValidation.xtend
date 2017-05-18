package org.uqbar.project.wollok.validation

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages

class ElementNameValidation {
	
	static char[] INVALID_RESOURCE_CHARACTERS = #{' ', '-', ',', '*', '\'', '\\', '/', '&', '¿', '?', '{', '}', '[', ']', '(', ')', '=', '>', '<', ':', ';', '%', '!', '¡', '|', '°', '"', '#', '$', '+', '^', '@' }
	
	static def Validation validateName(String name) {
		if (name == null || name.length == 0) {
			return Validation.ok
		}
		
		try {
			new Integer("" + name.charAt(0))
			return Validation.invalid(Messages.ElementNameValidation_NameShouldBeAlphabetic)
		} catch (NumberFormatException e) {
			// ok
		}
		
		if (name.matches("-?\\d+(\\.\\d+)?")) {
			return Validation.invalid(Messages.ElementNameValidation_NameShouldBeAlphabetic)
		}
		
		/* test invalid characters */
		val char[] chars = INVALID_RESOURCE_CHARACTERS
		for (var int i = 0; i < chars.length; i++) {
			if (name.indexOf(chars.get(i)) != -1) {
				return Validation.invalid(NLS.bind(Messages.ElementNameValidation_InvalidCharacterInName, String.valueOf(chars.get(i)), name))
			}
		}
		return Validation.ok
	}
	
	static def String asInvalidCharacterMessage(String s){
		NLS.bind(Messages.ElementNameValidation_InvalidCharacterInName, s)
	}

}