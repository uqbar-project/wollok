package org.uqbar.wollok.teamwork.git;


import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

public class GitRepositoryConfiguratorPage extends WizardPage {

	private String repoString;
	private String user;
	private String password;
	private GitRespositoryConfigurator configurator;
	
	public GitRepositoryConfiguratorPage(GitRespositoryConfigurator configurator) {
		super("Wollok Over Git");
		this.configurator = configurator;
		this.setDescription("Configure Git Repository");
		
	}


	@Override
	public void createControl(Composite paramComposite) {

		Group composite = new Group(paramComposite, SWT.NONE);

		composite.setLayout(new GridLayout(2, false));
		composite.setText("New Repository Configuration");

		
		createText(composite, "Repository", new GitConfiguratorModifyListener() {

			@Override
			public void setValue(GitRespositoryConfigurator configurator,
					String string) {
				configurator.setRepositoryString(string);
			}
			
		}, "http://", "Git Repository URL, for example: http://github.com/uqbar-project");
		
		createText(composite, "User",  new GitConfiguratorModifyListener() {

			@Override
			public void setValue(GitRespositoryConfigurator configurator,
					String string) {
				configurator.setUser(string);
			}
			
		}, "userName", "the username for the repository");
		
		createText(composite, "Password",  new GitConfiguratorModifyListener() {

			@Override
			public void setValue(GitRespositoryConfigurator configurator,
					String string) {
				configurator.setPassword(string);
			}
			
		}, "password", "the password for the selected username", SWT.PASSWORD | SWT.SINGLE);
		
		this.setControl(composite);
	}
	
	
	public void createText(Composite parent, String label, ModifyListener listener, String defaultValue, String help) {
		this.createText(parent, label, listener,defaultValue, help, SWT.SINGLE);
	}
		
	public void createText(Composite parent, String label, ModifyListener listener, String defaultValue, String help, int style) {
		    
	    Label lab = new Label(parent, SWT.None);
	    lab.setLayoutData(new GridData(GridData.BEGINNING));
		lab.setText(label);
		Text text = new Text(parent, style);
		text.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
		text.addModifyListener(listener);
		text.setToolTipText(help);
		text.setText(defaultValue);
		
	}
	
	
	@Override
	public boolean isPageComplete() {
		return this.repoString != null && this.user != null && this.password != null;
	}


	protected abstract class GitConfiguratorModifyListener implements ModifyListener {
		@Override
		public void modifyText(ModifyEvent arg0) {
			this.setValue(GitRepositoryConfiguratorPage.this.configurator, ((Text)arg0.widget).getText());
			
			GitRepositoryConfiguratorPage.this.getWizard().getContainer().updateButtons();
		}

		public abstract void setValue(GitRespositoryConfigurator configurator, String string);
		
	}

}
