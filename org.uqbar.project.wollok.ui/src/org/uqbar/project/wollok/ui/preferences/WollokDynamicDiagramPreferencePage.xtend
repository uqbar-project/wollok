package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage
import org.uqbar.project.wollok.ui.Messages

class WollokDynamicDiagramPreferencePage extends LanguageRootPreferencePage {

	@Inject
	IPreferenceStoreAccess preferenceStoreAccess
    
	public static val ACTIVATE_DYNAMIC_DIAGRAM_WITH_REPL = "Wollok.DynamicDiagramWithREPL"
	
	override protected createFieldEditors() {
		preferenceStoreAccess.writablePreferenceStore => [
			setDefault(ACTIVATE_DYNAMIC_DIAGRAM_WITH_REPL, true)
		]
		
		addField(
			new BooleanFieldEditor(ACTIVATE_DYNAMIC_DIAGRAM_WITH_REPL, Messages.WollokDynamicDiagramPreferencePage_integrateREPL_description,
				fieldEditorParent))
	}

}
