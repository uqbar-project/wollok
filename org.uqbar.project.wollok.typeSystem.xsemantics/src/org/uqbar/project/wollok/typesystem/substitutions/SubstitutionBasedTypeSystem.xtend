package org.uqbar.project.wollok.typesystem.substitutions

import com.google.inject.Inject
import java.util.List
import java.util.Set
import org.eclipse.emf.common.util.WeakInterningHashSet
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.NamedObjectWollokType
import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import static org.uqbar.project.wollok.typesystem.TypeSystemUtils.*
import static org.uqbar.project.wollok.typesystem.WollokType.*
import static org.uqbar.project.wollok.typesystem.substitutions.TypeCheck.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.utils.StringUtils

/**
 * Implementation that builds up rules
 * and the goes through several steps substituting types.
 *
 * @author jfernandes
 */
class SubstitutionBasedTypeSystem implements TypeSystem {
	List<TypeRule> rules = newArrayList
	// esto me gustaria evitarlo :S
	Set<EObject> analyzed = new WeakInterningHashSet
	@Inject WollokClassFinder finder
	
	override def name() { "Substitutions-based" }
	
	override validate(WFile file, WollokDslValidator validator) {
		this.analyzed = new WeakInterningHashSet
		println("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes()
		// TODO: report errors !
		(file.eAllContents.forEach[ issues.forEach[issue|
			validator.report(issue.message, issue.model)
		] ])
	}

	override analyse(EObject p) { p.eContents.forEach[analyze] }

	def analyze(EObject node) {
		if (!analyzed.contains(node)) {
			analyzed.add(node)
			node.doAnalyse
		}
	}

	def analyze(Iterable<? extends EObject> objects) { objects.forEach[analyze] }

	// ***************************
	// ** analysis rules
	// ***************************

	def dispatch void doAnalyse(WProgram it) { elements.analyze }
	def dispatch void doAnalyse(WTest it) { elements.analyze }

	def dispatch void doAnalyse(WClass it) { 
		if (members != null) members.forEach[analyze]
		if (constructors != null) constructors.forEach[analyze]
	}
	
	def dispatch void doAnalyse(WNamedObject it) {
		addFact(it, new NamedObjectWollokType(it, this))
		if (members != null) members.forEach[analyze]
	}
	
	def dispatch void doAnalyse(WConstructor it) {
		parameters.analyze
		expression?.analyze
	}

	def dispatch void doAnalyse(WMethodDeclaration it) {
		parameters.analyze
		if (overrides) {
			val overriden = overridenMethod
			addCheck(overriden, SUPER_OF, it)
			var i = 0
			for (overParam: overriden.parameters)
				addCheck(parameters.get(i++), SAME_AS, overParam)
		}
		if (isAbstract)
			isA(WAny) // acá debería alimentarse de las redefiniciones
		else
			addCheck(it, SUPER_OF, expression)
	}

	def dispatch void doAnalyse(WVariableDeclaration it) {
		addCheck(it, SAME_AS, variable)
		if (right != null) addCheck(variable, SUPER_OF, right)
	}

	def dispatch void doAnalyse(WVariable v) { /* does nothing */ }
	
	def dispatch void doAnalyse(WClosure it) {
		parameters.analyze
		expression.analyze
		addRule(new ClosureTypeRule(it, parameters, expression))
	}

	def dispatch void doAnalyse(WMemberFeatureCall it) {
		if (memberCallTarget instanceof WSelf) {
			addCheck(it, SAME_AS, method.declaringContext.lookupMethod(feature, memberCallArguments, true))
		}
		else {
			addRule(new MessageSendRule(it))
		}
	}

	def dispatch void doAnalyse(WConstructorCall it) {
		isA(new ClassBasedWollokType(classRef, null))
	}

	// literals
	def dispatch void doAnalyse(WNumberLiteral it) {
		// TODO: use classes from SDK. if (value.contains('.')) isOfClass(Double) || isOfClass(Integer)
		isOfClass(if (value.contains('.')) DOUBLE else INTEGER) 
	}
	def dispatch void doAnalyse(WStringLiteral it) { isOfClass(STRING) }
	def dispatch void doAnalyse(WBooleanLiteral it) { isOfClass(BOOLEAN) }
	def dispatch void doAnalyse(WNullLiteral it) { }
	def dispatch void doAnalyse(WListLiteral it) { isOfClass(LIST) }
	def dispatch void doAnalyse(WSetLiteral it) { isOfClass(SET) }
	
	
	def dispatch void doAnalyse(WParameter it) {
		// here it should inherit type from supermethod (if any)
		// also, if it's a closure parameter, it could infer type from usage
	}

	def dispatch void doAnalyse(WAssignment it) {
		isA(WVoid)
		if (value != null)
			addCheck(feature, SUPER_OF, value)
	}

	def dispatch void doAnalyse(WBinaryOperation it) {
		val opType = typeOfOperation(feature)
		// esto esta mal, no deberian ser facts, Sino expectations
		addFact(it, classType(opType.value))
		addFact(leftOperand, classType(opType.key.get(0)))
		addFact(rightOperand, classType(opType.key.get(1)))
	}

	def dispatch void doAnalyse(WVariableReference it) {
		addCheck(it, SAME_AS, ref)
	}

	def dispatch void doAnalyse(WIfExpression it) {
		addFact(condition, classType(BOOLEAN))
		addCheck(it, SUPER_OF, then)
		if (^else != null) 	addCheck(it, SUPER_OF, ^else)
	}

	def dispatch void doAnalyse(WBlockExpression it) {
		if (expressions.empty) {
			addFact(it, WVoid)
		}
		else {
			expressions.analyze
			addCheck(it, SAME_AS, expressions.last)
		}
	}
	
	def dispatch void doAnalyse(WReturnExpression it) {
		expression.analyze
		addCheck(it, SAME_AS, expression)
	}
	// ***************************
	// ** Inference (unification)
	// ***************************

	override inferTypes() {
		resolveRules
		unifyConstraints
	}

	protected def resolveRules() {
		var nrSteps = 0
		var resolved = true
		while (resolved) {
			println('Unify #' + nrSteps++)
			println(this.stateAsString)
			resolved = rules.clone.fold(false)[r, rule|
				// keep local variable to force execution (there's no non-shortcircuit 'or' in xtend! :S)
				val ruleValue = rule.resolve(this)
				r || ruleValue
			]
		}
	}

	protected def unifyConstraints() {

	}

	// ***************************
	// ** Query
	// ***************************

	override type(EObject obj) {
		val t = typeForExcept(obj, null) // horrible
		if (t == null) WAny
		else t
	}

	override issues(EObject obj) {
		val allIssues = rules.fold(newArrayList) [l, r|
			try
				r.check
			catch (TypeExpectationFailedException e)
				l.add(e)
			l
		]
		allIssues.filter[i| i.model == obj]
	}

	/**
	 * Returns the resolved type for the given object.
	 * Unless there are multiple resolved types.
	 * To resolve the type it asks all the rules (but the one passed as args).
	 * This is because probably from one rule you want to ask the type of one of its
	 * object but you don't want to the system to ask your rule back.
	 */
	def typeForExcept(EObject object, TypeRule unwantedRule) {
		val types = rules.fold(newArrayList)[l, r|
			if (r != unwantedRule) {
				val type = r.typeOf(object)
				if (type != null)
					l += type
			}
			l
		]
		if (types.size == 1)
			types.head
		else
			// multiple options ! conflict !
			null
	}

	// ***************************
	// ** Rules
	// ***************************

	def addRule(TypeRule rule) {
		if (!rules.contains(rule)) rules += rule
	}

	// shortcuts

	def addFact(EObject source, EObject model, WollokType knownType) {
		model.analyze
		addRule(new FactTypeRule(source, model, knownType))
	}
	def isAn(EObject model, WollokType knownType) { model.isA(knownType)	}
	def isA(EObject model, WollokType knownType) { model.addFact(model, knownType)	}
	def addCheck(EObject source, EObject a, TypeCheck check, EObject b) {
		a.analyze
		b.analyze
		addRule(new CheckTypeRule(source, a, check, b))
	}
	
	def isOfClass(EObject model, String className) { model.isA(classType(model, className)) }
	
	protected def ClassBasedWollokType classType(EObject model, String className) {
		val clazz = finder.getCachedClass(model, className)
		// REVIEWME: should we have a cache ?
		new ClassBasedWollokType(clazz, this)
	}

	def getStateAsString() {
		val leftValues = rules.map[ (ruleStateLeftPart -> ruleStateRightPart)]
		val maxLength = leftValues.map[key].maxBy[a | a.length].length

		'{' + System.lineSeparator + 
			'\t' + 
			leftValues.map[pair|
				StringUtils.padRight(pair.key, maxLength) + "\t" + pair.value
			].join(System.lineSeparator + "\t") + System.lineSeparator
	}

	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}