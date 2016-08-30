package org.uqbar.project.wollok.typesystem.substitutions

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ClosureType
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.typesystem.WollokType.*

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClosureTypeRule extends TypeRule {
	val WClosure closure
	ClosureType type
	
	new(WClosure closure, EList<WParameter> parameters, WExpression expression) {
		super(closure)
		this.closure = closure
	}
	
	override resolve(SubstitutionBasedTypeSystem system) {
		// REVIEW: should it run more than once ?
		if (type == null) {
			val paramTypes = closure.parameters.map[system.typeForExcept(it, this)]
			val returnType = if (closure.expression == null)
									WVoid
							else
								system.typeForExcept(closure.expression, this)
			type = new ClosureType(paramTypes, if (returnType != null) returnType else WAny)
			true
		}
		else {
			false
		}
		
	}
	
	override typeOf(EObject object) {
		if (object == closure) {
			type
		}
		else {
			super.typeOf(object)
		}
	}
	
	override ruleStateLeftPart() { '''t(«closure.formattedSourceCode») = «type»''' }
	
	override ruleStateRightPart() { "(" + source.lineNumber + ": " + source.formattedSourceCode + ")" }
	
}