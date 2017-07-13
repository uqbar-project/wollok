package org.uqbar.project.wollok.ui.wizard.tests

import org.eclipse.jface.viewers.IStructuredSelection
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage

class NewWollokTestWizardPage extends AbstractNewWollokFileWizardPage {
	new(IStructuredSelection selection) {
		super(selection)
	}

	override doInit(){
		this.extension = testExtension
		this.initialFileName = "test." + testExtension //$NON-NLS-1$
		this.title = Messages.NewWollokTestWizardPage_title
		this.description = Messages.NewWollokTestWizardPage_description
	}
	
	public def String testExtension() {
		WollokConstants.TEST_EXTENSION
	}
}

class NewWollokDescribeWizardPage extends NewWollokTestWizardPage {
	new(IStructuredSelection selection) {
		super(selection)
	}

	override doInit(){
		this.extension = testExtension
		this.initialFileName = "describe." + testExtension //$NON-NLS-1$
		this.title = Messages.NewWollokDescribeWizardPage_title
		this.description = Messages.NewWollokDescribeWizardPage_description
	}
}