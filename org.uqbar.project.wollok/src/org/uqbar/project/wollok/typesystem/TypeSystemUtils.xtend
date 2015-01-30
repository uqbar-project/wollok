package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import static org.uqbar.project.wollok.semantics.WollokType.*

/**
 * @author jfernandes
 */
class TypeSystemUtils {
	
	// helper
	def static functionType(WMethodDeclaration m, extension TypeSystem ts) {
		"(" + m.parameters.map[type?.name].join(", ") + ') => ' + m.type?.name
	}
	
	// TODO: hardcoded !
	def static typeOfOperation(String op) {
		if (#["&&", "||"].contains(op))
			#[WAny,WAny] -> WBoolean
		else if (#["==", "!=", "===", "<", "<=", ">", ">="].contains(op))
			#[WAny,WAny] -> WBoolean
		else
			#[WInt,WInt] -> WInt
	}
	
}