package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.isMultiOpAssignment

/**
 * This visitor get all the assignments of the lookedFor variable
 * @author tesonep
 * @author jfernandes
 * @author npasserini
 */
class VariableAssignmentsVisitor extends AbstractWollokVisitor {
	@Accessors
	List<EObject> uses = newArrayList
	List<WMethodDeclaration> methodsAlreadyVisited = newArrayList
	List<WConstructor> constructorsAlreadyVisited = newArrayList
	
	@Accessors
	WVariable lookedFor

	def static assignmentOf(WVariable lookedFor, EObject container) {
		(new VariableAssignmentsVisitor => [
			it.lookedFor = lookedFor
			visit(container)
		]).uses
	}

	// potatoe: specific methods to detect assignments
	def dispatch beforeVisit(WVariableDeclaration it) {
		addIf[variable == lookedFor && right !== null]
	}

	def dispatch beforeVisit(WDelegatingConstructorCall it) {
		val constructor = declaringContext.resolveConstructor(arguments)
		if (constructor !== null && !constructorsAlreadyVisited.contains(constructor)) {
			constructorsAlreadyVisited.add(constructor)
			constructor.visit
		}
	}
	
	def dispatch beforeVisit(WMemberFeatureCall it) {
		addIf[feature == lookedFor.name && memberCallArguments.size == 1 ]
		declaringContext?.findMethod(it)?.visit
	}
	
	def dispatch shouldVisit(WMethodDeclaration it) { !methodsAlreadyVisited.contains(it) }
	def dispatch beforeVisit(WMethodDeclaration it) { methodsAlreadyVisited.add(it) }
	
	def dispatch beforeVisit(WAssignment it) {
		addIf[feature.ref == lookedFor]
	}

	def dispatch beforeVisit(WPostfixOperation it) {
		addIf[operand.isReferenceTo(lookedFor)]
	}

	def dispatch beforeVisit(WBinaryOperation it) {
		addIf[isMultiOpAssignment && leftOperand.isReferenceTo(lookedFor)]
	}
	
	def dispatch beforeVisit(WInitializer it) {
		addIf [ initializer.name == lookedFor.name ]
	}

	// helpers
	protected def <T extends EObject> addIf(T it, (T)=>Boolean condition) {
		if (condition.apply(it))
			uses.add(it)
	}

	def static dispatch isReferenceTo(WExpression it, WVariable variable) { false }
	def static dispatch isReferenceTo(WVariableReference it, WVariable variable) { ref == variable }
}
