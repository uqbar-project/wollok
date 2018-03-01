package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.jface.preference.IntegerFieldEditor
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage
import org.uqbar.project.wollok.ui.Messages

class WollokRootPreferencePage extends LanguageRootPreferencePage {

	@Inject
	IPreferenceStoreAccess preferenceStoreAccess
    
	public static val FORMAT_ON_SAVE = "Wollok.formatOnSave"
	public static val DEBUGGER_WAIT_TIME_FOR_CONNECT = "Wollok.debuggerWaitTimeForConnect"
	public static val DEBUGGER_WAIT_TIME_FOR_CONNECT_DEFAULT = 3000
	
	override protected createFieldEditors() {
		preferenceStoreAccess.writablePreferenceStore => [
			setDefault(FORMAT_ON_SAVE, false)
			setDefault(DEBUGGER_WAIT_TIME_FOR_CONNECT, DEBUGGER_WAIT_TIME_FOR_CONNECT_DEFAULT)
		]
		
		addField(
			new BooleanFieldEditor(FORMAT_ON_SAVE, Messages.WollokRootPreferencePage_autoformat_description,
				fieldEditorParent))
				
		addField(
			new IntegerFieldEditor(DEBUGGER_WAIT_TIME_FOR_CONNECT, Messages.WollokRootPreferencePage_debuggerWaitTimeForConnect,
				fieldEditorParent))

	}

}
