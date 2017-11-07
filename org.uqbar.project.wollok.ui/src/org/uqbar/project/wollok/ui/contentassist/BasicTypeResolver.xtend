package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Really basic impl while we don't have the type system.
 * Just solves types for literals.
 * 
 * @author jfernandes
 */
class BasicTypeResolver {
	extension WollokClassFinder classFinder = WollokClassFinder.getInstance
	
	def dispatch WMethodContainer resolveType(WVariable variable) {
		if (variable.declaration.right === null)
			null
		else
			variable.declaration.right.resolveType
	}
	
	def dispatch WMethodContainer resolveType(WListLiteral it) { listClass }
	def dispatch WMethodContainer resolveType(WSetLiteral it) { setClass }
	def dispatch WMethodContainer resolveType(WStringLiteral it) { stringClass }
	def dispatch WMethodContainer resolveType(WBooleanLiteral it) { booleanClass }
	def dispatch WMethodContainer resolveType(WNumberLiteral it) { if (value.contains(".")) doubleClass else integerClass }
	def dispatch WMethodContainer resolveType(WConstructorCall it) { classRef }
	def dispatch WMethodContainer resolveType(WMethodContainer it) { it }
	def dispatch WMethodContainer resolveType(EObject it) { objectClass }
	def dispatch WMethodContainer resolveType(WVariableReference it) { ref.resolveType }
	
}