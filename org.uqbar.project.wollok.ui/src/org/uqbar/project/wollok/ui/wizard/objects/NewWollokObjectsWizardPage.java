package org.uqbar.project.wollok.ui.wizard.objects;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.Messages;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;

/**
 * 
 * @author tesonep
 */
public class NewWollokObjectsWizardPage extends AbstractNewWollokFileWizardPage {
	public NewWollokObjectsWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.CLASS_OBJECTS_EXTENSION;
		this.initialFileName = "objects." + WollokConstants.CLASS_OBJECTS_EXTENSION; //$NON-NLS-1$
		this.title = Messages.NewWollokObjectsWizardPage_title;
		this.description = Messages.NewWollokObjectsWizardPage_description;
	}
}