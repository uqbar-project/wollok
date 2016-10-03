package org.uqbar.project.wollok.model

import java.util.Arrays
import java.util.Collections
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.uqbar.project.wollok.interpreter.MixedMethodContainer
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSelfDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.uqbar.project.wollok.wollokDsl.Invariant

/**
 * Extension methods for WMethodContainers.
 *
 * @author jfernandes
 * @author npasserini
 */
class WMethodContainerExtensions extends WollokModelExtensions {

	def static WMethodContainer declaringContext(EObject it) { EcoreUtil2.getContainerOfType(it, WMethodContainer) }

	def static namedObjects(WPackage p){p.elements.filter(WNamedObject)}
	def static namedObjects(WFile p){p.elements.filter(WNamedObject)}

	def static boolean isAbstract(WMethodContainer it) { !unimplementedAbstractMethods.empty }

	def static unimplementedAbstractMethods(WMethodContainer it) { allAbstractMethods }

	def static boolean isAbstract(WMethodDeclaration it) { expression == null && !native }

	def static dispatch parameters(WMethodDeclaration it) { parameters }
	def static dispatch parameters(WConstructor it) { parameters }

	// rename: should be non-implemented abstract methods
	def static allAbstractMethods(WMethodContainer c) {
		val hierarchy = c.linearizateHierarhcy

		val concreteMethods = <WMethodDeclaration>newArrayList

		hierarchy.reverse.fold(<WMethodDeclaration>newArrayList) [unimplementedMethods, chunk |
			concreteMethods.addAll(chunk.methods.filter[!abstract])
			// remove implemented
			unimplementedMethods.removeIf[chunk.overrides(it)]
			// add NEW abstracts (abstracts on mixins can be overriden by an upper class / mixin in the chain!)
			val newAbstractsNotImplementedUpInTheHierarchy = chunk.abstractMethods.filter[abstractM |
				!concreteMethods.exists[m| abstractM.matches(m.name, m.parameters) ]
			]
			unimplementedMethods.addAll(newAbstractsNotImplementedUpInTheHierarchy)
			unimplementedMethods
		]
	}

	def static getAllMessageSentToThis(WMethodContainer it) {
		eAllContents.filter(WMemberFeatureCall).filter[memberCallTarget.isThis].toIterable
	}

	def static dispatch isThis(WSelf it) { true }
	def static dispatch isThis(EObject it) { false }

	def static boolean isNative(WMethodContainer it) { methods.exists[m|m.native] }

	def static methods(WMethodContainer c) { c.members.filter(WMethodDeclaration) }
	def static abstractMethods(WMethodContainer it) { methods.filter[isAbstract] }
	def static overrideMethods(WMethodContainer it) { methods.filter[overrides].toList }

	def static dispatch boolean overrides(WMethodContainer c, WMethodDeclaration m) { c.overrideMethods.exists[matches(m.name, m.parameters.size)] }
	// mixins can be overriding a method without explicitly declaring it
	def static dispatch boolean overrides(WMixin c, WMethodDeclaration m) { c.methods.exists[!abstract && matches(m.name, m.parameters.size)] }

	def static declaringMethod(WParameter p) { p.eContainer as WMethodDeclaration }
	def static overridenMethod(WMethodDeclaration m) { m.declaringContext.overridenMethod(m.name, m.parameters) }
	def protected static overridenMethod(WMethodContainer it, String name, List parameters) {
		lookUpMethod(linearizateHierarhcy.tail, name, parameters, true)
	}

	def static superMethod(WSuperInvocation it) { method.overridenMethod }

	def static supposedToReturnValue(WMethodDeclaration it) { expressionReturns || eAllContents.exists[e | e.isReturnWithValue] }
	def static hasSameSignatureThan(WMethodDeclaration it, WMethodDeclaration other) { matches(other.name, other.parameters) }

	def static isGetter(WMethodDeclaration it) { name.length > 4 && name.startsWith("get") && Character.isUpperCase(name.charAt(3)) }

	def dispatch static isReturnWithValue(EObject it) { false }
	// REVIEW: this is a hack solution. We don't want to compute "return" statements that are
	//  within a closure as a return on the containing method.
	def dispatch static isReturnWithValue(WReturnExpression it) { expression != null && allContainers.forall[!(it instanceof WClosure)] }

	def dispatch static hasReturnWithValue(WReturnExpression e) { e.isReturnWithValue }
	def dispatch static hasReturnWithValue(EObject e) { e.eAllContents.exists[isReturnWithValue] }

	def static variableDeclarations(WMethodContainer c) { c.members.filter(WVariableDeclaration) }

	def static variables(WMethodContainer c) { c.variableDeclarations.variables }
	def static variables(WProgram p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(WTest p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(Iterable<WVariableDeclaration> declarations) { declarations.map[variable] }

	def static findMethod(WMethodContainer c, WMemberFeatureCall it) {
		c.allMethods.findFirst[m | m.matches(feature, memberCallArguments) ]
	}

	def static dispatch Iterable<WMethodDeclaration> allMethods(WMixin it) { methods }
	def static dispatch Iterable<WMethodDeclaration> allMethods(WNamedObject it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allMethods(WObjectLiteral it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allMethods(MixedMethodContainer it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allMethods(WClass c) {
		val methods = newArrayList
		// TODO: should we replace this with the "linearization()" method call ?
		c.superClassesIncludingYourselfTopDownDo[cl |
			// remove overriden
			cl.overrideMethods.forEach[methods.remove(it.overridenMethod)]
			// add all
			methods.addAll(cl.methods)
		]
		methods
	}

	def static getInheritedMethods(WMethodContainer it) {
		linearizateHierarhcy.fold(newArrayList) [methods, type |
			val currents = type.methods
			val newMethods = currents.filter[m | ! methods.exists[m2 | m.matches(m2.name, m2.parameters)]]
			methods.addAll(newMethods)
			methods
		]
	}

	def static actuallyOverrides(WMethodDeclaration m) {
		m.declaringContext != null && inheritsMethod(m.declaringContext, m.name, m.parameters.size)
	}

	def static parents(WMethodContainer c) { _parents(c.parent, newArrayList) }
	def static List<WClass> _parents(WClass c, List<WClass> l) {
		if (c == null) {
			return l
		}
		l.add(c)
		return _parents(c.parent, l)
	}

	def static dispatch WClass parent(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch WClass parent(WClass it) { parent }
	def static dispatch WClass parent(WObjectLiteral it) { parent } // can we just reply with wollok.lang.Object class ?
	def static dispatch WClass parent(WNamedObject it) { parent }
	def static dispatch WClass parent(MixedMethodContainer it) { clazz }
	// not supported yet !
	def static dispatch WClass parent(WMixin it) { null }

	def static dispatch List<WMixin> mixins(WMethodContainer it) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch List<WMixin> mixins(WClass it) { mixins }
	def static dispatch List<WMixin> mixins(WObjectLiteral it) { mixins } // can we just reply with wollok.lang.Object class ?
	def static dispatch List<WMixin> mixins(WNamedObject it) { mixins }
	def static dispatch List<WMixin> mixins(MixedMethodContainer it) { mixins }
	def static dispatch List<WMixin> mixins(WMixin it) { Collections.EMPTY_LIST }

	def static dispatch members(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch members(WClass c) { c.members }
	def static dispatch members(WObjectLiteral c) { c.members }
	def static dispatch members(WNamedObject c) { c.members }
	def static dispatch members(MixedMethodContainer c) { #[] }
	def static dispatch members(WMixin c) { c.members }

	def static dispatch contextName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch contextName(WClass c) { c.fqn }
	def static dispatch contextName(WObjectLiteral c) { "<anonymousObject>" }
	def static dispatch contextName(WNamedObject c) { c.fqn }
	def static dispatch contextName(MixedMethodContainer c) { "<mixedObejct>" }
	def static dispatch contextName(WMixin c) { c.fqn }

	def static boolean inheritsMethod(WMethodContainer it, String name, int argSize) {
		(mixins != null && mixins.exists[m| m.hasOrInheritMethod(name, argSize)])
		|| (parent != null && parent.hasOrInheritMethod(name, argSize))
	}

	def static boolean hasOrInheritMethod(WMethodContainer c, String mname, int argsSize) {
		c != null && (c.methods.exists[matches(mname, argsSize)] || c.parent.hasOrInheritMethod(mname, argsSize))
	}

	def static WMethodDeclaration lookupMethod(WMethodContainer behavior, String message, List params, boolean acceptsAbstract) {
		lookUpMethod(behavior.linearizateHierarhcy, message, params, acceptsAbstract)
	}

	def static lookUpMethod(Iterable<WMethodContainer> hierarchy, String message, List params, boolean acceptsAbstract) {
		for (chunk : hierarchy) {
			val method = chunk.methods.findFirst[ (!it.abstract || acceptsAbstract) && matches(message, params)]
			if (method != null)
				return method;
		}
		null
	}

	/**
	 * The full hierarchy chain top->down
	 */
	def static List<WMethodContainer> linearizateHierarhcy(WMethodContainer it) {
		var chain = newLinkedList
		chain.add(it)
		if (mixins != null) {
			chain.addAll(mixins.clone.reverse)
		}
		if (parent != null)
			chain.addAll(parent.linearizateHierarhcy)
		chain
	}

	def static matches(WMethodDeclaration it, String message, List params) { matches(message, params.size) }

	def static matches(WMethodDeclaration it, String message, int nrOfArgs) {
		name == message &&
		if (hasVarArgs)
			nrOfArgs >= parameters.filter[!isVarArg].size
		else
			nrOfArgs == parameters.size
	}

	// all calls to 'this' are valid in mixins
//	def static dispatch boolean isValidCall(WMixin it, WMemberFeatureCall call, WollokClassFinder finder) { true }
	def static dispatch boolean isValidCall(WMethodContainer c, WMemberFeatureCall call, WollokClassFinder finder) {
		c.allMethods.exists[isValidMessage(call)] || (c.parent != null && c.parent.isValidCall(call, finder))
	}

	// ************************************************************************
	// ** Basic methods
	// ************************************************************************

	def static superClassesIncludingYourself(WClass cl) {
		val classes = newArrayList
		cl.superClassesIncludingYourselfTopDownDo[classes.add(it)]
		classes
	}

	def static void superClassesIncludingYourselfTopDownDo(WClass cl, (WClass)=>void action) {
		if (cl.parent != null) cl.parent.superClassesIncludingYourselfTopDownDo(action)
		action.apply(cl)
	}

	def static <R> R foldUp(WClass cl, R initialValue, (R, WClass)=>R action) {
		val nextValue = action.apply(initialValue, cl)
		if (cl.parent != null)
			cl.parent.foldUp(nextValue, action)
		else
			nextValue
	}

	def static dispatch feature(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }
	def static dispatch feature(WMemberFeatureCall call) { call.feature }
	def static dispatch feature(WSuperInvocation call) { call.method.name }

	// TODO Esto no debería ser necesario pero no logro generar bien la herencia entre estas clases para poder tratarlas polimórficamente.
	def static dispatch memberCallArguments(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }
	def static dispatch memberCallArguments(WMemberFeatureCall call) { call.memberCallArguments }
	def static dispatch memberCallArguments(WSuperInvocation call) { call.memberCallArguments }

	// ************************************************************************
	// ** isKindOf(c1, c2): Tells whether c1 is a type or subtype of c2
	// ** TODO: think if this can be a
	// ************************************************************************

	def static dispatch isKindOf(WMethodContainer c1, WMethodContainer c2) { c1 == c2 }
	def static dispatch isKindOf(WClass c1, WClass c2) { WollokModelExtensions.isSuperTypeOf(c2, c1) }

	def static dispatch WConstructor resolveConstructor(WClass clazz, Object[] arguments) {
		if (arguments.size == 0 && (clazz.constructors == null || clazz.constructors.empty))
			// default constructor
			clazz.findConstructorInSuper(arguments)
		else {
			val c = clazz.constructors.findFirst[ matches(arguments.size) ]
			if (c == null)
				throw new WollokRuntimeException('''No constructor in class «clazz.name» for parameters «Arrays.toString(arguments)»''');
			c
		}
	}

	def static dispatch WConstructor resolveConstructor(WNamedObject obj, Object... arguments) {
		obj.parent.resolveConstructor(arguments)
	}
	def static dispatch WConstructor resolveConstructor(MixedMethodContainer obj, Object... arguments) {
		obj.clazz.resolveConstructor(arguments)
	}
	
	def static dispatch WConstructor resolveConstructor(WMethodContainer otherContainer, Object... arguments) {
		throw new WollokRuntimeException('''Impossible to call a constructor on anything besides a class''');
	}


	// ************************************************************************
	// ** Constructors delegation, etc.
	// ************************************************************************

	def static dispatch resolveConstructorReference(WMethodContainer behave, WSelfDelegatingConstructorCall call) { behave.resolveConstructor(call.arguments) }
	def static dispatch resolveConstructorReference(WMethodContainer behave, WSuperDelegatingConstructorCall call) { findConstructorInSuper(behave, call.arguments) }

	def static findConstructorInSuper(WMethodContainer behave, Object[] args) {
		(behave as WClass).parent?.resolveConstructor(args)
	}

	// ************************************************************************
	// ** unorganized
	// ************************************************************************

	def static dispatch boolean getIsReturnTrue(WExpression it) { false }
	def static dispatch boolean getIsReturnTrue(WBlockExpression it) { expressions.size == 1 && expressions.get(0).isReturnTrue }
	def static dispatch boolean getIsReturnTrue(WReturnExpression it) { expression instanceof WBooleanLiteral && expression.isReturnTrue }
	def static dispatch boolean getIsReturnTrue(WBooleanLiteral it) { isTrueLiteral }
	
	def static dispatch isTrueLiteral(WBooleanLiteral it) { isIsTrue }
	def static dispatch isTrueLiteral(WExpression it) { false }
	
	def static dispatch isFalseLiteral(WBooleanLiteral it) { !isIsTrue }
	def static dispatch isFalseLiteral(WExpression it) { false }

	def static dispatch boolean evaluatesToBoolean(WExpression it) { false }
	def static dispatch boolean evaluatesToBoolean(WBlockExpression it) { expressions.size == 1 && expressions.get(0).evaluatesToBoolean }
	def static dispatch boolean evaluatesToBoolean(WReturnExpression it) { expression instanceof WBooleanLiteral }
	def static dispatch boolean evaluatesToBoolean(WBooleanLiteral it) { true }

	def static dispatch boolean isWritableVarRef(WVariableReference it) { ref.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariable it) { eContainer.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariableDeclaration it) { writeable }
	def static dispatch boolean isWritableVarRef(EObject it) { false }
	
	// 
	// SELF: target object/context
	//
	
	def static isInASelfContext(EObject ele) {
		ele.getSelfContext != null
	}
	
	def static getSelfContext(EObject ele) {
		for (var e = ele; e != null; e = e.eContainer)
			if (e.isSelfContext) return e
		null
	}
	
	def static dispatch isSelfContext(WClass it) { true }
	def static dispatch isSelfContext(WNamedObject it) { true }
	def static dispatch isSelfContext(WObjectLiteral it) { true }
	def static dispatch isSelfContext(WMixin it) { true }
	def static dispatch isSelfContext(EObject it) { false }
	
	
	def static unboundedSuperCallingMethodsOnMixins(WMethodContainer it) {
		return linearizateHierarhcy.fold(newArrayList)[scm, e |
			// order matters ! otherwise superCallingM will cancel themselves
			// remove methods fullfilled by this element
			scm.removeIf [required | e.hasMethodWithSignature(required) ]
			// accumulate requirements
			if (e instanceof WMixin) scm.addAll(e.superCallingMethods)
			scm
		]
	}
	
	def static hasMethodWithSignature(WMethodContainer it, WMethodDeclaration method) {
		methods.exists[m | m.hasSameSignatureThan(method) ]
	}
	
	def static superCallingMethods(WMixin it) { methods.filter[m | m.callsSuper ] }
	def static boolean callsSuper(WMethodDeclaration it) { !abstract && !native && expression.callsSuper }
	def static dispatch boolean callsSuper(WSuperInvocation it) { true }
	def static dispatch boolean callsSuper(EObject it) { eAllContents.exists[ e | e.callsSuper] }
	
	// invariants
	def static dispatch List<Invariant> invariants(WMixin it) { #[] }
	def static dispatch List<Invariant> invariants(WNamedObject it) { invariants }
	def static dispatch List<Invariant>invariants(WObjectLiteral it) { invariants }
	def static dispatch List<Invariant> invariants(WClass it) { invariants }
	def static dispatch List<Invariant> invariants(MixedMethodContainer it) { #[] }
	
	def static Iterable<Invariant> allInvariants(WMethodContainer it) {
		linearizateHierarhcy.map[invariants].flatten
	}
	

}
