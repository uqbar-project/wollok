package org.uqbar.project.wollok.ui.wizard.objects

import java.util.List
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.osgi.util.NLS
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage

import static extension org.uqbar.project.wollok.validation.ElementNameValidation.*

class NewWollokObjectsWizardPage extends AbstractNewWollokFileWizardPage {
	Text elementNameText
	List<Button> btnObject = newArrayList
	@Accessors String elementName
	@Accessors int elementIndex
	
	new(IStructuredSelection selection) {
		super(selection)
	}

	override doInit() {
		this.extension = WollokConstants.CLASS_OBJECTS_EXTENSION
		this.initialFileName = "objects." + WollokConstants.CLASS_OBJECTS_EXTENSION //$NON-NLS-1$
		this.title = Messages.NewWollokObjectsWizardPage_title
		this.description = Messages.NewWollokObjectsWizardPage_description
	}
	
	override doCreateControl(Composite container) {
		btnObject.add(new Button(container, SWT.RADIO) => [
			selection = true
			text = Messages.NewWollokObjectsWizardPage_objectLabel
		])
		btnObject.add(new Button(container, SWT.RADIO) => [
			text = Messages.NewWollokObjectsWizardPage_classLabel
		])
		
		val label = new Label(container, SWT.NULL)
		label.setText(Messages.NewWollokObjectsWizardPage_elementName)
	
		elementNameText = new Text(container, SWT.BORDER.bitwiseOr(SWT.SINGLE)) => [
			layoutData = new GridData(GridData.FILL_HORIZONTAL)
			addModifyListener [ e | dialogChanged()]
		]
	}
	
	override def doDialogChanged() {
		elementName = elementNameText.text
		val type = btnObject.findFirst [ btn | btn.selection ]
		elementIndex = btnObject.indexOf(type)	
		
		if (elementName.contains('.')) {
			updateStatus(NLS.bind(Messages.WollokDslNewWizard_invalidChar, '.'))
			return false
		}

		val nameValidation = elementName.validateName
		if (!nameValidation.ok) {
			updateStatus(nameValidation.message)
			return false
		}
		return true
	}
	
}