package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferencePageContainer
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IWorkbenchPropertyPage
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.Constants
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage

// TODO: Generate an Abstract Preference Page
class WollokNumbersPreferencePage extends PropertyAndPreferencePage implements IWorkbenchPropertyPage {
	@Inject @Named(Constants.LANGUAGE_NAME) String languageName
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	WollokNumbersConfigurationBlock builderConfigurationBlock
	
	override createControl(Composite parent) {
		val container = container as IWorkbenchPreferenceContainer
		val preferenceStore = preferenceStoreAccess.getWritablePreferenceStore(project)
		builderConfigurationBlock = new WollokNumbersConfigurationBlock(project, preferenceStore, container)
		builderConfigurationBlock.statusChangeListener = newStatusChangedListener
		super.createControl(parent)
	}
	
	override protected createPreferenceContent(Composite composite, IPreferencePageContainer preferencePageContainer) {
		builderConfigurationBlock.createContents(composite)
	}
	
	override protected getPreferencePageID() { languageName + "numbers.preferencePage" }
	override protected getPropertyPageID() { languageName + "numbers.propertyPage"}
	
	override protected hasProjectSpecificOptions(IProject project) { false }

	override performOk() {
		builderConfigurationBlock.performOk
		super.performOk
	}

	override performApply() {
		builderConfigurationBlock.performApply
		super.performApply
	}
	
}
