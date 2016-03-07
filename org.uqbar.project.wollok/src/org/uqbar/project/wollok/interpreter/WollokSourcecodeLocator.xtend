package org.uqbar.project.wollok.interpreter

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocator
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * Wollok impl
 * 
 * @author jfernandes
 */
class WollokSourcecodeLocator implements SourceCodeLocator {
	public static val INSTANCE = new WollokSourcecodeLocator
	
	def dispatch String contextDescription(Void o) { null }
	def dispatch String contextDescription(EObject o) { /*println("No context for " + o) ;*/ null }
	def dispatch String contextDescription(WExpression e) { e.method.contextDescription }
	def dispatch String contextDescription(WMethodDeclaration m) {
		m.declaringContext.contextName + "." + m.name + "(" + m.parameters.map[name].join(",") + ")"
	}
	def dispatch String contextDescription(WConstructor m) {
		m.declaringContext.contextName + "." + "(" + m.parameters.map[name].join(",") + ")"
	}
	
	
}