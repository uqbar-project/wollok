package org.uqbar.project.wollok.ui.editor.templates

import java.util.Properties
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.Grammar

/**
 * Helper object for creating code templates in a more
 * declarative and clean way.
 * 
 * @author jfernandes
 */
class TemplateBuilder {
	String idPreffix
	String i18nPreffix
	ParserRule rule
	(AbstractRule, String, String, String, String)=>void closure
	Properties props
	Grammar grammar
	
	new(Grammar grammar, String idPreffix, String i18nPreffix, Properties props, (AbstractRule, String, String, String, String)=>void closure) {
		this.grammar = grammar
		this.closure = closure
		this.idPreffix = idPreffix
		this.i18nPreffix = i18nPreffix
		this.props = props
	}
	
	def operator_doubleLessThan(ParserRule rule) {
		this.rule = rule
		this
	}
	
	def operator_doubleLessThan(Class modelClass) {
		this.rule = grammar.rules.filter(ParserRule).findFirst[name == modelClass.simpleName]
		this
	}
	
	def operator_doubleGreaterThan(String s) {
		val id = idPreffix + "." + rule.name.toLowerCase
		val name = i18n(rule.name + "_name")
		val description = i18n(rule.name + "_description")
		closure.apply(rule, name, description, id, s)
		
		this
	}
	
	def i18n(String key) {
		val k = i18nPreffix + "_" + key
		props.getProperty(k, k)  
	}
	
	
}