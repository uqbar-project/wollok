package org.uqbar.project.wollok.validation

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.ui.Messages

class ElementNameValidation {
	
	static char[] INVALID_RESOURCE_CHARACTERS = #{' ', '-', '*', '\'', '\\', '/', '&', '¿', '?', '{', '}', '[', ']', '(', ')', '=', '>', '<', ':', ';', '%', '!', '¡', '|', '°', '"', '#', '$', '+', '^', '@' }
	
	static def Validation validateName(String projectName) {
		/* test invalid characters */
		val char[] chars = INVALID_RESOURCE_CHARACTERS
		for (var int i = 0; i < chars.length; i++) {
			if (projectName.indexOf(chars.get(i)) != -1) {
				return Validation.invalid(NLS.bind(Messages.WollokDslNewWizard_invalidChar, String.valueOf(chars.get(i)), projectName))
			}
		}
		return Validation.ok
	}

	
}