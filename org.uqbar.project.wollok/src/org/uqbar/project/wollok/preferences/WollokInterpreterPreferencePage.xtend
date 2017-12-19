package org.uqbar.project.wollok.preferences

import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferencePageContainer
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IWorkbenchPropertyPage
import org.eclipse.xtext.Constants
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage

@Deprecated
class WollokInterpreterPreferencePage extends PropertyAndPreferencePage implements IWorkbenchPropertyPage {
	@Inject @Named(Constants.LANGUAGE_NAME) String languageName
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
	override protected createPreferenceContent(Composite composite, IPreferencePageContainer preferencePageContainer) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override protected getPreferencePageID() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override protected getPropertyPageID() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override protected hasProjectSpecificOptions(IProject project) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}