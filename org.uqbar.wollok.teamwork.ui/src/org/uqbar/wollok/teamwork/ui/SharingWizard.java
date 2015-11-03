
package org.uqbar.wollok.teamwork.ui;
import java.net.URL;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.dialogs.DialogSettings;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.team.core.RepositoryProvider;
import org.eclipse.team.core.TeamException;
import org.eclipse.team.ui.IConfigurationWizard;
import org.eclipse.ui.IWorkbench;
import org.uqbar.wollok.teamwork.extensions.TeamworkConfigurator;

import extensions.ExtensionManager;

public class SharingWizard extends Wizard implements IConfigurationWizard{

	private static final String SECTION_NAME = "teamwork";
	private static final String SHARING_WIZARD = "RepositoryConfigurator";
	private IProject project;
	private IWorkbench workbench;
	private List<TeamworkConfigurator> extensions;
	private TeamworkConfigurator currentConfigurator;

	@Override
	public void init(IWorkbench workbench , IProject project) {
		this.workbench = workbench;
		this.setProject(project);
	    this.setHelpAvailable(false);
	    this.setDefaultPageImageDescriptor(ImageDescriptor.createFromURL(getIconUrl()));
	    this.setDialogSettings(new DialogSettings(SECTION_NAME));
	    this.setNeedsProgressMonitor(false);
	    this.setTitleBarColor(Activator.DefaulColor);
	    this.setWindowTitle("Wollok Teamwork");
	    extensions = new ExtensionManager<TeamworkConfigurator>(Activator.PLUGIN_ID, SHARING_WIZARD, "class").getExtensions();
	    
	    
	    if(extensions.isEmpty()) {
	    	throw new RuntimeException("Teamwork Implementation does not exist");
	    }
	    
	    if(extensions.size() > 1) {
	    	this.addPage(createTeamWorkPage(extensions));
	    	this.setForcePreviousAndNextButtons(true);
	    	
	    }
	    else {
	    	this.setCurrentConfigurator(extensions.get(0));
	    }
	    
	    for(TeamworkConfigurator configurator : extensions) {
	    	configurator.init(project, workbench, this);
	    	for(IWizardPage page: configurator.getWizardPages()) {
	    	//	this.addPage(page);
	    		page.setWizard(this);
	    	}
	    } 
	}
	
	
	public IWorkbench getWorkbench() {
		return workbench;
	}
	
	protected IWizardPage createTeamWorkPage(List<TeamworkConfigurator> extensions) {
		return new TeamworkPage(this.getProject(), this, extensions);
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
			this.getCurrentConfigurator().configure();
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

	public TeamworkConfigurator getCurrentConfigurator() {
		return currentConfigurator;
	}

	public void setCurrentConfigurator(TeamworkConfigurator currentConfigurator) {
		this.currentConfigurator = currentConfigurator;
	}
	
	@Override
	public boolean canFinish() {
		return this.getCurrentConfigurator() != null && this.getCurrentConfigurator().configureEnabled();
	}
	
}
