package org.uqbar.project.wollok.ui.wizard

import org.eclipse.ui.dialogs.WizardNewProjectCreationPage
import static extension org.uqbar.project.wollok.validation.ElementNameValidation.*

class WollokDslNewProjectCreationPage extends WizardNewProjectCreationPage {

	new(String pageName) {
		super(pageName)
	}

	override protected validatePage() {
		val result = super.validatePage()
		if(!result) return false
		
		val String projectFieldContents = projectName
		val validation = projectFieldContents.validateName
		if (!validation.ok) {
			setErrorMessage(validation.message)
			return false
		}
		return true
	}

}
