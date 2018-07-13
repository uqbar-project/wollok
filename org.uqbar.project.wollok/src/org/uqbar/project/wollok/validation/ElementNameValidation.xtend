package org.uqbar.project.wollok.validation

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import com.google.common.base.CharMatcher

class ElementNameValidation {
	
	public static char[] INVALID_RESOURCE_CHARACTERS = #{' ', '-', ',', '*', '\'', '\\', '/', '&', '¿', '?', '{', '}', '[', ']', '(', ')', '=', '>', '<', ':', ';', '%', '!', '¡', '|', '°', '"', '#', '$', '+', '^', '@' }
	
	static def Validation validateName(String name) {
		if (name === null || name.length == 0) {
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
			val currentChar = chars.get(i)
			if (name.indexOf(currentChar) != -1) { 
				return Validation.invalid(NLS.bind(Messages.ElementNameValidation_InvalidCharacterInName, String.valueOf(currentChar), name))
			}
		}
		
		for (var int i = 0; i < name.length; i++) {
			val currentChar = name.charAt(i)
			if (Character.UnicodeBlock.of(currentChar) != Character.UnicodeBlock.BASIC_LATIN) {
				return Validation.invalid(NLS.bind(Messages.ElementNameValidation_InvalidCharacterInName, String.valueOf(currentChar), name))
			}
		}
		
		return Validation.ok
	}
	
	static def String asInvalidCharacterMessage(String s){
		NLS.bind(Messages.ElementNameValidation_InvalidCharacterInName, s)
	}

}