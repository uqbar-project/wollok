package org.uqbar.wollok.teamwork.git;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbench;
import org.uqbar.wollok.teamwork.extensions.TeamworkConfigurator;

public class DummyRespositoryConfigurator implements TeamworkConfigurator{

	private List<IWizardPage> pages = new ArrayList<IWizardPage>();
	private IProject project;
	private IWizard wizard;
	private IWorkbench workbench;
	@Override
	public String getName() {
		return "Wollok over nothing";
	}

	@Override
	public List<IWizardPage> getWizardPages() {
		return pages;
	}

	@Override
	public void init(IProject project, IWorkbench workbench, IWizard wizard) {
		this.project = project;
		this.workbench = workbench;
		this.wizard = wizard;
		
		this.pages.add(new WizardPage("Wollok over nothing Page") {
			
			@Override
			public void createControl(Composite arg0) {
				
				Label label = new Label(arg0, SWT.NONE);
				label.setText("Hola Nada");
				
				
				this.setControl(label);
			}
			
			
		});
		
	}

	@Override
	public void configure() {
		System.out.println("configurando el proyecto sobre la nada misma");
	}

	@Override
	public boolean configureEnabled() {
		return true;
	}

}
