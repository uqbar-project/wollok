package org.uqbar.wollok.teamwork.git;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.ui.IWorkbench;
import org.uqbar.wollok.teamwork.extensions.TeamworkConfigurator;

public class GitRespositoryConfigurator implements TeamworkConfigurator {

	private List<IWizardPage> pages = new ArrayList<IWizardPage>();
	private IProject project;
	private IWorkbench workbench;

	private String password;
	private String user;
	private String repositoryString;

	@Override
	public String getName() {
		return "Wollok over Git";
	}

	@Override
	public List<IWizardPage> getWizardPages() {
		return pages;
	}

	@Override
	public void init(IProject project, IWorkbench workbench, IWizard wizard) {
		this.project = project;
		this.workbench = workbench;

		this.pages.add(new GitRepositoryConfiguratorPage(this));

	}

	@Override
	public void configure() {
		System.out.println("configurando el proyecto  " + project.getName() + "sobre git en el repo "
				+ this.repositoryString + " usuario: " + this.user + " usando password: " + (password != null));
	}

	@Override
	public boolean configureEnabled() {
		return this.repositoryString != null && this.user != null;
	}

	public void setRepositoryString(String string) {
		this.repositoryString = string;
		
	}

	public void setUser(String string) {
		this.user = string;
		
	}

	public void setPassword(String string) {
		this.password = string;
		
	}
	

}
