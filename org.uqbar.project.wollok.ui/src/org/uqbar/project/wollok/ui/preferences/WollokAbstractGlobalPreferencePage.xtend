package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.jface.preference.PreferencePage
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IWorkbench
import org.eclipse.ui.IWorkbenchPreferencePage
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.Constants
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess

abstract class WollokAbstractGlobalPreferencePage extends PreferencePage implements IWorkbenchPreferencePage {
	@Inject @Named(Constants.LANGUAGE_NAME) String languageName
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	WollokAbstractConfigurationBlock builderConfigurationBlock
	
	override createControl(Composite parent) {
		val container = container as IWorkbenchPreferenceContainer
		val preferenceStore = preferenceStoreAccess.getWritablePreferenceStore()
		builderConfigurationBlock = buildConfigurationBlock(preferenceStore, container)
		
		super.createControl(parent)
	}
	
	override void init(IWorkbench workbench) {			
	}
	
	override protected createContents(Composite parent) {
		builderConfigurationBlock.createContents(parent)
	}
	
	def WollokAbstractConfigurationBlock buildConfigurationBlock(IPreferenceStore store, IWorkbenchPreferenceContainer container)
	
	override performOk() {
		builderConfigurationBlock.performOk
		super.performOk
	}

	override performApply() {
		builderConfigurationBlock.performApply
		super.performApply
	}
	
}