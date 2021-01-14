package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.uqbar.project.wollok.ui.Messages

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*

class WollokAdvancedProgrammingConfigurationBlock extends WollokAbstractConfigurationBlock {
		
	public static val  ACTIVATE_ADVANCED_PROGRAMMING= "WollokAdvancedProgramming_active"
	IPreferenceStore store
	boolean initialValue
	
	new(IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(null, store, container)
		store.setDefault(ACTIVATE_ADVANCED_PROGRAMMING, FALSE)
		this.store = store
		initialValue = currentValue
	}
	
	def currentValue() {
		this.store.getBoolean(ACTIVATE_ADVANCED_PROGRAMMING)
	}
	
	override protected doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginLeft = 10
				marginRight = 10
				marginTop = 10
			]
			addCheckBox(Messages.WollokAdvancedProgrammingConfigurationPreferencePage_active_description, ACTIVATE_ADVANCED_PROGRAMMING, booleanPrefValues, 10)
		]		
	}
	
	override getPropertyPrefix() { throw new UnsupportedOperationException("this block is just for global preferences") }
	
	override hasProjectSpecificOptions(IProject project) {
		return false
	}
	
	override savePreferences() {
		super.savePreferences()
		if (initialValue != currentValue) {
			//TODO RESTART ECLIPSE	
		}
	}
	
	
}