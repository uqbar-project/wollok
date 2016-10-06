package org.uqbar.project.wollok

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.utils.WEclipseUtils

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Just a utility to check for elements enabled / disabled
 * Since they are checke from many places like: code hightlight, autocomplete, and validator
 * 
 * @author jfernandes
 */
@Singleton 
class LanguageFeaturesHelper {
	// TODO: this needs to be optimized:
	//    - it should load preferences just one time and then listen for changes
	//	  - also for each disabled rule, it should register all its children so we don't need
	//	    to visit up all parents and we can do "disabled.contains(element)"
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
	def dispatch boolean isDisabled(EObject grammarElement, EObject context) {
		grammarElement.eContainer != null && grammarElement.eContainer.isDisabled(context) 
	}

	/** a call is disabled if the rule that is calling is disabled */	
	def dispatch boolean isDisabled(RuleCall ruleCall, EObject context) {
		isDisabled(ruleCall.rule, context)
	}
	
	def dispatch boolean isDisabled(AbstractRule element, EObject context) {
		val prefs = context.preferences
		
		val key = enabledPreferenceName(element)
		prefs != null && prefs.contains(key) && !prefs.getBoolean(key)
	}
	
	def static enabledPreferenceName(AbstractRule rule) {
		"feature_rule_" + rule.name + "_enabled"
	}
	
	def preferences(EObject obj) {
		if (WEclipseUtils.isWorkspaceOpen) {
			val ifile = obj.IFile
			if (ifile != null) {
				return preferenceStoreAccess.getContextPreferenceStore(ifile.project)
			}
		}
		null
	}
	
}