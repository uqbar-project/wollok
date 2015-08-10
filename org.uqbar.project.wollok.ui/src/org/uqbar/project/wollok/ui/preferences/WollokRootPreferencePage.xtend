package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage
import org.uqbar.project.wollok.ui.Messages

class WollokRootPreferencePage extends LanguageRootPreferencePage {

	@Inject
	IPreferenceStoreAccess preferenceStoreAccess

	public static val FORMAT_ON_SAVE = "Wollok.formatOnSave";

	override protected createFieldEditors() {

		val preferenceStore = preferenceStoreAccess.getWritablePreferenceStore()
		preferenceStore.setDefault(FORMAT_ON_SAVE, false)

		addField(
			new BooleanFieldEditor(FORMAT_ON_SAVE, Messages.WollokRootPreferencePage_autoformat_description,
				fieldEditorParent));
	}

}
