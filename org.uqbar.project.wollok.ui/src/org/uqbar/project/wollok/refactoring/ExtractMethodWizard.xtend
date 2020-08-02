package org.uqbar.project.wollok.refactoring

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.ltk.core.refactoring.Refactoring
import org.eclipse.ltk.ui.refactoring.RefactoringWizard
import org.uqbar.project.wollok.ui.Messages

/**
 * 
 * @author jfernandes 
 */
class ExtractMethodWizard extends RefactoringWizard {
	ExtractMethodUserInputPage userInputPage

	static class Factory {
		@Inject
		Provider<ExtractMethodUserInputPage> inputPageProvider
		
		def create(Refactoring refactoring) {
			new ExtractMethodWizard(refactoring, inputPageProvider.get)
		}
	}

	new(Refactoring refactoring, ExtractMethodUserInputPage userInputPage) {
		super(refactoring, RefactoringWizard.DIALOG_BASED_USER_INTERFACE)
		this.userInputPage = userInputPage;
	}
	
	override getWindowTitle() { Messages.ExtractMethodUserInputPage_extractMethodTitle }

	override addUserInputPages() {
		userInputPage.setRefactoring(refactoring as ExtractMethodRefactoring)
		addPage(userInputPage)
	}
	
}