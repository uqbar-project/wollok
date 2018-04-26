package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
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

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class GuessMinTypeFromMaxType extends SimpleTypeInferenceStrategy {
	
	val Logger log = Logger.getLogger(this.class)

	override walkThrougProgram() {
		changed = false
		allFiles.forEach[visit]
		globalChanged = changed
	}
		
	def dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		if (minTypes.isEmpty && maximalConcreteTypes !== null) {
			log.debug('''About to guess min types for «tvar.owner.debugInfoInContext»''')
			log.debug(tvar.fullDescription)
			maximalConcreteTypes.forEach[ type |
				val state = addMinType(type) 
				log.debug('''  Added min type «type» => «state»''')
				if (state == Pending) changed = true
			]
		}
	}

	// ************************************************************************
	// ** Interface with visitor 
	// ************************************************************************

	/** We will stop visits after a change is found */
	def dispatch shouldVisit(EObject e) { !changed && !e.isCoreObject }

	/** Handle nulls in multiple dispatch */
	def dispatch shouldVisit(Void it) { false }


	/** Execute actions before visiting child nodes */
	def beforeVisit(EObject e) {
		
	}

	/** Execute actions after visiting child nodes */
	def dispatch afterVisit(EObject it) {
		if (shouldVisit) analiseVariable(tvar)
	}

	// Avoid visiting objects that do not have associated type variables 
	def dispatch afterVisit(WFile it) {}
	def dispatch afterVisit(WProgram it) {}
	def dispatch afterVisit(WClass it) {}
	def dispatch afterVisit(WConstructor it) {}

	// ************************************************************************
	// ** Generic visiting construct 
	// ** (TODO extract them and join with AbstractWollokVisitor)
	// ************************************************************************

	/**
	 * Main method to be used to visit an object.
	 * Will check with the visiting algorithm to decide if we should continue or stop.
	 */
	def visit(EObject it) {
		if (shouldVisit) {
			beforeVisit
			visitChildren
			afterVisit
		}
	}

	/** Visit all nodes in an Iterable */
	def void visitAll(Iterable<? extends EObject> all) {
		all.forEach[visit]
	}

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
		// We are not generating type variables for the reference in an assignment.
		// Warning: if we generalize this algorithm we should not propagate this type-system-specific tuning to the generic version.
		// expr.feature.visit
		expr.value.visit
	}

	def dispatch void visitChildren(WBinaryOperation it){
		leftOperand.visit
		rightOperand.visit
	}

	def dispatch void visitChildren(WMemberFeatureCall it){
		memberCallTarget.visit
		memberCallArguments.visitAll
	}

	def dispatch void visitChildren(WVariableDeclaration it) {
		variable.visit
		right.visit
	}

	// i'm not sure why tests fails if we just let the generic WMethodContainer impl for all.
	def dispatch void visitChildren(WMethodContainer it) { eContents.visitAll }

	def dispatch void visitChildren(WMixin it) { eContents.visitAll }
	def dispatch void visitChildren(WSuite it) { eContents.visitAll }
	def dispatch void visitChildren(WClass it) { eContents.visitAll }
	def dispatch void visitChildren(WObjectLiteral it) { eContents.visitAll }
	def dispatch void visitChildren(WNamedObject it) { eContents.visitAll }
	def dispatch void visitChildren(WFixture it) { eContents.visitAll }

	def dispatch void visitChildren(WPackage it) { elements.visitAll }
	def dispatch void visitChildren(WUnaryOperation it) { operand.visit }
	def dispatch void visitChildren(WClosure it) { expression.visit }
	def dispatch void visitChildren(WConstructor it) { expression.visit }
	def dispatch void visitChildren(WMethodDeclaration it) {
		parameters.visitAll 
		expression.visit
	}

	def dispatch void visitChildren(WProgram it) { elements.visitAll }
	def dispatch void visitChildren(WTest it) { elements.visitAll }
	def dispatch void visitChildren(WSuperInvocation it) { memberCallArguments.visitAll }
	def dispatch void visitChildren(WConstructorCall it) {	arguments.visitAll }
	def dispatch void visitChildren(WCollectionLiteral it) { elements.visitAll }

	def dispatch void visitChildren(WBlockExpression it) { expressions.visitAll	}
	def dispatch void visitChildren(WPostfixOperation it) { operand.visit }
	def dispatch void visitChildren(WReturnExpression it) { expression.visit }

	// terminal elements
	def dispatch void visitChildren(WVariableReference it) { ref.visit }

	// terminals
	def dispatch void visitChildren(WReferenciable ref){}
	def dispatch void visitChildren(WNumberLiteral literal) {}
	def dispatch void visitChildren(WNullLiteral literal) {}
	def dispatch void visitChildren(WStringLiteral literal) {}
	def dispatch void visitChildren(WBooleanLiteral literal) {}
	def dispatch void visitChildren(WParameter param) {}
	def dispatch void visitChildren(WSelf wthis) {}
}
