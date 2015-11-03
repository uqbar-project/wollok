package org.uqbar.wollok.teamwork.git;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbench;
import org.uqbar.wollok.teamwork.extensions.TeamworkConfigurator;

public class GitRespositoryConfigurator implements TeamworkConfigurator {

	private List<IWizardPage> pages = new ArrayList<IWizardPage>();
	private IProject project;
	private IWizard wizard;
	private IWorkbench workbench;

	private String repo;

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
		this.wizard = wizard;

		this.pages.add(new WizardPage("Wollok over GIT Page") {

			@Override
			public void createControl(Composite arg0) {

				Composite container = new Composite(arg0, SWT.NONE);
				GridLayout layout = new GridLayout(2, true);
				container.setLayout(layout);

				Label label1 = new Label(container, SWT.NONE);
				label1.setText("Repo URL");

				Text text1 = new Text(container, SWT.BORDER | SWT.SINGLE);
				text1.setText("");
				text1.addModifyListener(new ModifyListener() {

					@Override
					public void modifyText(ModifyEvent paramModifyEvent) {
						if (paramModifyEvent.data != null) {
							repo = paramModifyEvent.data.toString();
						}
					}
				});
				;

				this.setControl(container);
			}
		});

	}

	@Override
	public void configure() {
		System.out.println("configurando el proyecto sobre git en el repo "
				+ repo);
	}

	@Override
	public boolean configureEnabled() {
		return repo != null;
	}

}
