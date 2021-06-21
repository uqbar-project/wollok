package org.uqbar.project.wollok.model

import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WAncestor
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamed
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.allWollokFiles
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.notNullAnd

/**
 * Extension methods for WMethodContainers.
 *
 * @author jfernandes
 * @author npasserini
 */
class WMethodContainerExtensions extends WollokModelExtensions {

	def static EObject getContainer(EObject it) { 
		EcoreUtil2.getContainerOfType(it, WMethodContainer) ?: EcoreUtil2.getContainerOfType(it, WTest) 
	}
	
	def static boolean isSingleTest(EObject it) { 
		val test = EcoreUtil2.getContainerOfType(it, WTest)
		test !== null && test.only !== null
	}

	def static WMethodContainer declaringContext(EObject it)	{ EcoreUtil2.getContainerOfType(it, WMethodContainer) }
	def static WMethodDeclaration declaringMethod(EObject it)	{ EcoreUtil2.getContainerOfType(it, WMethodDeclaration) }
	def static WArgumentList declaringArgumentList(EObject it)  { EcoreUtil2.getContainerOfType(it, WArgumentList) }
	def static WClosure declaringClosure(EObject it)			{ EcoreUtil2.getContainerOfType(it, WClosure) }
	def static WConstructorCall declaringConstructorCall(EObject it){ EcoreUtil2.getContainerOfType(it, WConstructorCall) }
	
	def static EObject returnContext(WReturnExpression it)	{ 
		getAllContainers.findFirst[it instanceof WClosure || it instanceof WMethodDeclaration]
	}

	/**
	 * Returns the first container that is able to declare variables
	 */
	def static EObject declaringContainer(WExpression it)	{ 
		getAllContainers.findFirst[
			it instanceof WClosure || 
			it instanceof WMethodDeclaration ||
			it instanceof WProgram ||
			it instanceof WNamedObject ||
			it instanceof WClass ||
			it instanceof WObjectLiteral ||
			it instanceof WSuite
		]
	}
	
	def static dispatch body(EObject it) { throw new UnsupportedOperationException }
	def static dispatch body(WClosure it) { expression }
	def static dispatch body(WMethodDeclaration it) { expression }

	def static namedElements(WFile it){ elements.map[named]}
	def static namedElements(WPackage it){ elements.map[named]}
	def static dispatch named(WNamed it) { it }
	def static dispatch named(WVariableDeclaration it) { variable }

	def static boolean isAbstract(WMethodContainer it) { !unimplementedAbstractMethods.empty }

	def static dispatch List<WMethodDeclaration> unimplementedAbstractMethods(WConstructorCall it) {
		classRef.unimplementedAbstractMethods
	}
	def static dispatch List<WMethodDeclaration> unimplementedAbstractMethods(WMethodContainer it) { allAbstractMethods }

	def static boolean isAbstract(WMethodDeclaration it) { expression === null && !native }

	def static dispatch parameters(EObject e) { null }
	def static dispatch parameters(WMethodDeclaration it) { parameters }
	
	def static dispatch parameterNames(EObject o) {
		val parameters = o.parameters
		if (parameters === null) return []
		parameters.map [ name ]
	}
	
	def static dispatch parameterNames(WMemberFeatureCall call) {
		val parametersSize = call.memberCallArguments.size
		if (parametersSize < 1) {
			return ""
		}
		(1..parametersSize).map [ i | "param" + i ].join(", ")
	}

	// rename: should be non-implemented abstract methods
	def static allAbstractMethods(WMethodContainer c) {
		c.linearizeHierarchy.reverse.fold(<WMethodDeclaration>newArrayList) [unimplementedMethods, methodContainer |
			// remove implemented methods
			unimplementedMethods.removeIf[methodContainer.overrides(it)]
			
			unimplementedMethods.addAll(c.notImplementedMethodsOf(methodContainer))
			unimplementedMethods
		]
	}
	
	protected def static Iterable<WMethodDeclaration> notImplementedMethodsOf(WMethodContainer methodContainer, WMethodContainer abstractMethodContainer) {
		val concreteMethods = methodContainer.allConcreteMethods
		val propertyGetters = methodContainer.allPropertiesGetters
		val propertySetters = methodContainer.allPropertiesSetters
		
		abstractMethodContainer.abstractMethods.reject[abstractMethod |
			abstractMethod.isImplementedBy(concreteMethods, propertyGetters, propertySetters)
		]
	}
	
	protected def static ArrayList<WMethodDeclaration> allConcreteMethods(WMethodContainer c) {
		c.linearizeHierarchy.reverse.fold(<WMethodDeclaration>newArrayList) [concreteMethods, methodContainer |
			concreteMethods.addAll(methodContainer.methods.filter[!abstract])
			concreteMethods
		]
	}
	
	protected def static boolean isImplementedBy(WMethodDeclaration abstractMethod, List<WMethodDeclaration> concreteMethods, Iterable<WVariableDeclaration> propertyGetters, Iterable<WVariableDeclaration> propertySetters) {
		concreteMethods.exists[m| abstractMethod.matches(m.name, m.parameters)] ||
		propertyGetters.exists[property| abstractMethod.matches(property.variable.name, 0)] ||
		propertySetters.exists[property| abstractMethod.matches(property.variable.name, 1)]
	}

	def static getAllMessageSentToThis(WMethodContainer it) {
		eAllContents.filter(WMemberFeatureCall).filter[memberCallTarget.isThis].toIterable
	}

	def static dispatch isThis(WSelf it) { true }
	def static dispatch isThis(EObject it) { false }

	def static boolean isNative(WMethodContainer it) { methods.exists[m|m.native] }

	def static behaviors(WMethodContainer c) {
		return <EObject>newArrayList => [
			addAll(c.methods)
			addAll(c.tests)     // we need to add both methods and tests for describe suites
		] 
	}

	def static methods(WMethodContainer c) { c.members.filter(WMethodDeclaration) }
	
	def static dispatch tests(WMethodContainer c) { newArrayList }
	def static dispatch tests(WSuite t) { t.tests.toList }
	
	def static abstractMethods(WMethodContainer it) { methods.filter[isAbstract] }
	def static overrideMethods(WMethodContainer it) { methods.filter[overrides].toList }

	def static dispatch boolean overrides(WMethodContainer c, WMethodDeclaration m) { c.overrideMethods.exists[matches(m.name, m.parameters.size)] }
	// mixins can be overriding a method without explicitly declaring it
	def static dispatch boolean overrides(WMixin c, WMethodDeclaration m) { c.methods.exists[!abstract && matches(m.name, m.parameters.size)] }

	def static declaringMethod(WParameter p) { p.eContainer as WMethodDeclaration }
	def static overriddenMethod(WMethodDeclaration m) { m.declaringContext.overriddenMethod(m.name, m.parameters) }
	def protected static overriddenMethod(WMethodContainer it, String name, List<?> parameters) {
		lookUpMethod(linearizeHierarchy.tail, name, parameters, true)
	}

	def static superMethod(WSuperInvocation it) { method.overriddenMethod }

	def static supposedToReturnValue(WMethodDeclaration it) { expressionReturns || eAllContents.exists[e | e.isReturnWithValue] }

	def static hasSameSignatureThan(WMethodDeclaration it, WMethodDeclaration other) { matches(other.name, other.parameters) }

	def static isGetter(WMethodDeclaration it) { (it.eContainer as WMethodContainer).variableNames.contains(name) && parameters.empty }
	
	def static variableNames(WMethodContainer it) {	variables.map [ v | v?.name ].toList }

	def static allVariableNames(WMethodContainer it) { allVariables.map [ v | v?.name ].toList }

	def static hasVariable(WMethodContainer it, String name) { variableNames.contains(name) }
	
	def dispatch static isReturnWithValue(EObject it) { false }
	// REVIEW: this is a hack solution. We don't want to compute "return" statements that are
	//  within a closure as a return on the containing method.
	def dispatch static isReturnWithValue(WReturnExpression it) { validReturnExpression && expression !== null && allContainers.forall[!(it instanceof WClosure)] }
	def dispatch static hasReturnWithValue(WReturnExpression r) { r.returnWithValue }
	def dispatch static hasReturnWithValue(EObject e) { e.eAllContents.exists[isReturnWithValue] }

	def static dispatch boolean isValidReturnExpression(EObject o) { 
		val container = o.eContainer
		container !== null && container.isValidReturnExpression
	}
	def static dispatch boolean isValidReturnExpression(WMemberFeatureCall call) { false }
	def static dispatch boolean isValidReturnExpression(WBlockExpression expr) { true }
	def static dispatch boolean isValidReturnExpression(WMethodDeclaration method) { true }

	def static List<WVariableDeclaration> allVariableDeclarations(WMethodContainer it) {
		linearizeHierarchy.fold(newArrayList) [variableDeclarations, type |
			variableDeclarations.addAll(type.variableDeclarations)
			variableDeclarations
		]
	}
	
	def static variablesMap(WMethodContainer it) {
		linearizeHierarchy.fold(newHashMap) [variableDeclarations, type |
			val key = type.keyForVariablesMap
			val newVariableDeclarations = variableDeclarations.getOrDefault(key, newArrayList)
			newVariableDeclarations.addAll(type.variableDeclarations)
			variableDeclarations.put(key, newVariableDeclarations)
			variableDeclarations
		]
	}
	
	def static dispatch keyForVariablesMap(EObject it) { "*" }
	def static dispatch keyForVariablesMap(WMixin it) { name	}
	
	def static List<WVariableDeclaration> allVariableDeclarations(WMethodContainer it, WollokObject wo) {
		// Step 1 - Obtaining all variable declarations 
		val variableDeclarations = allVariableDeclarations
		// Step 2 - Detecting dependencies among variable declarations
		// for example:
		// const a = b + 1
		// const b = 2
		// const c = a + b
		// should finish in the current map:
		// a -> [b]
		// b -> []
		// c -> [a, b]
		val variableDependenciesGraph = <WVariableDeclaration, List<WVariable>>newHashMap
		variableDeclarations.forEach [ variableDeclaration |
			if (variableDeclaration.right !== null && !wo.isInitialized(variableDeclaration.variable.name)) {
				val dependencies = variableDeclaration.right.dependenciesOnInit(variableDeclaration)
				variableDependenciesGraph.put(variableDeclaration, dependencies)
			}
		]
		// Ordering variable declarations based on dependencies
		// based on previous example:
		// if a depends on b, and c depends on a & b
		// the order should be: b, then a, then c
		// We assure each declaration is sorted after all dependencies
		new ArrayList(variableDeclarations).forEach [ variableDeclaration |
			val variableDependencies = variableDependenciesGraph.get(variableDeclaration)
			if (variableDependencies !== null && !variableDependencies.isEmpty) {
				val variables = variableDeclarations.map [ variable ]
				val maximumDependencyIndex = variableDependencies.map [ variables.indexOf(it) ].max
				if (maximumDependencyIndex > 0) {
					val index = variableDeclarations.indexOf(variableDeclaration)
					variableDeclarations.add(maximumDependencyIndex + 1, variableDeclaration)
					variableDeclarations.remove(index)
				}
			}
		]
		variableDeclarations
	}
	
	def static dispatch List<WVariable> dependenciesOnInit(EObject o, WVariableDeclaration variable) { newArrayList }
	def static dispatch List<WVariable> dependenciesOnInit(WBinaryOperation operation, WVariableDeclaration variable) {
		newArrayList => [
			addIfVariable(operation.leftOperand, it)
			addIfVariable(operation.rightOperand, it)
		]
	}
	def static dispatch List<WVariable> dependenciesOnInit(WVariableDeclaration declaration, WVariableDeclaration variable) {
		newArrayList => [
			add(declaration.variable)
		]
	}
	
	def static void addIfVariable(EObject o, List<WVariable> variableDeclarations) {
		if (o instanceof WVariableReference) {
			val variable = o.ref
			if (variable instanceof WVariable) {
				variableDeclarations.add(variable)
			}
		}
	}

	def static dispatch List<WVariableDeclaration> variableDeclarations(EObject o) { newArrayList }
	def static dispatch List<WVariableDeclaration> variableDeclarations(WBlockExpression b) { b.expressions.filter(WVariableDeclaration).toList }
	def static dispatch List<WVariableDeclaration> variableDeclarations(WMethodContainer c) {c.members.filter(WVariableDeclaration).toList }
	def static dispatch List<WVariableDeclaration> variableDeclarations(WVariableDeclaration e) {
		#[e]
	}
	def static dispatch List<WVariableDeclaration> variableDeclarations(WCatch c) {
		c.expression.variableDeclarations
	}
	def static dispatch List<WVariableDeclaration> variableDeclarations(WTry t) { 
		t.expression.variableDeclarations
	}
	def static dispatch List<WVariableDeclaration> variableDeclarations(WTest test) {
		test.elements.flatMap [ variableDeclarations ].toList
	}

	def static WMethodDeclaration initializeMethod(WMethodContainer it) { methods.findFirst [ isInitializer ] }

	def static List<WMethodDeclaration> initializeMethods(WMethodContainer it) { initializeMethodsRecursive(newArrayList).reverse }

	private def static List<WMethodDeclaration> initializeMethodsRecursive(WMethodContainer it, List<WMethodDeclaration> result) {
		val initMethod = initializeMethod
		if (initMethod !== null) {
			result.add(initMethod)
		}
		if (parent === null) result else parent.initializeMethodsRecursive(result) 
	}
	
	def static variables(WMethodContainer c) { c.variableDeclarations.variables }
	def static variables(WProgram p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(WTest p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(Iterable<WVariableDeclaration> declarations) { declarations.map[variable] }
	def static variables(WSuite p) { p.members.filter(WVariableDeclaration).variables }

	/**
	 * If the variable is not found in the method container, look up the hierarchy until it is found.
	 * TODO: Consider mixins.
	 */
	def static WVariableDeclaration getVariableDeclaration(WMethodContainer it, String name) {
		getOwnVariableDeclaration(name) ?: parent?.getVariableDeclaration(name)
	}
	
	/**
	 * Looks for "own" variables, i.e. not inherited ones.
	 */
	def static getOwnVariableDeclaration(WMethodContainer it, String name) {
		variableDeclarations.findFirst [ variable?.name.equals(name) ]
	}

	def static findMethod(WMethodContainer c, WMemberFeatureCall it) {
		c.allUntypedMethods.findFirst [ m | m.matches(feature, memberCallArguments) ]	
	}
	
	def static findMethodIgnoreCase(WMethodContainer c, String methodName, int argumentsSize) {
		c.allUntypedMethods.findMethodIgnoreCase(methodName, argumentsSize) 
	}

	def static ownerOf(WollokObject o, String methodName) {
		o.behavior.lookupMethod(methodName, #[o], false).wollokClass.fqn
	}
	
	def static hasEqualsMethod(WollokObject o) {
		!o.ownerOf(EQUALITY).equals(OBJECT) || !o.ownerOf("equals").equals(OBJECT)
	}
	
	def static hasGreaterThanMethod(WollokObject o) {
		o.behavior.methods.hasMethodIgnoreCase(GREATER_THAN, 1)  
	}

	def static hasMethodIgnoreCase(Iterable<WMethodDeclaration> methods, String methodName, int argumentsSize) {
		methods.findMethodIgnoreCase(methodName, argumentsSize) !== null 
	}

	def static findMethodIgnoreCase(Iterable<WMethodDeclaration> methods, String methodName, int argumentsSize) {
		methods.findFirst[m | m.matches(methodName, argumentsSize, true) ] 
	}

	def static dispatch List<WMethodDeclaration> findMethodsByName(WMethodContainer c, String methodName) {
		c.allUntypedMethods.findMethodsByName(methodName)
	}
	
	def static dispatch List<WMethodDeclaration> findMethodsByName(WollokObject o, String methodName) {
		o.allMethods.findMethodsByName(methodName)
	}
	
	def static dispatch List<WMethodDeclaration> findMethodsByName(Iterable<WMethodDeclaration> methods, String methodName) {
		methods.filter [ m | m.name.equals(methodName) && !m.overrides ].toList
	}
	
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(EObject o) { newArrayList }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WMixin it) { methods }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WNamedObject it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WObjectLiteral it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WClass it) { inheritedMethods }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WSuite it) { methods }
	def static dispatch Iterable<WMethodDeclaration> allUntypedMethods(WProgram it) { newArrayList }
	
	def static allVariables(WMethodContainer it) {
		allVariableDeclarations.map [ variable ]
	}
	
	def static allProperties(WMethodContainer it) {
		allVariableDeclarations.filter [ property ]
	}
	
	def static allPropertiesGetters(WMethodContainer it) {
		allProperties
	}
	
	def static allPropertiesSetters(WMethodContainer it) {
		allProperties.filter [ writeable ]
	}
	
	def static getInheritedMethods(WMethodContainer it) {
		linearizeHierarchy.fold(newArrayList) [methods, type |
			val currents = type.methods
			val newMethods = currents.filter[m | ! methods.exists[m2 | m.matches(m2.name, m2.parameters)]]
			methods.addAll(newMethods)
			methods
		]
	}

	def static actuallyOverrides(WMethodDeclaration m) {
		m.declaringContext !== null && inheritsMethod(m.declaringContext, m.name, m.parameters.size)
	}

	def static convertToString(List<WMethodDeclaration> methods) { 
		methods.map [ messageName ].join(', ')
	}

	def static parents(WMethodContainer c) { _parents(c.parent, newArrayList) }
	
	def static List<WClass> _parents(WClass c, List<WClass> l) {
		if (c === null) {
			return l
		}
		if (l.contains(c)) {
			return l
			//throw new WollokRuntimeException('''Class «c.name» is in a cyclic hierarchy''');
		}
		//
		l.add(c)
		return _parents(c.parent, l)
	}

	def dispatch static usesDerivedKeyword(WMethodContainer it) { false }
	def dispatch static usesDerivedKeyword(WClass it) {
		root !== null && !root.fqn.equals(OBJECT)
	}
	def dispatch static usesDerivedKeyword(WNamedObject it) { root !== null && !root.fqn.equals(OBJECT) }
	def dispatch static usesDerivedKeyword(WObjectLiteral it) { root !== null && !root.fqn.equals(OBJECT) }
	
	def dispatch static hasCyclicHierarchy(WClass c) { 
		_hasCyclicHierarchy(c, newArrayList)
	}
	def dispatch static hasCyclicHierarchy(EObject e) { false }
	
	def static boolean _hasCyclicHierarchy(WClass c, List<WClass> l) {
		if (c === null) {
			return false
		}
		if (l.contains(c)) {
			return true
		}
		l.add(c)
		return _hasCyclicHierarchy(c.parent, l)
	}

	def static boolean inheritsFromLibClass(WMethodContainer it) { parent.isCoreObject }

	def static dispatch boolean inheritsFromObject(EObject e) { false }
	def static dispatch boolean inheritsFromObject(WClass c) { c.parent === null || c.parent.fqn.equals(OBJECT) }
	def static dispatch boolean inheritsFromObject(WNamedObject o) { o.parent === null || o.parent.fqn.equals(OBJECT) }
	def static dispatch boolean inheritsFromObject(WObjectLiteral o) { o.parent === null || o.parent.fqn.equals(OBJECT) }

	def static dispatch WClass parent(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch WClass parent(WClass it) { getClassParent(parents, root) }
	def static dispatch WClass parent(WObjectLiteral it) { getClassParent(parents, root) }
	def static dispatch WClass parent(WNamedObject it) { getClassParent(parents, root) }
	// not supported yet !
	def static dispatch WClass parent(WMixin it) { null }
	def static dispatch WClass parent(WSuite it) { null }

	def static getClassParent(WMethodContainer it, List<WAncestor> parents, WClass root) {
		if (parents.empty) return root
		val parentsClass = parents.map [ ref ].filter(WClass)
		if (parentsClass.isEmpty) root ?: WollokClassFinder.instance.getObjectClass(it) else parentsClass.last
	}
	
	def static EObject ref(WAncestor ancestor) { ancestor.ref }
	
	def static dispatch List<WMixin> mixins(EList<WAncestor> it) {
		map [ ref ].filter(WMixin).toList
	}
	def static dispatch List<WMixin> mixins(WMethodContainer it) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch List<WMixin> mixins(WClass it) { parents.mixins	}
	def static dispatch List<WMixin> mixins(WObjectLiteral it) { parents.mixins	}
	def static dispatch List<WMixin> mixins(WNamedObject it) { parents.mixins }
	def static dispatch List<WMixin> mixins(WMixin it) { Collections.EMPTY_LIST }
	def static dispatch List<WMixin> mixins(WSuite it) { Collections.EMPTY_LIST }

	def static dispatch members(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch members(WClass c) { c.members }
	def static dispatch members(WObjectLiteral c) { c.members }
	def static dispatch members(WNamedObject c) { c.members }
	def static dispatch members(WMixin c) { c.members }
	def static dispatch members(WSuite c) { c.members }

	def static dispatch contextName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch contextName(WClass c) { c.fqn }
	def static dispatch contextName(WObjectLiteral c) { "<anonymousObject>" }
	def static dispatch contextName(WNamedObject c) { c.fqn }
	def static dispatch contextName(WMixin c) { c.fqn }
	def static dispatch contextName(WSuite s) { s.name }

	def static dispatch abstractionName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch abstractionName(WClass c) { WollokConstants.CLASS }
	def static dispatch abstractionName(WNamedObject o) { WollokConstants.WKO }
	def static dispatch abstractionName(WMixin m) { WollokConstants.MIXIN }
	def static dispatch abstractionName(WMethodDeclaration m) { WollokConstants.METHOD }
	
	def static boolean inheritsMethod(WMethodContainer it, String name, int argSize) {
		(mixins !== null && mixins.exists[m| m.hasOrInheritsMethod(name, argSize)])
		|| (parent !== null && parent.hasOrInheritsMethod(name, argSize))
	}

	def static boolean hasOrInheritsMethod(WMethodContainer c, String mname, int argsSize) {
		c !== null && !c.hasCyclicHierarchy && (c.matchesProperty(mname, argsSize) || c.methods.exists[matches(mname, argsSize)] || c.parent.hasOrInheritsMethod(mname, argsSize))
	}

	def static WMethodDeclaration lookupMethod(WMethodContainer behavior, String message, List<?> params, boolean acceptsAbstract) {
		lookUpMethod(behavior.linearizeHierarchy, message, params, acceptsAbstract)
	}

	def static lookUpMethod(Iterable<WMethodContainer> hierarchy, String message, List<?> params, boolean acceptsAbstract) {
		for (chunk : hierarchy) {
			val method = chunk.methods.findFirst[ (!it.abstract || acceptsAbstract) && matches(message, params)]
			if (method !== null)
				return method
		}
		null
	}

	/**
	 * The full hierarchy chain top->down
	 */
	def static List<WMethodContainer> linearizeHierarchy(WMethodContainer c) {
		if (c.parent !== null && c.parent.hasCyclicHierarchy) return newLinkedList
		newLinkedList => [
			add(c)
			addAll(c.mixinsForLinearization)
			addAll(c.parentClassesForLinearization)
		]
	}
	
	def static List<WMethodContainer> mixinsForLinearization(WMethodContainer it) {
		(mixins ?: newArrayList).clone.toList
	}
	
	def static parentClassesForLinearization(WMethodContainer it) {
		if (parent === null) #[WollokClassFinder.instance.getObjectClass(it)] else parent.linearizeHierarchy
	}
	
	def static matches(WMethodDeclaration m1, WMethodDeclaration m2) {
		m1.name.equals(m2.name) && m1.parameters.length === m2.parameters.length 
	}

	def static matches(WMethodDeclaration it, String message, List<?> params) { 
		matches(message, params.size)
	}

	def static matches(WMethodDeclaration it, String message, int nrOfArgs) {
		matches(message, nrOfArgs, false)
	}

	def static matches(WMethodDeclaration it, String message, int nrOfArgs, boolean ignoreCase) {
		val messageMatches = if (ignoreCase) name.equalsIgnoreCase(message) else name == message 
		
		messageMatches &&
		if (hasVarArgs)
			nrOfArgs >= parameters.filter[!isVarArg].size
		else
			nrOfArgs == parameters.size
	}

	def static boolean isValidCall(WMethodContainer c, WMemberFeatureCall call) {
		c.matchesPropertiesInHierarchy(call.feature, call.memberCallArguments.size) 
			|| c.allUntypedMethods.exists[isValidMessage(call)] 
	}

	def static boolean matchesPropertiesInHierarchy(WMethodContainer it, String propertyName, int parametersSize) {
		matchesProperty(propertyName, parametersSize) || (parent !== null && !hasCyclicHierarchy && parent.matchesPropertiesInHierarchy(propertyName, parametersSize))	
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
		if (cl.hasCyclicHierarchy) return;
		if (cl.parent !== null) cl.parent.superClassesIncludingYourselfTopDownDo(action)
		action.apply(cl)
	}

	def static <R> R foldUp(WClass cl, R initialValue, (R, WClass)=>R action) {
		val nextValue = action.apply(initialValue, cl)
		if (cl.parent !== null)
			cl.parent.foldUp(nextValue, action)
		else
			nextValue
	}

	def static dispatch memberTarget(WFeatureCall call) { null }
	def static dispatch memberTarget(WMemberFeatureCall call) { call.memberCallTarget }
	
	def static dispatch feature(EObject o) { null }
	def static dispatch feature(WMemberFeatureCall call) { call.feature }
	def static dispatch feature(WSuperInvocation call) { call.method?.name }
	def static dispatch feature(WUnaryOperation o) { o.feature }
	def static dispatch feature(WBinaryOperation o) { o.feature }
	def static dispatch feature(WPostfixOperation o) { o.feature }

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

	// ************************************************************************
	// ** unorganized
	// ************************************************************************

	def static dispatch boolean getIsReturnTrue(WExpression it) { false }
	def static dispatch boolean getIsReturnTrue(WBlockExpression it) { expressions.size == 1 && expressions.get(0).isReturnTrue }
	def static dispatch boolean getIsReturnTrue(WReturnExpression it) { expression instanceof WBooleanLiteral && expression.isReturnTrue }
	def static dispatch boolean getIsReturnTrue(WBooleanLiteral it) { isTrueLiteral }

	def static dispatch boolean returnsABoolean(WExpression it) { false }
	def static dispatch boolean returnsABoolean(WBlockExpression it) { expressions.size == 1 && expressions.get(0).isReturnTrue }
	def static dispatch boolean returnsABoolean(WReturnExpression it) { expression instanceof WBooleanLiteral }
	
	def static dispatch isTrueLiteral(WBooleanLiteral it) { isIsTrue }
	def static dispatch isTrueLiteral(WExpression it) { false }
	
	def static dispatch isFalseLiteral(WBooleanLiteral it) { !isIsTrue }
	def static dispatch isFalseLiteral(WExpression it) { false }

	def static dispatch boolean evaluatesToBoolean(Void it) { false }
	def static dispatch boolean evaluatesToBoolean(WExpression it) { false }
	def static dispatch boolean evaluatesToBoolean(WBlockExpression it) { expressions.size == 1 && expressions.get(0).evaluatesToBoolean }
	def static dispatch boolean evaluatesToBoolean(WReturnExpression it) { expression instanceof WBooleanLiteral }
	def static dispatch boolean evaluatesToBoolean(WBooleanLiteral it) { true }

	def static dispatch boolean isWritableVarRef(WVariableReference it) { ref.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariable it) { eContainer.isWritableVarRef }
	def static dispatch boolean isWritableVarRef(WVariableDeclaration it) { writeable }
	def static dispatch boolean isWritableVarRef(EObject it) { false }
	
	def static findProperty(WMethodContainer it, String propertyName, int parametersSize) {
		allVariableDeclarations.findFirst [ variable | variable.matchesProperty(propertyName, parametersSize) ]
	} 
	
	def static dispatch boolean matchesProperty(EObject it, String propertyName, int parametersSize) { false }
	def static dispatch boolean matchesProperty(WMethodContainer it, String propertyName, int parametersSize) {
		variableDeclarations.exists [ variable | variable.matchesProperty(propertyName, parametersSize) ]
	}
	
	def static dispatch boolean matchesProperty(WVariableDeclaration decl, String propertyName, int parametersSize) {
		matchesGetter(decl, propertyName, parametersSize) || matchesSetter(decl, propertyName, parametersSize)
	}

	def static boolean matchesGetter(WVariableDeclaration decl, String propertyName, int parametersSize) {
		decl.variable !== null && decl.variable.name.equals(propertyName) && decl.property && parametersSize == 0
	}
	
	def static boolean matchesSetter(WVariableDeclaration decl, String propertyName, int parametersSize) {
		decl.variable !== null && decl.variable.name.equals(propertyName) && decl.property && decl.writeable && parametersSize == 1
	}

	def static boolean constantProperty(WMethodContainer mc, String propertyName, int parametersSize) {
		mc.variableDeclarations.exists [ decl | decl.variable !== null && decl.variable.name.equals(propertyName) && decl.property && !decl.writeable ]
	}
	
	// 
	// SELF: target object/context
	//
	
	def static isInASelfContext(EObject ele) {
		ele.declaringContext !== null
	}
	
	def dispatch static boolean canCreateLocalVariable(WTest it) { true }
	def dispatch static boolean canCreateLocalVariable(WMethodContainer it) { true }
	def dispatch static boolean canCreateLocalVariable(WProgram it) { true }
	def dispatch static boolean canCreateLocalVariable(EObject ele) {
		if (ele.eContainer === null) return false
		ele.eContainer.canCreateLocalVariable
	}
	
	def static dispatch isSelfContext(WClass it) { true }
	def static dispatch isSelfContext(WNamedObject it) { true }
	def static dispatch isSelfContext(WObjectLiteral it) { true }
	def static dispatch isSelfContext(WMixin it) { true }
	def static dispatch isSelfContext(WSuite it) { true }
	def static dispatch isSelfContext(EObject it) { false }
	
	
	def static unboundedSuperCallingMethodsOnMixins(WMethodContainer it) {
		return linearizeHierarchy.fold(newArrayList)[scm, e |
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
	def static dispatch boolean callsSuper(WMethodDeclaration it) { !abstract && !native && expression.callsSuper }
	def static dispatch boolean callsSuper(WSuperInvocation it) { true }
	def static dispatch boolean callsSuper(EObject it) { eAllContents.exists[ e | e.callsSuper] }

	def static dispatch boolean hasRealParent(EObject it) { false }
	def static dispatch boolean hasRealParent(WNamedObject wko) { wko.parent !== null && wko.parent.name !== null && !wko.parent.fqn.equalsIgnoreCase(WollokConstants.FQN_ROOT_CLASS) }
	def static dispatch boolean hasRealParent(WClass c) {
		c.parent !== null && c.parent?.name !== null && !c.parent?.fqn.notNullAnd[equalsIgnoreCase(WollokConstants.FQN_ROOT_CLASS)]
	}
		
	/* Including file name for multiple tests */
	def static getFullName(WTest test, boolean processingManyFiles) {
		test.name
	}

	def static dispatch Boolean isVariable(EObject o) { false }
	def static dispatch Boolean isVariable(WVariableDeclaration member) { true }
	
	def static allMethodContainers(IProject project) {
		project
			.allWollokFiles
			.map [ it.getMethodContainers ]
			.flatten
			.toList
	}

	def static Map<URI, List<WMethodContainer>> mapMethodContainers(IProject project) {
		val result = new HashMap<URI, List<WMethodContainer>>
		project.allWollokFiles.forEach [ file | result.put(file, newArrayList)]
		project
			.allMethodContainers
			.forEach [ mc |
				val uri = mc.file.URI
				val methodContainers = result.get(uri)
				methodContainers.add(mc)
				result.put(uri, methodContainers)
			]
		result
	}

	def static Map<URI, List<WMethodContainer>> mapMethodContainers(IProject project, boolean platformFile) {
		if (platformFile) return newHashMap
		project.mapMethodContainers
	}
	
	def static getMethodContainers(URI uri) {
		val resSet = new XtextResourceSet()
	    val file = resSet.getResource(uri, true)
		val result = new ArrayList<WMethodContainer>
		searchMethodContainers(file.contents, result)
		result	
	}
	
	def static void searchMethodContainers(EList<EObject> objects, List<WMethodContainer> containers) {
		objects.forEach [ object |
			if (object.isValidContainerForStaticDiagram) {
				containers.add(object as WMethodContainer)
			} else {
				searchMethodContainers(object.eContents, containers)
			}
		]
	}
	
	def static dispatch isValidContainerForStaticDiagram(EObject o) { false }
	def static dispatch isValidContainerForStaticDiagram(WMethodContainer mc) {	true }
	def static dispatch isValidContainerForStaticDiagram(WSuite s) { false }

	def static dispatch canDefineConstructors(EObject o) { false }
	def static dispatch canDefineConstructors(WClass c) { true }

	def static dispatch canDefineFixture(EObject o) { false }
	def static dispatch canDefineFixture(WSuite s) { true }

	def static dispatch canDefineTests(EObject o) { false }
	def static dispatch canDefineTests(WSuite s) { true }
	def static dispatch canDefineTests(WTest t) { true }

	def static dispatch constructionName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch constructionName(WClass c) { WollokConstants.CLASS }
	def static dispatch constructionName(WObjectLiteral c) { WollokConstants.WKO }
	def static dispatch constructionName(WNamedObject c) { WollokConstants.WKO }
	def static dispatch constructionName(WMixin c) { WollokConstants.MIXIN }
	def static dispatch constructionName(WSuite s) { WollokConstants.SUITE }

	def static dispatch boolean isPropertyAllowed(WSuite s) { false	}
	def static dispatch boolean isPropertyAllowed(WProgram p) { false }
	def static dispatch boolean isPropertyAllowed(WMethodDeclaration m) { false }
	def static dispatch boolean isPropertyAllowed(WClosure c) { false }
	def static dispatch boolean isPropertyAllowed(WMethodContainer mc) { true }
	def static dispatch boolean isPropertyAllowed(EObject o) {
		val parent = o.eContainer
		parent !== null && parent.isPropertyAllowed
	}

	def static dispatch isCustom(WMethodContainer o) { !o.fqn.startsWith("wollok.") }
	def static dispatch isCustom(EObject o) { false }

	def static dispatch shouldCheckInitialization(WMethodContainer it) { true }
	def static dispatch shouldCheckInitialization(WClass it) { false }
	def static dispatch shouldCheckInitialization(WMixin it) { false }

	def static isInitializer(WMethodDeclaration m) { m.name.equals(INITIALIZE_METHOD) }

	def static dispatch boolean isClosureWithoutParams(WExpression e) { false }
	def static dispatch boolean isClosureWithoutParams(WClosure block) { block.parameters.isEmpty } 
}
