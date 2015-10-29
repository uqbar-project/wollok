
package org.uqbar.wollok.teamwork.ui;
import java.net.URL;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.dialogs.DialogSettings;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.team.core.RepositoryProvider;
import org.eclipse.team.core.TeamException;
import org.eclipse.team.ui.IConfigurationWizard;
import org.eclipse.ui.IWorkbench;

public class SharingWizard extends Wizard implements IConfigurationWizard{

	private static final String SECTION_NAME = "teamwork";
	private IProject project;
	private IWorkbench workbench;


	@Override
	public void init(IWorkbench workbench , IProject project) {
		this.workbench = workbench;
		this.setProject(project);
		
	    this.addPage(createTeamWorkPage());
	    this.setHelpAvailable(false);
	    this.setDefaultPageImageDescriptor(ImageDescriptor.createFromURL(getIconUrl()));
	    this.setDialogSettings(new DialogSettings(SECTION_NAME));
	    this.setNeedsProgressMonitor(false);
	    this.setTitleBarColor(Activator.DefaulColor);
	    this.setWindowTitle("Wollok Teamwork");

		
	}
	
	public IWorkbench getWorkbench() {
		return workbench;
	}
	
	protected TeamworkPage createTeamWorkPage() {
		TeamworkPage teamworkPage = new TeamworkPage();
		teamworkPage.setProject(this.getProject());
		teamworkPage.addString("repo", "Repository Location", "https://");
		teamworkPage.setWizard(this);
		return teamworkPage;
	}

	protected String getIconPath() {
		return Activator.IconPath;
	}

	protected URL getIconUrl() {
		return Platform.getBundle(Activator.PLUGIN_ID).getEntry(getIconPath());
	}

	@Override
	public boolean performFinish() {
		try {
			RepositoryProvider.map(this.getProject(), org.uqbar.wollok.teamwork.RepositoryProvider.getId());
		} catch (TeamException e) {
			throw new RuntimeException(e);
		}
		return true;
	}

	public IProject getProject() {
		return project;
	}

	public void setProject(IProject project) {
		this.project = project;
	}
	
	
}
