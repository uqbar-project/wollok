package org.uqbar.project.wollok.typesystem.constraints

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
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
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.element
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation

/**
 * @author npasserini
 */
class ConstraintGenerator {
	extension ConstraintBasedTypeSystem typeSystem
	extension TypeVariablesRegistry registry

	val Logger log = Logger.getLogger(this.class)

	OverridingConstraintsGenerator overridingConstraintsGenerator
	ConstructorConstraintsGenerator constructorConstraintsGenerator

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
		this.overridingConstraintsGenerator = new OverridingConstraintsGenerator(registry)
		this.constructorConstraintsGenerator = new ConstructorConstraintsGenerator(registry)
	}

	// ************************************************************************
	// ** First pass
	// ************************************************************************
	/**
	 * We have to to two passes through the program. The first one just adds globals, 
	 * so that they are visible during constraint generation.
	 */
	def dispatch void addGlobals(EObject it) {
		// By default we do nothing.
	}

	def dispatch void addGlobals(WNamedObject it) {
		typeSystem.allTypes.add(objectType)
		newNamedObject
	}

	def dispatch void addGlobals(WClass it) {
		typeSystem.allTypes.add(classType)
	}

	// ************************************************************************
	// ** Second pass / whole constraint generation
	// ************************************************************************
	
	def dispatch void generateVariables(EObject node) {
		// Default case
		log.warn('''WARNING: Not generating constraints for: «node»''')
	}

	def dispatch void generateVariables(WFile it) {
		eContents.forEach[addGlobals]
		eContents.forEach[generateVariables]
	}

	def dispatch void generateVariables(WProgram it) {
		elements.forEach[generateVariables]
	}

	def dispatch void generateVariables(WNamedObject it) {
		members.forEach[generateVariables]
	}

	def dispatch void generateVariables(WClass it) {

		// TODO Process supertype information: parent and mixins
		members.forEach[generateVariables]
		constructors.forEach[generateVariables]
	}

	def dispatch void generateVariables(WConstructor it) {
		// TODO Process superconstructor information.
		parameters.forEach[generateVariables]
		expression?.generateVariables
	}

	def dispatch void generateVariables(WMethodDeclaration it) {
		it.newTypeVariable
		parameters.forEach[generateVariables]

		if (!abstract) {
			expression?.generateVariables
			// Return type for compact methods (others are handled by return expressions)
			if (expressionReturns) beSupertypeOf(expression) else if (tvar.subtypes.empty) beVoid
		}

		if (overrides) overridingConstraintsGenerator.addMethodOverride(it)
	}

	def dispatch void generateVariables(WClosure it) {
		newTypeVariable //For returns
		parameters.forEach[generateVariables]
		expression.generateVariables
		
		val containsReturn = !tvar.subtypes.empty 
		val returnVar = if (containsReturn) tvar else expression.tvar
			
		newClosure(parameters.map[tvar], returnVar)
	}

	def dispatch void generateVariables(WParameter it) {
		newTypeVariable
	}

	def dispatch void generateVariables(WBlockExpression it) {
		expressions.forEach[ generateVariables ]

		it.newTypeVariable

		if (!expressions.empty) it.beSupertypeOf(expressions.last) else it.beVoid
	}

	def dispatch void generateVariables(WNumberLiteral it) {
		newSealed(classType(NUMBER))
	}

	def dispatch void generateVariables(WStringLiteral it) {
		newSealed(classType(STRING))
	}

	def dispatch void generateVariables(WBooleanLiteral it) {
		newSealed(classType(BOOLEAN))
	}

	def dispatch void generateVariables(WListLiteral it) {
		val listType = newCollection(classType(LIST))
		
		elements.forEach[
			generateVariables
			tvar.beSubtypeOf(listType.element)
		]
	}

	def dispatch void generateVariables(WSetLiteral it) {
		val setType = newCollection(classType(SET))

		elements.forEach[
			generateVariables
			tvar.beSubtypeOf(setType.element)
		]
	}

	def dispatch void generateVariables(WConstructorCall it) {
		/*
		 * NOT SURE FOR NOW - Dodain
		val associatedConstructor = constructor
		associatedConstructor?.generateVariables
		*/
		arguments.forEach [ generateVariables ]
		newSealed(classType(classRef))

		constructorConstraintsGenerator.addConstructorCall(it)
	}

	def dispatch void generateVariables(WAssignment it) {
		value.generateVariables
		feature.ref.tvar.beSupertypeOf(value.tvar)
		newVoid
	}

	def dispatch void generateVariables(WPostfixOperation it) {
		(operand as WVariableReference).ref.newSealed(classType(NUMBER))
		operand.generateVariables
		newVoid
	}
	
	def dispatch void generateVariables(WVariableReference it) {
		it.newWithSubtype(ref)
	}
	
	def dispatch void generateVariables(WSelf it) {
		it.newSealed(declaringContext.asWollokType)
	}

	def dispatch void generateVariables(WUnaryOperation it) {
		if (feature.equals("!")) {
			newSealed(classType(BOOLEAN))
		}
		operand.generateVariables
	}

	def dispatch void generateVariables(WIfExpression it) {
		condition.generateVariables
		condition.beSealed(classType(BOOLEAN))

		then.generateVariables

		if (getElse !== null) {
			getElse.generateVariables

			// If there is a else branch, if can be an expression 
			// and has to be a supertype of both (else, then) branches
			it.newWithSubtype(then, getElse)
		} else {
			// If there is no else branch, if is NOT an expression, 
			// it is a (void) statement.
			newVoid
		}
	}

	def dispatch void generateVariables(WVariableDeclaration it) {
		variable.newTypeVariable()

		if (right !== null) {
			right.generateVariables
			variable.beSupertypeOf(right)
		}

		it.newVoid
	}

	def dispatch void generateVariables(WMemberFeatureCall it) {
		memberCallTarget.generateVariables
		memberCallArguments.forEach[generateVariables]
		memberCallTarget.tvar.messageSend(feature, memberCallArguments.map[tvar], it.newTypeVariable)
	}

	def dispatch void generateVariables(WBinaryOperation it) {
		leftOperand.generateVariables
		rightOperand.generateVariables

		if (isMultiOpAssignment) {
			// Handling something of the form "a += b"
			val operator = feature.substring(0, 1)
			leftOperand.tvar.messageSend(operator, newArrayList(rightOperand.tvar), TypeVariable.synthetic)
			it.newVoid
		}
		else {
			// Handling a proper BinaryExpression, such as "a + b"
			leftOperand.tvar.messageSend(feature, newArrayList(rightOperand.tvar), it.newTypeVariable)
		}
	}

	def dispatch void generateVariables(WReturnExpression it) {
		newTypeVariable
		expression.generateVariables
		declaringContainer.beSupertypeOf(expression)
		beVoid
	}

	// ************************************************************************
	// ** Method overriding
	// ************************************************************************
	def addCrossReferenceConstraints() {
		overridingConstraintsGenerator.run()
		constructorConstraintsGenerator.run()
	}

	def newNamedObject(WNamedObject it) {
		it.newSealed(it.objectType)
	}

	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	def beSupertypeOf(EObject supertype, EObject subtype) {
		supertype.tvar.beSupertypeOf(subtype.tvar)
	}

	def dispatch WollokType asWollokType(WNamedObject object) {
		objectType(object)
	}

	def dispatch WollokType asWollokType(WClass wClass) {
		classType(wClass)
	}
}
