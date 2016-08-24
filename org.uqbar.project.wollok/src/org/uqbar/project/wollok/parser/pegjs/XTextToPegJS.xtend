package org.uqbar.project.wollok.parser.pegjs

import org.uqbar.project.wollok.WollokDslStandaloneSetup
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import com.google.inject.Inject
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.AbstractElement
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.CompoundElement
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.RuleCall

/**
 * Generates a PEGJS grammar based on the XText grammar
 * 
 * @author jfernandes
 */
class XTextToPegJS {
	@Inject
	WollokDslGrammarAccess grammar
	
	def static void main(String[] args) {
		val setup = new WollokDslStandaloneSetup()
		val injector = setup.createInjectorAndDoEMFRegistration
		val generator = new XTextToPegJS()
		injector.injectMembers(generator)
		
		generator.generate()
	}
	
	def generate() {
		grammar.grammar.rules.forEach [rule|
			println(rule.name)
			println("  = ")
			println(toPegJS(rule))
		]
	}
	
	def dispatch toPegJS(ParserRule it) {
		alternatives.alternativeToPegJS
	}
	
	def dispatch toPegJS(AbstractRule it) {
		""
	}
	
	// elements
	
	def dispatch String alternativeToPegJS(AbstractElement it) { "<<unknown>>" }
	def dispatch String alternativeToPegJS(Keyword it) { '''KEYWORD(«value»)''' }
	def dispatch String alternativeToPegJS(CompoundElement it) { 
		'''
			«FOR e : elements»
			«e.alternativeToPegJS»
			«ENDFOR»
			{
				return {
					«FOR element : elements.filter(Assignment) SEPARATOR ","»
						«element.feature» : «element.feature»
					«ENDFOR»
				}	
			}
		'''
	}

	def dispatch String alternativeToPegJS(RuleCall it) { rule.name }
	
	def dispatch String alternativeToPegJS(Assignment it) { '''(«feature»: (i:«terminal.alternativeToPegJS» whitespace { return i })«cardinality»)'''}
	

	
}