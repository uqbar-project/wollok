package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock

import static org.uqbar.project.wollok.ui.Messages.*
import static extension org.uqbar.project.wollok.WollokConstants.*

class WollokConsoleConfigurationBlock extends OptionsConfigurationBlock {
	
	public static val OUTPUT_FORMATTER = "WollokConsolePreferences_Formatter"
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		store.setDefault(OUTPUT_FORMATTER, ANSI_COLORED_FORMATTER)
	}

	def formattersNames() {
		#[ REGULAR_FORMATTER, ANSI_COLORED_FORMATTER ]
	}

	def formattersDescriptions() {
		#[ WollokConsolePreferencePage_regular_description, WollokConsolePreferencePage_ansiColored_description ]
	}

	override protected doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginHeight = 20
				marginWidth = 8
			]
			addComboBox(WollokConsolePreferencePage_output_formatter, OUTPUT_FORMATTER, 0, 
				formattersNames, formattersDescriptions
			)			
		]
	}
	
	override protected getBuildJob(IProject project) {}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {}
	
	override getPropertyPrefix() { "ConsoleConfiguration" }
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
	}

	override performApply() {
		// Hay que hacer esto para que no se rompa Xtext
		savePreferences
		true
	}
	
	override performOk() {
		// Hay que hacer esto para que no se rompa Xtext
		savePreferences
		true
	}
}

