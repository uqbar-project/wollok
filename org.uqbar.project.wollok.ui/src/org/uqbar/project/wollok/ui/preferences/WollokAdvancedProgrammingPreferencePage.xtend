package org.uqbar.project.wollok.ui.preferences

import org.eclipse.jface.preference.PreferencePage
import org.eclipse.swt.widgets.Composite
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import javax.inject.Inject
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.uqbar.project.wollok.ui.Messages

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*


class WollokAdvancedProgrammingPreferencePage extends PreferencePage {
	
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
	
	override protected createContents(Composite parent) {
			new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginLeft = 10
				marginRight = 10
				marginTop = 10
			]
			addCheckBox(Messages.WollokDynamicDiagramPreferencePage_integrateREPL_description, ACTIVATE_DYNAMIC_DIAGRAM_REPL, booleanPrefValues, 10)
		]
	}
	
	override protected IPreferenceStore doGetPreferenceStore() {
		return preferenceStoreAccess.getWritablePreferenceStore( );
	}
	
	
	
}