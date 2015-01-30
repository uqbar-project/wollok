package org.uqbar.project.wollok.ui.wizard;

import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
import org.eclipse.xtext.ui.wizard.IProjectInfo;
import org.eclipse.xtext.ui.wizard.IProjectCreator;
import org.uqbar.project.wollok.ui.WollokActivator;

import com.google.inject.Inject;

public class WollokDslNewProjectWizard extends org.eclipse.xtext.ui.wizard.XtextNewProjectWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.WollokDslNewProjectWizard";
	
	private WizardNewProjectCreationPage mainPage;

	@Inject
	public WollokDslNewProjectWizard(IProjectCreator projectCreator) {
		super(projectCreator);
		setWindowTitle("New WollokDsl Project");
		setDefaultPageImageDescriptor(WollokActivator.getInstance().getImageDescriptor("icons/wollok-logo-64.fw.png"));
	}

	/**
	 * Use this method to add pages to the wizard.
	 * The one-time generated version of this class will add a default new project page to the wizard.
	 */
	public void addPages() {
		mainPage = new WizardNewProjectCreationPage("basicNewProjectPage");
		mainPage.setTitle("WollokDsl Project");
		mainPage.setDescription("Create a new WollokDsl project.");
		addPage(mainPage);
	}

	/**
	 * Use this method to read the project settings from the wizard pages and feed them into the project info class.
	 */
	@Override
	protected IProjectInfo getProjectInfo() {
		org.uqbar.project.wollok.ui.wizard.WollokDslProjectInfo projectInfo = new org.uqbar.project.wollok.ui.wizard.WollokDslProjectInfo();
		projectInfo.setProjectName(mainPage.getProjectName());
		return projectInfo;
	}

}
