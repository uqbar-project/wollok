package org.uqbar.wollok.teamwork.extensions;

import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.ui.IWorkbench;

public interface TeamworkConfigurator {

	
	public String getName();
	
	/**This method can be called many times */
	public List<IWizardPage> getWizardPages();
	
	public void init(IProject project, IWorkbench workbench, IWizard wizard);
	
	public void configure();

	public boolean configureEnabled();
	

}
