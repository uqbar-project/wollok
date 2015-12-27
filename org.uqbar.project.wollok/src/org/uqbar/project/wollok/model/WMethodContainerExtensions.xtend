package org.uqbar.project.wollok.model

import java.util.Arrays
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThisDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WMixin
import java.util.Collections

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

	def static boolean isAbstract(WClass it) { hasUnimplementedInheritedMethods }
	def static boolean isAbstract(WNamedObject it) { parent != null && parent.hasUnimplementedInheritedMethods }
	def static boolean isAbstract(WMethodDeclaration it) { expression == null && !native }
	
	def static dispatch parameters(WMethodDeclaration it) { parameters }
	def static dispatch parameters(WConstructor it) { parameters }

	def static allAbstractMethods(WClass c) {
		val unimplementedMethods = <WMethodDeclaration>newArrayList
		c.superClassesIncludingYourselfTopDownDo [ claz |
			unimplementedMethods.removeAllSuchAs[claz.overrides(it)]
			unimplementedMethods.addAll(claz.abstractMethods);
		]
		unimplementedMethods
	}
	
	def static Iterable<WMethodDeclaration> unimplementedAbstractMethods(WNamedObject it) { parent.allAbstractMethods.filter[m| !it.overrides(m)] }

	def static hasUnimplementedInheritedMethods(WClass c) { !c.allAbstractMethods.empty }

	def static boolean isNative(WMethodContainer it) { methods.exists[m|m.native] }
	
	def static methods(WMethodContainer c) { c.members.filter(WMethodDeclaration) }
	def static abstractMethods(WClass it) { methods.filter[isAbstract] }
	def static overrideMethods(WMethodContainer it) { methods.filter[overrides].toList }
	def static boolean overrides(WMethodContainer c, WMethodDeclaration m) { c.overrideMethods.exists[matches(m.name, m.parameters.size)] }
	
	def static declaringMethod(WParameter p) { p.eContainer as WMethodDeclaration }
	def static overridenMethod(WMethodDeclaration m) { m.declaringContext.parent?.lookupMethod(m.name, m.parameters) }
	def static superMethod(WSuperInvocation sup) { sup.method.overridenMethod }
	
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
	
	def static dispatch Iterable<WMethodDeclaration> allMethods(WNamedObject o) { o.methods + if (o.parent != null) o.parent.allMethods else #[] }
	def static dispatch Iterable<WMethodDeclaration> allMethods(WObjectLiteral o) { o.methods }
	def static dispatch Iterable<WMethodDeclaration> allMethods(WClass c) {
		val methods = newArrayList
		c.superClassesIncludingYourselfTopDownDo[cl |
			// remove overriden
			cl.overrideMethods.forEach[methods.remove(it.overridenMethod)]
			// add all
			methods.addAll(cl.methods)
		]
		methods
	}

	def static actuallyOverrides(WMethodDeclaration m) {
		m.declaringContext != null && inheritsMethod(m.declaringContext, m.name, m.parameters.size)
	}
	
	def static parents(WMethodContainer c) { _parents(c.parent, newArrayList) }
	def static List<WClass> _parents(WMethodContainer c, List l) {
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
	// not supported yet !
	def static dispatch WClass parent(WMixin it) { null }
	
	def static dispatch List<WMixin> mixins(WMethodContainer it) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch List<WMixin> mixins(WClass it) { mixins }
	def static dispatch List<WMixin> mixins(WObjectLiteral it) { mixins } // can we just reply with wollok.lang.Object class ?
	def static dispatch List<WMixin> mixins(WNamedObject it) { mixins }
	def static dispatch List<WMixin> mixins(WMixin it) { Collections.EMPTY_LIST }

	def static dispatch members(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch members(WClass c) { c.members }
	def static dispatch members(WObjectLiteral c) { c.members }
	def static dispatch members(WNamedObject c) { c.members }
	def static dispatch members(WMixin c) { c.members }
	
	def static dispatch contextName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch contextName(WClass c) { c.fqn }
	def static dispatch contextName(WObjectLiteral c) { "<anonymousObject>" }
	def static dispatch contextName(WNamedObject c) { c.fqn }
	def static dispatch contextName(WMixin c) { c.fqn }
	
	def static boolean inheritsMethod(WMethodContainer c, String name, int argSize) { c.parent != null && c.parent.hasOrInheritMethod(name, argSize) }
	
	def static boolean hasOrInheritMethod(WClass c, String mname, int argsSize) { 
		c != null && (c.methods.exists[matches(mname, argsSize)] || c.parent.hasOrInheritMethod(mname, argsSize))
	}

	def static WMethodDeclaration lookupMethod(WMethodContainer behavior, String message, List params) { 
		var method = behavior.methods.findFirst[matches(message, params)]
		
		if (method != null) 
			return method
		
		if (behavior.mixins != null) {
			method = behavior.mixins.reverseView.fold(null) [WMethodDeclaration resolvedMethod, mixin|
				if (resolvedMethod != null)
					resolvedMethod
				else
					mixin.lookupMethod(message, params)
			]
			if (method != null)
				return method
		}
		else if (behavior.parent != null)
			behavior.parent.lookupMethod(message, params)
		else 
			null
	}
	
	def static matches(WMethodDeclaration it, String message, List params) { matches(message, params.size) }
	
	def static matches(WMethodDeclaration it, String message, int nrOfArgs) {
		name == message && 
		if (hasVarArgs)
			nrOfArgs >= parameters.filter[!isVarArg].size
		else
			nrOfArgs == parameters.size
	}

	def static boolean isValidCall(WMethodContainer c, WMemberFeatureCall call, WollokClassFinder finder) {
		c.hookObjectSuperClass(finder)
		c.allMethods.exists[isValidMessage(call)] || (c.parent != null && c.parent.isValidCall(call, finder))
	}
	
	def static dispatch void hookObjectSuperClass(WClass it, WollokClassFinder finder) { hookToObject(finder) }
	def static dispatch void hookObjectSuperClass(WNamedObject it, WollokClassFinder finder) { hookObjectInHierarhcy(finder) }
	def static dispatch void hookObjectSuperClass(WObjectLiteral it, WollokClassFinder finder) { } // nothing !

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
	def static dispatch WConstructor resolveConstructor(WMethodContainer otherContainer, Object... arguments) {
		throw new WollokRuntimeException('''Impossible to call a constructor on anything besides a class''');
	}
	
	
	// ************************************************************************
	// ** Constructors delegation, etc.
	// ************************************************************************
	
	def static dispatch resolveConstructorReference(WMethodContainer behave, WThisDelegatingConstructorCall call) { behave.resolveConstructor(call.arguments) }
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
	def static dispatch boolean getIsReturnTrue(WBooleanLiteral it) { it.isIsTrue }
	
	def static dispatch boolean evaluatesToBoolean(WExpression it) { false }
	def static dispatch boolean evaluatesToBoolean(WBlockExpression it) { expressions.size == 1 && expressions.get(0).evaluatesToBoolean }
	def static dispatch boolean evaluatesToBoolean(WReturnExpression it) { expression instanceof WBooleanLiteral }
	def static dispatch boolean evaluatesToBoolean(WBooleanLiteral it) { true }

	def static dispatch boolean isWritableVarRef(WVariableReference it) { ref.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariable it) { eContainer.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariableDeclaration it) { writeable }
	def static dispatch boolean isWritableVarRef(WExpression it) { false }
	
}