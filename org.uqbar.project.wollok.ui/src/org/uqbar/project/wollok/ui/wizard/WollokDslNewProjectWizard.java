package org.uqbar.project.wollok.ui.wizard;

import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
import org.eclipse.xtext.ui.wizard.IProjectCreator;
import org.eclipse.xtext.ui.wizard.IProjectInfo;
import org.uqbar.project.wollok.ui.Messages;
import org.uqbar.project.wollok.ui.WollokActivator;

import com.google.inject.Inject;

public class WollokDslNewProjectWizard extends org.eclipse.xtext.ui.wizard.XtextNewProjectWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.WollokDslNewProjectWizard"; //$NON-NLS-1$
	
	private WizardNewProjectCreationPage mainPage;

	@Inject
	public WollokDslNewProjectWizard(IProjectCreator projectCreator) {
		super(projectCreator);
		setWindowTitle(Messages.WollokDslNewProjectWizard_windowTitle);
		setDefaultPageImageDescriptor(WollokActivator.getInstance().getImageDescriptor("icons/wollok-logo.iconset/icon_64x64.png")); //$NON-NLS-1$
	}

	/**
	 * Use this method to add pages to the wizard.
	 * The one-time generated version of this class will add a default new project page to the wizard.
	 */
	public void addPages() {
		mainPage = new WollokDslNewProjectCreationPage("basicNewProjectPage"); //$NON-NLS-1$
		mainPage.setTitle(Messages.WollokDslNewProjectWizard_pageTitle);
		mainPage.setDescription(Messages.WollokDslNewProjectWizard_pageDescription);
		addPage(mainPage);
	}

	/**
	 * Use this method to read the project settings from the wizard pages and feed them into the project info class.
	 */
	@Override
	protected IProjectInfo getProjectInfo() {
		org.uqbar.project.wollok.ui.wizard.WollokDslProjectInfo projectInfo = new org.uqbar.project.wollok.ui.wizard.WollokDslProjectInfo();
		projectInfo.setProjectName(mainPage.getProjectName());
		if(!mainPage.useDefaults()) projectInfo.setLocationPath(mainPage.getLocationPath());
		return projectInfo;
	}

}
