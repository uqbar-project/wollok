package org.uqbar.project.wollok.ui.wizard.program;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.Messages;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;

public class NewWollokProgramWizardPage extends AbstractNewWollokFileWizardPage {
	public NewWollokProgramWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.PROGRAM_EXTENSION;
		this.initialFileName = "program." + WollokConstants.PROGRAM_EXTENSION; //$NON-NLS-1$
		this.title = Messages.NewWollokProgramWizardPage_title;
		this.description = Messages.NewWollokProgramWizardPage_description + this.extension + "."; //$NON-NLS-2$
	}
}