package org.uqbar.project.wollok.typesystem

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * @author jfernandes
 */
class TypeSystemUtils {
	
	// helper
	def static functionType(WMethodDeclaration m, extension TypeSystem ts) {
		"(" + m.parameters.types(ts) + ') => ' + m.type.name
	}
	
	def static types(EList<? extends EObject> elements, extension TypeSystem ts) {
		elements.map[it.type?.name].join(", ")
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