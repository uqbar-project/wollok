package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.eclipse.xtext.ui.validation.AbstractValidatorConfigurationBlock
import org.uqbar.project.wollok.services.WollokDslGrammarAccess

import static org.uqbar.project.wollok.LanguageFeaturesHelper.*

/**
 * Preference section for Wollok Language features enabling/disabling
 * 
 * @author jfernandes
 */
class FeaturesConfigurationBlock extends AbstractValidatorConfigurationBlock {
	IPreferenceStore store
	@Inject
	WollokDslGrammarAccess grammar
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		this.store = store
		this.preferenceStore = store
		this.workbenchPreferenceContainer = container
	}
	
	override protected fillSettingsPage(Composite composite, int nColumns, int defaultIndent) {
		new Composite(composite, SWT.NONE) => [
			layout = new GridLayout(4, false) => [
				marginHeight = 20
				marginWidth = 8
			]
			
			val section = createSection("Features", composite, nColumns)
			grammar.grammar.rules.sortBy[ r | r.humanReadableName ].forEach [ rule |
				var name = enabledPreferenceName(rule)
				store.setDefault(name, true) // all enabled by default
				addCheckBox(section, rule.humanReadableName, name, #["true","false"], 0)	
			]
			
		]
	}
	
	def String getHumanReadableName(AbstractRule rule) {
		rule.name.removeWPreffix.splitCamelCase
	}
	
	def removeWPreffix(String name) {
		if (name.startsWith("W") && Character.isUpperCase(name.charAt(1)))
			name.substring(1)
		else
			name
	}
	
	def static splitCamelCase(String s) {
	   return s.replaceAll(
	      String.format("%s|%s|%s",
	         "(?<=[A-Z])(?=[A-Z][a-z])",
	         "(?<=[^A-Z])(?=[A-Z])",
	         "(?<=[A-Za-z])(?=[^A-Za-z])"
	      ),
	      " "
	   );
	}
	
	override protected getBuildJob(IProject project) {
		new OptionsConfigurationBlock.BuildJob("Saving configuration", project) => [
			rule = ResourcesPlugin.getWorkspace.ruleFactory.buildRule
			user = true	
		]
	}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {
		#["Language Settings", if (workspaceSettings) "Apply changed workspace-wide ? All wollok projects will be rebuilt" else "Apply changes for this project ? It will be rebuilt" ]
	}
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {
	}
	
}