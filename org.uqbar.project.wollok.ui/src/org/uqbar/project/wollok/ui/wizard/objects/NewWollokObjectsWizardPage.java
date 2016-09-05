package org.uqbar.project.wollok.ui.wizard.objects;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.Messages;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage;
import org.uqbar.project.wollok.validation.ElementNameValidation;
import org.uqbar.project.wollok.validation.Validation;

/**
 * 
 * @author tesonep
 */
public class NewWollokObjectsWizardPage extends AbstractNewWollokFileWizardPage {
	private Text elementNameText;
	private String elementName;
	
	public NewWollokObjectsWizardPage(IStructuredSelection selection) {
		super(selection);
	}

	protected void doInit(){
		this.extension = WollokConstants.CLASS_OBJECTS_EXTENSION;
		this.initialFileName = "objects." + WollokConstants.CLASS_OBJECTS_EXTENSION; //$NON-NLS-1$
		this.title = Messages.NewWollokObjectsWizardPage_title;
		this.description = Messages.NewWollokObjectsWizardPage_description;
	}
	
	@Override
	public void doCreateControl(Composite container) {
		Label label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWollokObjectsWizardPage_elementName);
	
		elementNameText = new Text(container, SWT.BORDER | SWT.SINGLE);
		GridData gd = new GridData(GridData.FILL_HORIZONTAL);
		elementNameText.setLayoutData(gd);
		elementNameText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				dialogChanged();
			}
		});
	}
	
	@Override
	public boolean doDialogChanged() {
		elementName = elementNameText.getText();
		
		Validation nameValidation = ElementNameValidation.validateName(elementName);
		if (!nameValidation.isOk()) {
			updateStatus(nameValidation.getMessage());
			return false;
		}
		return true;
	}
	
	public String getElementName() {
		return elementName;
	}
	
}