package org.uqbar.project.wollok.typeSystem.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.uqbar.project.wollok.typesystem.Constants
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.validation.CheckSeverity

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*

/**
 * @author jfernandes
 */
//TODO: must rebuild project on apply/save
class TypeSystemConfigurationBlock extends OptionsConfigurationBlock {
	static val SETTINGS_SECTION_NAME = "TypeSystemConfigurationBlock"
	public static final String PROPERTY_PREFIX = "TypeSystemConfiguration"
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		store.setDefault(WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_CHECKS_ENABLED, IPreferenceStore.FALSE)
		store.setDefault(WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_IMPL, Constants.TS_CONSTRAINTS_BASED)
		store.setDefault(WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_SEVERITY, CheckSeverity.WARN.toString)
	}
	
	override getPropertyPrefix() {  PROPERTY_PREFIX }
	
	override doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginHeight = 20
				marginWidth = 8
			]
			addCheckBox(it, Messages.WollokTypeSystemPreference_ENABLE_TYPE_SYSTEM_CHECKS_TITLE, WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_CHECKS_ENABLED, booleanPrefValues, 0)
			
			val typeSystems = WollokTypeSystemActivator.^default.typeSystems.map[t| t.name]
			
			addComboBox(it, Messages.WollokTypeSystemPreference_TYPE_SYSTEM_IMPLEMENTATION_TITLE, WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_IMPL, 0, 
				typeSystems, typeSystems
			)
			
			val severities = WollokTypeSystemUIPreferences.severities.map [ toString ]
			addComboBox(it, Messages.WollokTypeSystemPreference_TYPE_SYSTEM_ISSUE_SEVERITY_TITLE, WollokTypeSystemUIPreferences.PREF_TYPE_SYSTEM_SEVERITY, 1, 
				severities, WollokTypeSystemUIPreferences.severitiesDescriptions
			)
			
		]
	}
	
	override protected getBuildJob(IProject project) {
		new OptionsConfigurationBlock.BuildJob(Messages.WollokTypeSystemPreference_SAVE_JOB_TITLE, project) => [
			rule = ResourcesPlugin.getWorkspace.ruleFactory.buildRule
			user = true	
		]
	}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {
		#[Messages.WollokTypeSystemPreference_CONFIRM_BUILD_PROJECT_TITLE, if (workspaceSettings) Messages.WollokTypeSystemPreference_CONFIRM_BUILD_ALL_MESSAGE else Messages.WollokTypeSystemPreference_CONFIRM_BUILD_PROJECT_MESSAGE ]
	}
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
	}
	
	override dispose() {
		restoreSectionExpansionStates = WollokActivator.getInstance.dialogSettings.addNewSection(SETTINGS_SECTION_NAME)
		super.dispose
	}
	
}