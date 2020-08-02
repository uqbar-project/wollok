package org.uqbar.project.wollok.ui.wizard.objects

import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.widgets.Combo
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizardPage

import static extension org.uqbar.project.wollok.validation.ElementNameValidation.*
import static extension org.uqbar.project.wollok.WollokConstants.*

class NewWollokObjectsWizardPage extends AbstractNewWollokFileWizardPage {
	Text elementNameText
	Combo cbElement
	@Accessors String elementName
	@Accessors int elementIndex
	
	new(IStructuredSelection selection) {
		super(selection)
	}

	override doInit() {
		this.extension = WOLLOK_DEFINITION_EXTENSION
		this.initialFileName = "objects." + WOLLOK_DEFINITION_EXTENSION //$NON-NLS-1$
		this.title = Messages.NewWollokObjectsWizardPage_title
		this.description = Messages.NewWollokObjectsWizardPage_description
	}
	
	override doCreateControl(Composite container) {
		new Label(container, SWT.NULL) => [
			text = Messages.NewWollokObjectsWizardPage_elementType
		]

		cbElement = new Combo(container, SWT.NONE) => [
			add(Messages.NewWollokObjectsWizardPage_objectLabel)
			add(Messages.NewWollokObjectsWizardPage_classLabel)
			add(Messages.NewWollokObjectsWizardPage_mixinLabel)
			select(0)
			addModifyListener [ e | dialogChanged()]
		]
		
		new Label(container, SWT.NULL) => [
			text = Messages.NewWollokObjectsWizardPage_elementName
		]
	
		elementNameText = new Text(container, SWT.BORDER.bitwiseOr(SWT.SINGLE)) => [
			layoutData = new GridData(GridData.FILL_HORIZONTAL)
			addModifyListener [ e | dialogChanged()]
		]
		
	}
	
	override doDialogChanged() {
		elementName = elementNameText.text
		elementIndex = cbElement.selectionIndex	
		
		if (elementName.contains('.')) {
			updateStatus('.'.asInvalidCharacterMessage)
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