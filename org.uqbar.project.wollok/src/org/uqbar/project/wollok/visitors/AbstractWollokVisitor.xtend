package org.uqbar.project.wollok.visitors

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedArgumentsList
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPositionalArgumentsList
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Implements an abstract visitor for the AST
 * 
 * @author tesonep
 * @author jfernandes
 * @author npasserini
 */
abstract class AbstractWollokVisitor {

	// ************************************************************************
	// ** Main structure 
	// ************************************************************************
	/**
	 * Main method to be used to visit an object.
	 * Will check with the visiting algorithm to decide if we should continue or stop.
	 */
	def visit(EObject it) {
		if(shouldContinue && shouldVisit) {
			beforeVisit
			visitChildren
			afterVisit
		}
	}

	/** Execute actions before visiting child nodes */
	def dispatch void beforeVisit(EObject it) {}
	def dispatch void beforeVisit(Void it) {}

	/** Execute actions after visiting child nodes */
	def dispatch void afterVisit(EObject it) {}
	def dispatch void afterVisit(Void it) {}

	// ************************************************************************
	// ** Filtering & premature stopping 
	// ************************************************************************
	/** 
	 * Override if you are not interested in some kind of nodes.
	 * Please note that their children will also be ignored.
	 */
	def dispatch shouldVisit(EObject e) { true }

	/** Handle nulls in multiple dispatch */
	def dispatch shouldVisit(Void it) { false }

	/**
	 * Lets subclasses to decide whether it is necessary to continue with execution.
	 * By default it always visits the whole program tree.
	 */
	def shouldContinue(EObject e) { true }

	/**
	 * Helper method for visiting a collection of EObjects
	 */
	def void visitAll(Iterable<? extends EObject> all) {
		all.forEach[visit]
	}

	/** Handle nulls in multiple dispatch */
	def dispatch void visitChildren(Void it) {}

	def dispatch void visitChildren(WFile it) {
		elements.visitAll
		main.visit
	}

	def dispatch void visitChildren(WIfExpression it) {
		condition.visit
		then.visit
		getElse.visit
	}

	def dispatch void visitChildren(WTry it) {
		expression.visit
		catchBlocks.visitAll
		alwaysExpression.visit
	}

	def dispatch void visitChildren(WThrow it) { exception.visit }
	def dispatch void visitChildren(WCatch it) { expression.visit }

	def dispatch void visitChildren(WAssignment expr) {
		expr.feature.visit
		expr.value.visit
	}

	def dispatch void visitChildren(WArgumentList args) {
		args.initializers.visitAll
		args.values.visitAll
	}

	def dispatch void visitChildren(WBinaryOperation it) {
		leftOperand.visit
		rightOperand.visit
	}

	def dispatch void visitChildren(WMemberFeatureCall it) {
		memberCallTarget.visit
		memberCallArguments.visitAll
	}

	def dispatch void visitChildren(WVariableDeclaration it) {
		// Visit the expression before the LHS.
		right.visit
		variable.visit
	}

	// i'm not sure why tests fails if we just let the generic WMethodContainer impl for all.
	def dispatch void visitChildren(WMethodContainer it) { eContents.visitAll }

	def dispatch void visitChildren(WMixin it) { eContents.visitAll }
	def dispatch void visitChildren(WSuite it) { eContents.visitAll }
	def dispatch void visitChildren(WClass it) { eContents.visitAll }
	def dispatch void visitChildren(WObjectLiteral it) { eContents.visitAll }
	def dispatch void visitChildren(WNamedObject it) { 
		eContents.visitAll
	}
	def dispatch void visitChildren(WFixture it) { eContents.visitAll }

	def dispatch void visitChildren(WPackage it) { elements.visitAll }
	def dispatch void visitChildren(WUnaryOperation it) { operand.visit }
	def dispatch void visitChildren(WClosure it) { expression.visit }
	def dispatch void visitChildren(WPositionalArgumentsList it) { values.visitAll }
	def dispatch void visitChildren(WMethodDeclaration it) { expression.visit }

	def dispatch void visitChildren(WProgram it) { elements.visitAll }
	def dispatch void visitChildren(WTest it) { elements.visitAll }
	def dispatch void visitChildren(WSuperInvocation it) { memberCallArguments.visitAll }
	def dispatch void visitChildren(WConstructorCall it) {
		argumentList.visit
	}

	def dispatch void visitChildren(WCollectionLiteral it) { elements.visitAll }

	def dispatch void visitChildren(WBlockExpression it) { expressions.visitAll }
	def dispatch void visitChildren(WPostfixOperation it) { operand.visit }
	def dispatch void visitChildren(WReturnExpression it) { expression.visit }

	// references
	def dispatch void visitChildren(WVariableReference it) {
		// Do nothing.
		// The contents of the reference have been visited elsewhere.
		// When referencing WKOs usually introduces stack overflows.
	}

	// terminal elements
	def dispatch void visitChildren(WNamedArgumentsList it) { initializers.visitAll }
	def dispatch void visitChildren(WInitializer i) {
		i.initializer.visit
		i.initialValue.visit
	}

	// terminals
	def dispatch void visitChildren(WReferenciable ref) {}
	def dispatch void visitChildren(WNumberLiteral literal) {}
	def dispatch void visitChildren(WNullLiteral literal) {}
	def dispatch void visitChildren(WStringLiteral literal) {}
	def dispatch void visitChildren(WBooleanLiteral literal) {}
	def dispatch void visitChildren(WParameter param) {}
	def dispatch void visitChildren(WSelf wthis) {}
}
