package org.uqbar.project.wollok.typesystem.substitutions

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.typesystem.TypeSystemUtils.*
import static org.uqbar.project.wollok.typesystem.substitutions.TypeCheck.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * Implementation that builds up rules
 * and the goes through several steps substituting types.
 *
 * @author jfernandes
 */
class SubstitutionBasedTypeSystem implements TypeSystem {
	List<TypeRule> rules = newArrayList
	// esto me gustaria evitarlo :S
	Set<EObject> analyzed = newHashSet

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

	def dispatch void doAnalyse(WClass it) { if (members != null) members.forEach[analyze] }
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

	def dispatch void doAnalyse(WMemberFeatureCall it) {
		if (memberCallTarget instanceof WSelf)
			addCheck(it, SAME_AS, method.declaringContext.lookupMethod(feature, memberCallArguments, true))
	}

	def dispatch void doAnalyse(WConstructorCall it) {
		isA(new ClassBasedWollokType(classRef, null))
	}

	// literals
	def dispatch void doAnalyse(WNumberLiteral it) { isAn(WInt)  }
	def dispatch void doAnalyse(WStringLiteral it) { isA(WString) }
	def dispatch void doAnalyse(WBooleanLiteral it) { isA(WBoolean) }
	def dispatch void doAnalyse(WNullLiteral it) { }
	def dispatch void doAnalyse(WParameter it) {
		// here it should inherit type from supermethod (if any)
		// also, if it's a closure parameter, it could infer type from usage
	}

	def dispatch void doAnalyse(WAssignment it) {
		isA(WVoid)
		addCheck(feature, SUPER_OF, value)
	}

	def dispatch void doAnalyse(WBinaryOperation it) {
		val opType = typeOfOperation(feature)
		// esto esta mal, no deberian ser facts, Sino expectations
		addFact(it, opType.value)
		addFact(leftOperand, opType.key.get(0))
		addFact(rightOperand, opType.key.get(1))
	}

	def dispatch void doAnalyse(WVariableReference it) {
		addCheck(it, SAME_AS, ref)
	}

	def dispatch void doAnalyse(WIfExpression it) {
		addFact(condition, WBoolean)
		addCheck(it, SUPER_OF, then)
		if (^else != null) 	addCheck(it, SUPER_OF, ^else)
	}

	def dispatch void doAnalyse(WBlockExpression it) {
		if (!expressions.empty) {
			expressions.analyze
			addCheck(it, SAME_AS, expressions.last)
		}
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
//			println('Unify #' + nrSteps++)
//			println(this)
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

	override toString() {
		'{' + System.lineSeparator + '\t' + 
		rules.join(System.lineSeparator + "\t") + System.lineSeparator
	}

	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}