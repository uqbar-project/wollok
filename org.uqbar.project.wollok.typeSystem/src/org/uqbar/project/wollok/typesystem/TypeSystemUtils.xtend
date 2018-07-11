package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * @author jfernandes
 */
class TypeSystemUtils {
	
	// helper
	def static functionType(WMethodDeclaration m, extension TypeSystem ts) {
		"(" + m.parameterTypes(ts).join(", ") + ') => ' + m.type
	}
	
	def static constructorType(WConstructor it, extension TypeSystem ts) {
		"(" + parameters.map[type?.name].join(", ") + ")"
	}
	
	def static parameterTypes(WMethodDeclaration m, extension TypeSystem ts) {
		m.parameters.map[it.type]
	}
	
	// TODO: hardcoded !
	def static typeOfOperation(String op) {
		if (#["&&", "||"].contains(op))
			#[OBJECT,OBJECT] -> BOOLEAN
		else if (#["==", "!=", "===", "<", "<=", ">", ">="].contains(op))
			#[OBJECT,OBJECT] -> BOOLEAN
		else
			#[NUMBER,NUMBER] -> NUMBER
	}
	
}