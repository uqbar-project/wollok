package org.uqbar.wollok.teamwork.ui;

import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Composite;
import org.uqbar.wollok.teamwork.extensions.TeamworkConfigurator;

public class TeamworkPage extends WizardPage implements IWizardPage {

	private IProject project;
	
	private List<TeamworkConfigurator> extensions;
	private String[] configuratorNames;
	

	public TeamworkPage(IProject project, SharingWizard wizard, List<TeamworkConfigurator> extensions) {
		super("Teamwork Repository selection");
		this.project = project;
		this.setWizard(wizard);
		this.extensions = extensions;
		configuratorNames = new String[extensions.size()];
		int i = 0;
		for(TeamworkConfigurator configurator : extensions) {
			configuratorNames[i++] = configurator.getName();
		}
		this.setPageComplete(false);
		this.setDescription("Choose a Backend Platform");
	}
	
	@Override
	public boolean canFlipToNextPage() {
		return getCurrentConfigurator() != null;
	}
	
	@Override
	public IWizardPage getNextPage() {
		return getCurrentConfigurator()!= null ? getCurrentConfigurator().getWizardPages().get(0) : null;
	}

	public SharingWizard getSharingWizard() {
		return (SharingWizard) getWizard();
	}


	@Override
	public void setWizard(IWizard arg0) {
		super.setWizard(arg0);
	}

	public IProject getProject() {
		return project;
	}

	
	@Override
	public void createControl(Composite parent) {
		org.eclipse.swt.widgets.List combo = new org.eclipse.swt.widgets.List(parent, SWT.SINGLE);
		combo.setItems(configuratorNames);
		combo.addSelectionListener(new SelectionListener() {
			
			@Override
			public void widgetSelected(SelectionEvent arg0) {
				
				setCurrentConfigurator(combo.getSelectionIndex() >= 0 ? extensions.get(combo.getSelectionIndex()) : null);
				TeamworkPage.this.getWizard().getContainer().updateButtons();
				
			}
			
			@Override
			public void widgetDefaultSelected(SelectionEvent arg0) {
				widgetSelected(arg0);
			}
		});
		this.setControl(combo);
	}


	public TeamworkConfigurator getCurrentConfigurator() {
		return this.getSharingWizard().getCurrentConfigurator();
	}


	public void setCurrentConfigurator(TeamworkConfigurator currentConfigurator) {
		this.getSharingWizard().setCurrentConfigurator(currentConfigurator);
	}
	
	


}
