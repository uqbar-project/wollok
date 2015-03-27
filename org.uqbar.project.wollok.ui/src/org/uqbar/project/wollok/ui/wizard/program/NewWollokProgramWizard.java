package org.uqbar.project.wollok.ui.wizard.program;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import org.eclipse.ui.INewWizard;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizard;

/**
 * New Wollok Program wizard
 * 
 * @author jfernandes
 */
public class NewWollokProgramWizard extends AbstractNewWollokFileWizard implements INewWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.program.NewWollokProgramWizard";
	
	public void addPages() {
		page = new NewWollokProgramWizardPage(selection);
		addPage(page);
	}
	
	@Override
	protected InputStream openContentStream() {
		String contents =
			"\nprogram abc {\n\n\tthis.println('Hello Wollok')\n\n}";
		return new ByteArrayInputStream(contents.getBytes());
	}
}