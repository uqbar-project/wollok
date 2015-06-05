package org.uqbar.project.wollok.ui.wizard.tests;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.Messages;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;

public class NewWollokTestWizardPage extends AbstractNewWollokFileWizardPage {
	public NewWollokTestWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.TEST_EXTENSION;
		this.initialFileName = "test." + WollokConstants.TEST_EXTENSION; //$NON-NLS-1$
		this.title = Messages.NewWollokTestWizardPage_title;
		this.description = Messages.NewWollokTestWizardPage_description;
	}
}