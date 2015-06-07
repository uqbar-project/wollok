package org.uqbar.project.wollok.model

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.visitors.VariableAssignmentsVisitor
import org.uqbar.project.wollok.visitors.VariableUsesVisitor
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import wollok.lang.Exception
import org.uqbar.project.wollok.wollokDsl.WConstructor

/**
 * Extension methods to Wollok semantic model.
 * 
 * @author jfernandes
 * @author npasserini
 * @author tesonep
 */
class WollokModelExtensions {

	def static boolean isException(WClass it) { fqn == Exception.name || (parent != null && parent.exception) }

	def static fqn(WClass it) { (if (package != null) (package.name + ".") else "") + name }
	def static fqn(WNamedObject it) {
		 if(package != null) package.name + "." + name
		 else name
	}

	def static WPackage getPackage(WClass it) { if(eContainer instanceof WPackage) eContainer as WPackage else null }
	def static WPackage getPackage(WNamedObject it) { if(eContainer instanceof WPackage) eContainer as WPackage else null }

	def static boolean isSuperTypeOf(WClass a, WClass b) {
		a == b || (b.parent != null && a.isSuperTypeOf(b.parent))
	}

	// *******************
	// ** WReferenciable
	// *******************
	def static dispatch isModifiableFrom(WVariable v, WAssignment from) { v.declaration.writeable || from.initializesInstanceValueFromConstructor(v) }
	def static dispatch isModifiableFrom(WParameter v, WAssignment from) { false }
	def static dispatch isModifiableFrom(WReferenciable v, WAssignment from) { true }
	
	def static boolean initializesInstanceValueFromConstructor(WAssignment a, WVariable v) {
		v.declaration.right == null && a.isWithinConstructor 
	}
	
	def static boolean isWithinConstructor(EObject e) {
		e.eContainer != null && (e.eContainer instanceof WConstructor || e.eContainer.isWithinConstructor)
	}

	/*
	 * Uses of a Variable
	 */
	def static uses(WVariable variable) { VariableUsesVisitor.usesOf(variable, variable.declarationContext) }

	def static assignments(WVariable variable) {
		VariableAssignmentsVisitor.assignmentOf(variable, variable.declarationContext)
	}

	def static declaration(WVariable variable) { variable.eContainer as WVariableDeclaration }

	def static declarationContext(WVariable variable) { variable.declaration.eContainer }

	// **********************
	// ** access containers
	// **********************
	def static dispatch WBlockExpression block(WBlockExpression b) { b }

	def static dispatch WBlockExpression block(EObject b) { b.eContainer.block }

	def static closure(WParameter p) { p.eContainer as WClosure }

	// ojo podría ser un !ObjectLiteral
	def static declaringContext(WMethodDeclaration m) { m.eContainer as WMethodContainer } //

	def static void addMembersTo(WClass cl, WollokObject wo) { cl.members.forEach[wo.addMember(it)] }

	// se puede ir ahora que esta bien la jerarquia de WReferenciable (?)
	def dispatch messagesSentTo(WVariable v) { v.allMessageSent }

	def dispatch messagesSentTo(WParameter p) { p.allMessageSent }

	def static allMessageSent(WReferenciable r) { r.eContainer.allMessageSentTo(r) }

	def static allMessageSentTo(EObject context, WReferenciable ref) {
		context.allCalls.filter[c|c.isCallOnVariableRef && (c.memberCallTarget as WVariableReference).ref == ref]
	}

	def static allCalls(EObject context) { context.eAllContents.filter(WMemberFeatureCall) }

	def static isCallOnVariableRef(WMemberFeatureCall c) { c.memberCallTarget instanceof WVariableReference }

	def static isCallOnThis(WMemberFeatureCall c) { c.memberCallTarget instanceof WThis }


	def static isValidMessage(WMethodDeclaration m, WMemberFeatureCall call) {
		m.name == call.feature && m.parameters.size == call.memberCallArguments.size
	}

	def static isValidConstructorCall(WConstructorCall c) {
		c.numberOfParameters == c.classRef.numberOfParameters
	}

	def static numberOfParameters(WConstructorCall c) { if(c.arguments == null) 0 else c.arguments.size }

	def static numberOfParameters(WClass c) { if(c.constructor == null) 0 else c.constructor.parameters.size }

	// For objects or classes
	def static dispatch declaredVariables(WObjectLiteral obj) { obj.members.filter(WVariableDeclaration).map[variable] }

	def static dispatch declaredVariables(WClass clazz) { clazz.members.filter(WVariableDeclaration).map[variable] }

	def static WMethodDeclaration method(WExpression param) {
		val container = param.eContainer
		if (container instanceof WMethodDeclaration)
			container
		else if(container instanceof WExpression) container.method
			// this is just a hack for expressions that are not within a method! Specifically
		// for expressions in the root level of a file, like an interpreted program
		// we are actually thinking on disallowing to do that, you won't be able to write
		// any expression alone in a file. They must be within a class, object or other construction
		// if we perform that change, then this null won't be necessary.
		else null
	}

	// ****************************
	// ** transparent containers (in terms of debugging -maybe also could be used for visualizing, like outline?-)
	// ****************************
	// containers
	def static dispatch isTransparent(EObject o) { false }

	def static dispatch isTransparent(WTry o) { true }

	def static dispatch isTransparent(WBlockExpression o) { true }

	def static dispatch isTransparent(WIfExpression o) { true }

	// literals or leafs
	def static dispatch isTransparent(WThis o) { true }

	def static dispatch isTransparent(WNumberLiteral o) { true }

	def static dispatch isTransparent(WStringLiteral o) { true }

	def static dispatch isTransparent(WBooleanLiteral o) { true }

	def static dispatch isTransparent(WObjectLiteral o) { true }

	def static dispatch isTransparent(WCollectionLiteral o) { true }

	def static dispatch isTransparent(WVariableReference o) { true }

	def static dispatch isTransparent(WBinaryOperation o) { true }

	def static IFile getIFile(EObject obj) {
		val platformString = obj.eResource.URI.toPlatformString(true)
		ResourcesPlugin.workspace.root.getFile(new Path(platformString))
	}

}
