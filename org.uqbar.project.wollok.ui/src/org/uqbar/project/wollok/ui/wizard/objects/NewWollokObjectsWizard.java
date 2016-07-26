package org.uqbar.project.wollok.ui.wizard.objects;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import org.eclipse.ui.INewWizard;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizard;

/**
 * New Wollok Objects and Classes Wizard
 * 
 * @author tesonep
 */
public class NewWollokObjectsWizard extends AbstractNewWollokFileWizard implements INewWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.objects.NewWollokObjectsWizard";
	
	public void addPages() {
		page = new NewWollokObjectsWizardPage(selection);
		addPage(page);
	}
	
	@Override
	protected InputStream openContentStream() {
		String contents =
			System.lineSeparator() + 
			"object abc {" + 
					System.lineSeparator() + 
					System.lineSeparator() + 
					System.lineSeparator() + 
					System.lineSeparator() + 
			"}";
		return new ByteArrayInputStream(contents.getBytes());
	}
}