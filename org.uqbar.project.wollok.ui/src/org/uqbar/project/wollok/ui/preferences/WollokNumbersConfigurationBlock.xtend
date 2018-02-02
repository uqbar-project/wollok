package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersPreferences

import static org.uqbar.project.wollok.ui.Messages.*

class WollokNumbersConfigurationBlock extends OptionsConfigurationBlock {
	
	extension val WollokNumbersPreferences = WollokNumbersPreferences.instance

	public static val DECIMAL_POSITIONS = "WollokNumberPreferences_DecimalPosition"
	public static val NUMBER_COERCING_STRATEGY = "WollokNumberPreferences_CoercingStrategy"
	public static val NUMBER_PRINTING_STRATEGY = "WollokNumberPreferences_PrintingStrategy"
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		store.setDefault(DECIMAL_POSITIONS, WollokNumbersPreferences.DECIMAL_POSITIONS_DEFAULT)
		store.setDefault(NUMBER_COERCING_STRATEGY, WollokNumbersPreferences.NUMBER_COERCING_STRATEGY_DEFAULT.name)
		store.setDefault(NUMBER_PRINTING_STRATEGY, WollokNumbersPreferences.NUMBER_PRINTING_STRATEGY_DEFAULT.name)
	}
	
	override protected doCreateContents(Composite parent) {
		val coercingStrategiesDescriptions = coercingStrategies.map [ description ]
		val printingStrategiesDescriptions = printingStrategies.map [ description ]

		val coercingStrategiesNames = coercingStrategies.map [ name ]
		val printingStrategiesNames = printingStrategies.map [ name ]
		
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginHeight = 20
				marginWidth = 8
			]
			addTextField(WollokNumbersPreferencePage_decimalPositionsAmount, DECIMAL_POSITIONS, 0, 150)
			addComboBox(WollokNumbersPreferencePage_numberCoercingStrategy, NUMBER_COERCING_STRATEGY, 0, 
				coercingStrategiesNames, coercingStrategiesDescriptions
			)			
			addComboBox(WollokNumbersPreferencePage_numberPrintingStrategy, NUMBER_PRINTING_STRATEGY, 0, 
				printingStrategiesNames, printingStrategiesDescriptions
			)	
		]
		
	}
	
	override protected getBuildJob(IProject project) {}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {}
	
	override getPropertyPrefix() { "NumbersConfiguration" }
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
		if (changedKey.equalsIgnoreCase(DECIMAL_POSITIONS)) {
			Integer.parseUnsignedInt(newValue)
		}
	}
	
}
