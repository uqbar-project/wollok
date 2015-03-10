package org.uqbar.project.wollok.ui.wizard.program;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;

public class NewWollokProgramWizardPage extends AbstractNewWollokFileWizardPage {
	public NewWollokProgramWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.PROGRAM_EXTENSION;
		this.initialFileName = "program." + WollokConstants.PROGRAM_EXTENSION;
		this.title = "Creates a new Wollok Program File";
		this.description = "This wizard creates a new wollok program file. The file must have the extension " + this.extension + ".";
	}
}