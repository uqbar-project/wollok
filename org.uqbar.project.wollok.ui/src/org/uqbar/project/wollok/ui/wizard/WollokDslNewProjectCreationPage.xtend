package org.uqbar.project.wollok.ui.wizard

import org.eclipse.core.resources.IResource
import org.eclipse.osgi.util.NLS
import org.eclipse.ui.dialogs.WizardNewProjectCreationPage
import org.eclipse.xtend.lib.annotations.Data
import org.uqbar.project.wollok.ui.Messages

class WollokDslNewProjectCreationPage extends WizardNewProjectCreationPage {

	char[] INVALID_RESOURCE_CHARACTERS = #{' ', '-', '*', '\'', '\\', '/', '&', '¿', '?', '{', '}', '[', ']', '(', ')', '=', '>', '<', ':', ';', '%', '!', '¡', '|', '°', '"', '#', '$', '+', '^', '@' }
 
	new(String pageName) {
		super(pageName)
	}

	override protected validatePage() {
		val result = super.validatePage()
		if(!result) return false
		
		val String projectFieldContents = projectName
		val validation = validateName(projectFieldContents, IResource.PROJECT)
		if (!validation.ok) {
			setErrorMessage(validation.message)
			return false
		}
		return true
	}
	
	def Validation validateName(String projectName, int type) {
		/* test invalid characters */
		val char[] chars = INVALID_RESOURCE_CHARACTERS
		for (var int i = 0; i < chars.length; i++) {
			if (projectName.indexOf(chars.get(i)) != -1) {
				return Validation.invalid(NLS.bind(Messages.WollokDslNewProjectWizard_invalidChar, String.valueOf(chars.get(i)), projectName))
			}
		}
		return Validation.ok
	}

}

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