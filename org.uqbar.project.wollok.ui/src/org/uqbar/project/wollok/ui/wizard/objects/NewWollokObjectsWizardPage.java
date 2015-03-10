package org.uqbar.project.wollok.ui.wizard.objects;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;

public class NewWollokObjectsWizardPage extends AbstractNewWollokFileWizardPage {
	public NewWollokObjectsWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.CLASS_OBJECTS_EXTENSION;
		this.initialFileName = "objects." + WollokConstants.CLASS_OBJECTS_EXTENSION;
		this.title = "Creates a new file for Objects and Classes";
		this.description = "This wizard creates a new wollok file for the definition of objects and classes";
	}
}