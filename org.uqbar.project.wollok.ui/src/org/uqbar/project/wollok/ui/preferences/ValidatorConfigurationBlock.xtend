package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.uqbar.project.wollok.ui.WollokActivator

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.validation.CheckSeverity
import org.uqbar.project.wollok.validation.DefaultSeverity
import org.uqbar.project.wollok.validation.CheckSeverityUtils
import static extension org.uqbar.project.wollok.utils.StringUtils.*

/**
 * Configuration for XText validator options.
 * Validations can be configured to enable / disable them.
 * Also the severity can be configured: error, warning, info.
 * 
 * This config applies both for general workspace preferences
 * as well as per project.
 * 
 * @author jfernandes
 */
class ValidatorConfigurationBlock extends OptionsConfigurationBlock {
	static val SETTINGS_SECTION_NAME = "ValidatorConfigurationBlock"
	
	IPreferenceStore store
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		this.store = store
	}
	
	override protected doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout(4, false) => [
				marginHeight = 20
				marginWidth = 8
			]
			
			WollokDslValidator.methods.filter[m| m.isAnnotationPresent(Check)].forEach[m|
				if (m.getAnnotation(DefaultSeverity) != null)
					store.setDefault(m.name, m.getAnnotation(DefaultSeverity).value.name)
				store.setDefault(m.name + WollokDslValidator.PREF_KEY_ENABLED_SUFFIX, TRUE)
				
				// TODO: i18nize
				val checkDescription = splitCamelCase(m.name).firstUpper
				
				// TODO: disabled the combo if the check is disabled
				addCheckBox(it, checkDescription, m.name + WollokDslValidator.PREF_KEY_ENABLED_SUFFIX, booleanPrefValues, 0)
				newComboControl(it, m.name, CheckSeverity.values.map[name], CheckSeverity.values.map[CheckSeverityUtils.getI18nizedValue(it)])
			]
		]
	}
	
	override protected getBuildJob(IProject project) {
		new OptionsConfigurationBlock.BuildJob("Saving Validator configuration", project) => [
			rule = ResourcesPlugin.getWorkspace.ruleFactory.buildRule
			user = true	
		]
	}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {
		#["Validation settings", if (workspaceSettings)	"Apply changed workspace-wide ? All wollok projects will be rebuilt" else "Apply changes for this project ? It will be rebuilt" ]
	}
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
	}
	
	override dispose() {
		restoreSectionExpansionStates = WollokActivator.getInstance.dialogSettings.addNewSection(SETTINGS_SECTION_NAME)
		super.dispose
	}
	
}