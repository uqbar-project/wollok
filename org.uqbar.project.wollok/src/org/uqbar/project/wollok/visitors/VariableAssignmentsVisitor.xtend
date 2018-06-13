package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
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
 * @author	tesonep
 * @author jfernandes
 */
class VariableAssignmentsVisitor extends AbstractWollokVisitor {
	@Accessors
	List<EObject> uses = newArrayList
	List<WMethodDeclaration> methodsAlreadyVisited = newArrayList
	List<WConstructor> constructorsAlreadyVisited = newArrayList
	
	@Accessors
	WVariable lookedFor

	// generic visitor methods
	override doVisit(EObject e) {
		if (e !== null) {
			visit(e)
		}
	}

	def static assignmentOf(WVariable lookedFor, EObject container) {
		(new VariableAssignmentsVisitor => [
			it.lookedFor = lookedFor
			doVisit(container)
		]).uses
	}

	// potatoe: specific methods to detect assignments
	override dispatch visit(WVariableDeclaration it) {
		addIf[variable == lookedFor && right !== null]
	}

	override dispatch visit(WConstructor it) {
		doVisit(expression)

		if (delegatingConstructorCall !== null) {
			doVisit(delegatingConstructorCall)
		}
	}

	def dispatch visit(WDelegatingConstructorCall it) {
		val constructor = declaringContext.resolveConstructor(arguments)
		if (constructor !== null && !constructorsAlreadyVisited.contains(constructor)) {
			constructorsAlreadyVisited.add(constructor)
			constructor.doVisit
		}
	}
	
	override dispatch visit(WBlockExpression it) {
		expressions.forEach [ expression |
			doVisit(expression)
		]
	}
	
	override dispatch visit(WMemberFeatureCall it) {
		addIf[feature == lookedFor.name && memberCallArguments.size == 1 ]
		val method = declaringContext?.findMethod(it)
		if (method !== null) {
			doVisit(method)
		}
	}
	
	override dispatch visit(WMethodDeclaration it) {
		if (methodsAlreadyVisited.contains(it)) return;
		methodsAlreadyVisited.add(it)
		doVisit(expression)
	}
	
	override dispatch visit(WAssignment it) {
		addIf[feature.ref == lookedFor]
	}

	override dispatch visit(WPostfixOperation it) {
		addIf[operand.isReferenceTo(lookedFor)]
	}

	override dispatch visit(WBinaryOperation it) {
		addIf[isMultiOpAssignment && leftOperand.isReferenceTo(lookedFor)]
	}
	
	override dispatch visit(WInitializer it) {
		addIf [ initializer.name == lookedFor.name ]
	}

	// helpers
	protected def <T extends EObject> addIf(T it, (T)=>Boolean condition) {
		if (condition.apply(it))
			uses.add(it)
	}

	def static isReferenceTo(WExpression it, WVariable variable) {
		it instanceof WVariableReference && (it as WVariableReference).ref == variable
	}

	// I'm not sure if this is a hack
	// why visiting the content of the reference ?
	// in a WKO referencing itself was introducing a stackoverflow
	override dispatch void visit(WVariableReference it) {
		// does nothing ! 
	}

}
