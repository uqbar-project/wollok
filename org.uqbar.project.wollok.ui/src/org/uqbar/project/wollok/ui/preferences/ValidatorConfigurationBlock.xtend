package org.uqbar.project.wollok.ui.preferences

import java.lang.reflect.Method
import java.util.Properties
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.eclipse.xtext.ui.validation.AbstractValidatorConfigurationBlock
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.validation.CheckGroup
import org.uqbar.project.wollok.validation.CheckGroupDefault
import org.uqbar.project.wollok.validation.CheckSeverity
import org.uqbar.project.wollok.validation.CheckSeverityUtils
import org.uqbar.project.wollok.validation.DefaultSeverity
import org.uqbar.project.wollok.validation.NotConfigurable
import org.uqbar.project.wollok.validation.WollokDslValidator

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*

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
class ValidatorConfigurationBlock extends AbstractValidatorConfigurationBlock {
	static Properties properties
	static val SETTINGS_SECTION_NAME = "ValidatorConfigurationBlock"
	public static final String PROPERTY_PREFIX = "StaticValidatorConfiguration"
	
	IPreferenceStore store
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		this.store = store
		this.preferenceStore = store
		this.workbenchPreferenceContainer = container
	}
	
	override getPropertyPrefix() { PROPERTY_PREFIX }
	
	def getGetProperties() {
		if (properties === null)
			properties = Messages.loadProperties 
		properties
	}
	
	override protected fillSettingsPage(Composite composite, int nColumns, int defaultIndent) {
		val methodsByGroup = validationMethods.groupBy[m |
			if (m.isAnnotationPresent(CheckGroup))
				m.getAnnotation(CheckGroup).value
			else 
				CheckGroupDefault.DEFAULT_GROUP
		]
		
		methodsByGroup.forEach[ group, methods |
			val section = createSection(group.i18n, composite, nColumns)
			doCreateContentsBlah(section, methods)
		]
	}
	
	def getI18n(String string) { val k = "CheckGroup_" + string getProperties.getProperty(k, k) }
	
	protected def doCreateContentsBlah(Composite parent, Iterable<Method> methods) {
		val severityKeys = CheckSeverity.values.map[name]
		val severityValues = CheckSeverity.values.map[CheckSeverityUtils.getI18nizedValue(it)]
		
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout(4, false) => [
				marginHeight = 20
				marginWidth = 8
			]
			
			methods
			.forEach[ m |
				if (m.getAnnotation(DefaultSeverity) !== null)
					store.setDefault(m.name, m.getAnnotation(DefaultSeverity).value.name)
				store.setDefault(m.enabledPropertyName, TRUE)
				
				// TODO: disabled the combo if the check is disabled
				addCheckBox(it, m.validationLabel, m.enabledPropertyName, booleanPrefValues, 0)
				newComboControl(it, m.name, severityKeys, severityValues)
			]
		]
	}
	
	protected def validationLabel(Method m) { splitCamelCase(m.name).firstUpper }
	
	/** property name for enabled/disabled in pref store */
	protected def enabledPropertyName(Method m) { m.name + WollokDslValidator.PREF_KEY_ENABLED_SUFFIX }
	
	protected def validationMethods() {
		WollokDslValidator.methods.filter[isAnnotationPresent(Check) && isAnnotationPresent(DefaultSeverity) && !isAnnotationPresent(NotConfigurable)]
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