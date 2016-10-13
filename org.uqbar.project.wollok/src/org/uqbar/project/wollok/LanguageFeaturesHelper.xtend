package org.uqbar.project.wollok

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.AbstractElement
import org.eclipse.xtext.AbstractNegatedToken
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.CompoundElement
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.utils.WEclipseUtils

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.Grammar

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
	
	def dispatch boolean isDisabled(AbstractElement abstractElement, EObject context) {
		abstractElement.isDisabledGrammarElement(context)
	}
	
	def dispatch boolean isDisabled(AbstractRule rule, EObject context) {
		rule.isDisabledRule(context) || (rule.eContainer != null && rule.eContainer.isDisabled(context)) 
	}
	
	def dispatch boolean isDisabled(Grammar rule, EObject context) {
		false
	}
	
	
	def boolean isDisabledGrammarElement(AbstractElement grammarElement, EObject context) {
		innerIsDisabledGrammarElement(grammarElement, context) || grammarElement.eContainer != null && grammarElement.eContainer.isDisabled(context) 
	}
	
	/** a call is disabled if the rule that is calling is disabled */
	def dispatch boolean innerIsDisabledGrammarElement(RuleCall call, EObject context) {
		isDisabledRule(call.rule, context)
	}

	def dispatch boolean innerIsDisabledGrammarElement(AbstractNegatedToken e, EObject context) {
		e.terminal != null && e.terminal.innerIsDisabledGrammarElement(context)
	}
	
	def dispatch boolean innerIsDisabledGrammarElement(CompoundElement e, EObject context) {
		e.elements.exists[ innerIsDisabledGrammarElement(context) ]
	}
	
	def dispatch boolean innerIsDisabledGrammarElement(CrossReference e, EObject context) {
		e.terminal != null && e.terminal.innerIsDisabledGrammarElement(context)
	}
	
	def dispatch boolean innerIsDisabledGrammarElement(AbstractElement e, EObject context) {
		// TODO: analyze other elements
		false
	}
	
	// 
	// Checking preferences
	//

	protected def boolean isDisabledRule(AbstractRule element, EObject context) {
		val prefs = context.preferences
		
		val key = enabledPreferenceName(element)
		val r = prefs != null && prefs.contains(key) && !prefs.getBoolean(key)
		
//		println("///// CHECKED " + element + " and was disabled == " + r )
		r
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