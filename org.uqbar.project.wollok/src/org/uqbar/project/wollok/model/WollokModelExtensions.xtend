
package org.uqbar.project.wollok.model

import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.visitors.VariableAssignmentsVisitor
import org.uqbar.project.wollok.visitors.VariableUsesVisitor
import org.uqbar.project.wollok.wollokDsl.Import
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
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamed
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage
import wollok.lang.Exception

import static extension org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator.hookObjectInHierarhcy
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * Extension methods to Wollok semantic model.
 * 
 * @author jfernandes
 * @author npasserini
 * @author tesonep
 */
class WollokModelExtensions {
	
	def static fileName(EObject it) {
		file.URI.trimFileExtension.lastSegment
	}
	def static file(EObject it) { eResource }

	def static boolean isException(WClass it) { fqn == Exception.name || (parent != null && parent.exception) }

	def static dispatch name(WClass it) { name }
	def static dispatch name(WNamedObject it) { name }
	def static dispatch name(WObjectLiteral it) { "anonymousObject" }

	def static dispatch fqn(WClass it) { 
		fileName + "." + (if (package != null) (package.name + ".") else "") + name
	}
	def static dispatch fqn(WNamedObject it) {
		 fileName + "." + 
		 	if(package != null) package.name + "." + name
		 		else name
	}
	
	def static dispatch fqn(WObjectLiteral it) {
		//TODO: make it better (show containing class /object / package + linenumber ?)
		fileName + "." + "anonymousObject" 
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
	
	def static WClass getWollokClass(EObject it) { EcoreUtil2.getContainerOfType(it, WClass) }
	
	def static dispatch WBlockExpression block(WBlockExpression b) { b }

	def static dispatch WBlockExpression block(EObject b) { b.eContainer.block }
	
	def static first(WBlockExpression it, Class type) { expressions.findFirst[ type.isInstance(it) ] }

	def static closure(WParameter p) { p.eContainer as WClosure }

	// ojo podría ser un !ObjectLiteral
	def static declaringContext(WMethodDeclaration m) { m.eContainer as WMethodContainer } //

	def static void addMembersTo(WClass cl, WollokObject wo) { cl.members.forEach[wo.addMember(it)] }

	// se puede ir ahora que esta bien la jerarquia de WReferenciable (?)
	def dispatch messagesSentTo(WVariable v) { v.allMessageSent }
	def dispatch messagesSentTo(WParameter p) { p.allMessageSent }

	def static Iterable<WMemberFeatureCall> allMessageSent(WReferenciable r) { r.eContainer.allMessageSentTo(r) + r.allMessagesToRefsWithSameNameAs}

	def static List<WMemberFeatureCall> allMessageSentTo(EObject context, WReferenciable ref) {
		context.allCalls.filter[c|c.isCallOnVariableRef && (c.memberCallTarget as WVariableReference).ref == ref].toList
	}
	
	// heuristic: add's messages sent to other parameters with the same name
	def static dispatch Iterable<WMemberFeatureCall> allMessagesToRefsWithSameNameAs(WParameter ref) {
		ref.declaringContext.methods.map[ parameters ].flatten.filter[ name == ref.name && it != ref ].map[ eContainer.allMessageSentTo(it) ].flatten
	}
	def static dispatch Iterable<WMemberFeatureCall> allMessagesToRefsWithSameNameAs(WReferenciable it) { #[] }

	def static allCalls(EObject context) { context.eAllContents.filter(WMemberFeatureCall) }

	def static isCallOnVariableRef(WMemberFeatureCall c) { c.memberCallTarget instanceof WVariableReference }

	def static isCallOnThis(WMemberFeatureCall c) { c.memberCallTarget instanceof WThis }
	
	def static WMethodDeclaration resolveMethod(WMemberFeatureCall it, WollokClassFinder finder) {
		if (isCallOnThis) 
			method.declaringContext.findMethod(it)
		else if (isCallToWellKnownObject)
			resolveWKO(finder).findMethod(it)
		else
		 // TODO: call to super (?)
		 	null
	}
	
	
	
	def static isCallToWellKnownObject(WMemberFeatureCall c) { c.memberCallTarget.isWellKnownObject }

	def static dispatch boolean isWellKnownObject(EObject it) { false }
	def static dispatch boolean isWellKnownObject(WVariableReference it) { ref.isWellKnownObject }
	def static dispatch boolean isWellKnownObject(WNamedObject it) { true }
	def static dispatch boolean isWellKnownObject(WReferenciable it) { false }
	
	def static isValidCallToWKObject(WMemberFeatureCall it, WollokClassFinder finder) { resolveWKO(finder).isValidCall(it, finder) }
	
	def static resolveWKO(WMemberFeatureCall it, WollokClassFinder finder) { 
		val obj = (memberCallTarget as WVariableReference).ref as WNamedObject
		obj.hookObjectInHierarhcy(finder)
		obj
	}


	def static isValidMessage(WMethodDeclaration it, WMemberFeatureCall call) {
		matches(call.feature, call.memberCallArguments)
	}

	def static isValidConstructorCall(WConstructorCall c) {
		c.classRef.hasConstructorForArgs(c.numberOfParameters)
	}
	
	def static numberOfParameters(WConstructorCall c) { if(c.arguments == null) 0 else c.arguments.size }

	def static hasConstructorDefinitions(WClass c) { c.constructors != null && c.constructors.size > 0 }

	def static hasConstructorForArgs(WClass c, int nrOfArgs) {
		(nrOfArgs == 0 && !c.hasConstructorDefinitions) || c.constructors.exists[matches(nrOfArgs)] 
	}
	
	def static matches(WConstructor it, int nrOfArgs) { 
		if (hasVarArgs)
			nrOfArgs >= parameters.filter[!isVarArg].size
		else
			nrOfArgs == parameters.size
	}
	
	def static dispatch hasVarArgs(WConstructor it) { parameters.exists[isVarArg] }
	def static dispatch hasVarArgs(WMethodDeclaration it) { parameters.exists[isVarArg] }
	
	def static superClassRequiresNonEmptyConstructor(WClass it) { parent != null && !parent.hasEmptyConstructor }
	def static superClassRequiresNonEmptyConstructor(WNamedObject it) { parent != null && !parent.hasEmptyConstructor }
	
	def static hasEmptyConstructor(WClass c) { !c.hasConstructorDefinitions || c.hasConstructorForArgs(0) }

	// For objects or classes
	def static dispatch declaredVariables(WObjectLiteral obj) { obj.members.filter(WVariableDeclaration).map[variable] }
	def static dispatch declaredVariables(WNamedObject obj) { obj.members.filter(WVariableDeclaration).map[variable] }
	def static dispatch declaredVariables(WClass clazz) { clazz.members.filter(WVariableDeclaration).map[variable] }

	def static dispatch WMethodDeclaration method(Void it) { null }
	def static dispatch WMethodDeclaration method(EObject it) { null }
	def static dispatch WMethodDeclaration method(WMethodDeclaration it) { it }
	def static dispatch WMethodDeclaration method(WExpression it) { eContainer.method }

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
		if (platformString == null) {
			// could be a synthetic file
			return null;
		}
		ResourcesPlugin.workspace.root.getFile(new Path(platformString))
	}
	
	// ******************************
	// ** is duplicated impl
	// ******************************
	
	def static boolean isDuplicated(WReferenciable reference) {
		reference.eContainer.isDuplicated(reference)
	}

	// Root objects (que no tiene acceso a variables fuera de ellos)
	def static dispatch boolean isDuplicated(WFile f, WNamedObject o) { f.elements.existsMoreThanOne(o) }
	def static dispatch boolean isDuplicated(WFile f, WClass c) { f.elements.existsMoreThanOne(c) }
	
	def static dispatch boolean isDuplicated(WClass c, WReferenciable v) { c.variables.existsMoreThanOne(v) }
	def static dispatch boolean isDuplicated(WProgram p, WReferenciable v) {  p.variables.existsMoreThanOne(v) }
	def static dispatch boolean isDuplicated(WTest p, WReferenciable v) { p.variables.existsMoreThanOne(v) }
	def static dispatch boolean isDuplicated(WNamedObject c, WReferenciable r) { c.variables.existsMoreThanOne(r) }

	def static dispatch boolean isDuplicated(WPackage it, WNamedObject r){ namedObjects.existsMoreThanOne(r) }
	def static dispatch boolean isDuplicated(WMethodDeclaration it, WReferenciable v) { parameters.existsMoreThanOne(v) || declaringContext.isDuplicated(v) }
	def static dispatch boolean isDuplicated(WBlockExpression it, WReferenciable v) { expressions.existsMoreThanOne(v) || eContainer.isDuplicated(v) }
	def static dispatch boolean isDuplicated(WClosure it, WReferenciable r) { parameters.existsMoreThanOne(r) || eContainer.isDuplicated(r) }
	def static dispatch boolean isDuplicated(WConstructor it, WReferenciable r) { parameters.existsMoreThanOne(r) || eContainer.isDuplicated(r) }
	// default case is to delegate up to container
	def static dispatch boolean isDuplicated(EObject it, WReferenciable r) { eContainer.isDuplicated(r) }
	
	def static dispatch existsMoreThanOne(Iterable<?> exps, WReferenciable ref) {
		exps.filter(WReferenciable).exists[it != ref && name == ref.name]
	}

	def static dispatch existsMoreThanOne(Iterable<?> exps, WNamed named) {
		exps.filter(WReferenciable).exists[it != named && name == named.name]
	}
	
	def static dispatch boolean isInConstructor(EObject obj) { obj.eContainer != null && obj.eContainer.inConstructor }
	def static dispatch boolean isInConstructor(WConstructor obj) { true }
	def static dispatch boolean isInConstructor(WClass obj){ false }
	def static dispatch boolean isInConstructor(WMethodDeclaration obj) { false }
	
	// *****************************
	// ** valid return
	// *****************************
	
	def static dispatch boolean returnsOnAllPossibleFlows(WMethodDeclaration it) { expressionReturns || expression.returnsOnAllPossibleFlows }
	def static dispatch boolean returnsOnAllPossibleFlows(WReturnExpression it) { true }
	def static dispatch boolean returnsOnAllPossibleFlows(WThrow it) { true }
	def static dispatch boolean returnsOnAllPossibleFlows(WBlockExpression it) { expressions.last.returnsOnAllPossibleFlows }
	def static dispatch boolean returnsOnAllPossibleFlows(WIfExpression it) { then.returnsOnAllPossibleFlows && ^else != null && ^else.returnsOnAllPossibleFlows }
	def static dispatch boolean returnsOnAllPossibleFlows(WTry it) { expression.returnsOnAllPossibleFlows && catchBlocks.forall[c | c.returnsOnAllPossibleFlows ] }
	def static dispatch boolean returnsOnAllPossibleFlows(WCatch it) { expression.returnsOnAllPossibleFlows }
	def static dispatch boolean returnsOnAllPossibleFlows(Void it) { false } // ?
	def static dispatch boolean returnsOnAllPossibleFlows(WExpression it) { false }
	
	
	def static tri(WCatch it) { eContainer as WTry }
	def static catchesBefore(WCatch it) { tri.catchBlocks.subList(0, tri.catchBlocks.indexOf(it)) }
	
	// *******************************
	// ** imports
	// *******************************
	
	def static importedNamespaceWithoutWildcard(Import it) { if (importedNamespace.endsWith(".*")) importedNamespace.substring(0, importedNamespace.length - 2) else importedNamespace }
	def static toFQN(String string) { QualifiedName.create(string.split("\\.")) }
	// hack uses another grammar ereference to any
	def static getScope(Import it, WollokGlobalScopeProvider scopeProvider) { scopeProvider.getScope(eResource, WollokDslPackage.Literals.WCLASS__PARENT) }
	def static upTo(Import it, String segment) { importedNamespace.substring(0, importedNamespace.indexOf(segment) + segment.length) }
}
