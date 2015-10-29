package org.uqbar.wollok.teamwork.ui;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;

import uqbarpropertypagecontrib.DynamicPropertyPage;

public class TeamworkPage extends DynamicPropertyPage implements IWizardPage {

	private IWizard wizard;
	private IWizardPage previusPage;
	private IProject project;

	public TeamworkPage() {
		this.noDefaultAndApplyButton();
	}
	
	@Override
	public boolean canFlipToNextPage() {
		return false;
	}

	@Override
	public String getName() {
		return "TeamWorkPage";
	}

	@Override
	public IWizardPage getNextPage() {
		return null;
	}

	@Override
	public IWizardPage getPreviousPage() {
		return previusPage;
	}

	@Override
	public IWizard getWizard() {
		return wizard;
	}

	@Override
	public boolean isPageComplete() {
		return true;
	}

	@Override
	public void setPreviousPage(IWizardPage arg0) {
		previusPage = arg0;
	}

	@Override
	public void setWizard(IWizard arg0) {
		this.wizard = arg0;
	}

	@Override
	protected String getPluginId() {
		return Activator.PLUGIN_ID;
	}

	public IProject getProject() {
		return project;
	}

	public void setProject(IProject project) {
		this.project = project;
	}

	/**
	 * Create preference for project scope. Override it if you want other scope
	 * */
	protected IScopeContext buildScopeContext() {
		return new ProjectScope(this.project);
	}


}
