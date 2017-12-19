package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.jface.preference.ComboFieldEditor
import org.eclipse.jface.preference.IntegerFieldEditor
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage
import org.uqbar.project.wollok.interpreter.nativeobj.DecimalPrintingStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.DecimalsNotAllowedCoercionStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.PlainPrintingStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.RoundingDecimalsCoercionStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.TruncateDecimalsCoercionStrategy
import org.uqbar.project.wollok.ui.Messages
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokInterpreterPreferences.*

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
			setDefault(DECIMAL_POSITIONS, DECIMAL_POSITIONS_DEFAULT)
			setDefault(NUMBER_COERCING_STRATEGY, NUMBER_COERCING_STRATEGY_DEFAULT)
			setDefault(NUMBER_PRINTING_STRATEGY, NUMBER_PRINTING_STRATEGY_DEFAULT)
		]
		
		addField(
			new BooleanFieldEditor(FORMAT_ON_SAVE, Messages.WollokRootPreferencePage_autoformat_description,
				fieldEditorParent))
				
		addField(
			new IntegerFieldEditor(DEBUGGER_WAIT_TIME_FOR_CONNECT, Messages.WollokRootPreferencePage_debuggerWaitTimeForConnect,
				fieldEditorParent))

		addField(
			new IntegerFieldEditor(DECIMAL_POSITIONS, Messages.WollokRootPreferencePage_decimalPositionsAmount,
				fieldEditorParent))

		val truncateStrat = new TruncateDecimalsCoercionStrategy
		val withoutDecimalStrat = new DecimalsNotAllowedCoercionStrategy
		val roundingStrat = new RoundingDecimalsCoercionStrategy
			
		// TODO: Enhance this, by God sake! Using a Matrix is no good, and Xtend lacks documentation for this	
		val String[][] coercingStrats = #[ #[truncateStrat.description, truncateStrat.description], 
			#[withoutDecimalStrat.description, withoutDecimalStrat.description],
			#[roundingStrat.description, roundingStrat.description]
		]
		
		addField(
			new ComboFieldEditor(NUMBER_COERCING_STRATEGY, Messages.WollokRootPreferencePage_numberCoercingStrategy, 
				coercingStrats, fieldEditorParent
			)
		)

		val printingStrat = new DecimalPrintingStrategy
		val plainStrat = new PlainPrintingStrategy
		
		val String[][] printingStrats = #[ #[printingStrat.description, printingStrat.description], 
			#[plainStrat.description, plainStrat.description]
		]
		
		addField(
			new ComboFieldEditor(NUMBER_PRINTING_STRATEGY, Messages.WollokRootPreferencePage_numberPrintingStrategy, 
				printingStrats, fieldEditorParent
			)
		)

	}

}
