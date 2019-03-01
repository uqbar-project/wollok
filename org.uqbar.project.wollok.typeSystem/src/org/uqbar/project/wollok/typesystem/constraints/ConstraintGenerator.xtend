package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSelfDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * @author npasserini
 */
class ConstraintGenerator {
	extension ConstraintBasedTypeSystem typeSystem
	extension TypeVariablesRegistry registry

	OverridingConstraintsGenerator overridingConstraintsGenerator
	ConstructorConstraintsGenerator constructorConstraintsGenerator
	SuperInvocationConstraintsGenerator superInvocationConstraintsGenerator
	DelegatingConstructorCallConstraintsGenerator delegatingConstructorCallConstraintsGenerator
	UnaryOperationsConstraintsGenerator unaryOperationsConstraintsGenerator

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
		this.overridingConstraintsGenerator = new OverridingConstraintsGenerator(registry)
		this.constructorConstraintsGenerator = new ConstructorConstraintsGenerator(registry)
		this.superInvocationConstraintsGenerator = new SuperInvocationConstraintsGenerator(registry)
		this.delegatingConstructorCallConstraintsGenerator = new DelegatingConstructorCallConstraintsGenerator(registry)
		this.unaryOperationsConstraintsGenerator = new UnaryOperationsConstraintsGenerator(typeSystem)
	}

	// ************************************************************************
	// ** First pass
	// ************************************************************************
	/**
	 * We have two passes through the program. The first one just adds globals, 
	 * so that they are visible during constraint generation.
	 */
	def dispatch void addGlobals(EObject it) {
		// By default we do nothing.
	}

	def dispatch void addGlobals(WFile it) {
		eContents.forEach[addGlobals]
	}

	def dispatch void addGlobals(WNamedObject it) {
		typeSystem.allTypes.add(objectType)
		newTypeVariable.beSealed(objectType)
	}

	def dispatch void addGlobals(WClass it) {
		typeSystem.allTypes.add(classType)
	}

	// ************************************************************************
	// ** Second pass / whole constraint generation
	// ************************************************************************
	def void generateVariables(EObject it) {
		try {
			generate
		} catch (Exception e) {
			addFatalError(e)
		}
	}

	// ************************************************************************
	// ** Containers & top level
	// ************************************************************************
	def dispatch void generate(WFile it) {
		eContents.forEach[generateVariables]
	}

	def dispatch void generate(Import it) {}

	def dispatch void generate(WProgram it) {
		elements.forEach[generateVariables]
	}

	def dispatch void generate(WNamedObject it) {
		// TODO Process supertype information: parent and mixins
		members.forEach[generateVariables]
	}

	def dispatch void generate(WClass it) {
		// TODO Process supertype information: parent and mixins
		members.forEach[generateVariables]
		constructors.forEach[generateVariables]
	}

	def dispatch void generate(WObjectLiteral it) {
		// TODO Process supertype information: parent and mixins
		members.forEach[generateVariables]
		newTypeVariable.beSealed(objectLiteralType(it))
	}

	// ************************************************************************
	// ** Methods and closures
	// ************************************************************************
	def dispatch void generate(WConstructor it) {
		// TODO Process superconstructor information.
		parameters.forEach[generateVariables]
		expression?.generateVariables
		delegatingConstructorCall?.generateVariables
	}

	def dispatch void generate(WMethodDeclaration it) {
		newTypeVariable
		parameters.forEach[generateVariables]

		if (!abstract) {
			expression?.generateVariables
			if(hasReturnType) beSupertypeOf(expression) // Return type is taken from the body
			else beVoid // Otherwise, method is void.
		}

		if(overrides) overridingConstraintsGenerator.add(it)
	}

	def dispatch void generate(WClosure it) {
		parameters.forEach[generateVariables]
		expression.generateVariables

		val closureType = closureType(parameters.length).instanceFor(newTypeVariable)

		beSealed(closureType)
		parameters.forEach [ parameter, index |
			val paramName = GenericTypeInfo.PARAM(index)
			closureType.param(paramName).beSubtypeOf(parameter.tvar)
		]
		closureType.param(GenericTypeInfo.RETURN).beSupertypeOf(expression.tvar)
	}

	def dispatch void generate(WBlockExpression it) {
		newTypeVariable
		expressions.forEach[generateVariables]

		val containsReturn = !tvar.subtypes.empty
		if (!containsReturn)
			if(!expressions.empty) beSupertypeOf(expressions.last) else beVoid
	}

	def dispatch void generate(WReturnExpression it) {
		newTypeVariable
		expression.generateVariables
		returnContext.body.beSupertypeOf(expression)
		beVoid
	}

	def dispatch void generate(WParameter it) {
		newTypeVariable.beNonVoid
	}

	// ************************************************************************
	// ** Message sending
	// ************************************************************************
	def dispatch void generate(WMemberFeatureCall it) {
		memberCallTarget.generateVariables
		memberCallArguments.forEach[generateVariables]
		memberCallTarget.tvar.messageSend(feature, memberCallArguments.map[tvar], it.newTypeVariable)
	}

	def dispatch void generate(WBinaryOperation it) {
		leftOperand.generateVariables
		rightOperand.generateVariables

		if (isMultiOpAssignment) {
			// Handling something of the form "a += b"
			newTypeVariable => [beVoid]
			val operator = feature.substring(0, 1)
			leftOperand.tvar.messageSend(operator, newArrayList(rightOperand.tvar),
				newParameter(tvar.owner, "ignoredResult"))
		} else {
			// Handling a proper BinaryExpression, such as "a + b"
			leftOperand.tvar.messageSend(feature, newArrayList(rightOperand.tvar), newTypeVariable)
		}
	}

	def dispatch void generate(WUnaryOperation it) {
		operand.generateVariables
		unaryOperationsConstraintsGenerator.generate(it)
	}

	def dispatch void generate(WPostfixOperation it) {
		(operand as WVariableReference).ref.asOwner.newSealed(classType(NUMBER))
		operand.generateVariables
		newTypeVariable.beVoid
	}

	// ************************************************************************
	// ** Constructor calling
	// ************************************************************************
	def dispatch void generate(WConstructorCall it) {
		arguments.forEach[arg|arg.generateVariables]
		beSealed(typeOrFactory(classRef).instanceFor(newTypeVariable))
		constructorConstraintsGenerator.add(it)
	}

	def dispatch void generate(WInitializer it) {
		val instantiatedClass = declaringConstructorCall.classRef
		val initializedVariable = instantiatedClass.getVariableDeclaration(initializer.name)

		initialValue.generateVariables
		initializedVariable.variable.beSupertypeOf(initialValue)
	}

	// ************************************************************************
	// ** Variables
	// ************************************************************************
	def dispatch void generate(WVariableDeclaration it) {
		variable.newTypeVariable.beNonVoid

		if (right !== null) {
			right.generateVariables
			variable.beSupertypeOf(right)
		}

		newTypeVariable.beVoid
	}

	def dispatch void generate(WAssignment it) {
		value.generateVariables
		feature.ref.tvar.beSupertypeOf(value.tvar)
		newTypeVariable.beVoid
	}

	// ************************************************************************
	// ** Flow control
	// ************************************************************************
	def dispatch void generate(WIfExpression it) {
		condition.generateVariables
		condition.beSealed(classType(BOOLEAN))

		then.generateVariables

		if (getElse !== null) {
			getElse.generateVariables

			// If there is a else branch, if can be an expression 
			// and has to be a supertype of both (else, then) branches
			newTypeVariable => [ v |
				v.beSupertypeOf(then.tvar)
				v.beSupertypeOf(getElse.tvar)
			]
		} else {
			// If there is no else branch, if is NOT an expression, 
			// it is a (void) statement.
			newTypeVariable.beVoid
		}
	}

	def dispatch void generate(WThrow it) {
		exception.generateVariables
		newTypeVariable.beVoid
	}

	def dispatch void generate(WTry it) {
		expression.generateVariables
		catchBlocks.forEach[generateVariables]
		alwaysExpression?.generateVariables
		newTypeVariable.beVoid
	}

	def dispatch void generate(WCatch it) {
		exceptionVarName.newTypeVariable => [ tvar |
			if (exceptionType !== null)
				tvar.beSealed(classType(exceptionType))
			else
				tvar.beNonVoid
		]
		expression.generateVariables
	}

	// ************************************************************************
	// ** Literals & terminals
	// ************************************************************************
	def dispatch void generate(WNumberLiteral it) {
		newTypeVariable.beSealed(classType(NUMBER))
	}

	def dispatch void generate(WStringLiteral it) {
		newTypeVariable.beSealed(classType(STRING))
	}

	def dispatch void generate(WBooleanLiteral it) {
		newTypeVariable.beSealed(classType(BOOLEAN))
	}

	def dispatch void generate(WListLiteral it) {
		val listType = genericType(LIST, GenericTypeInfo.ELEMENT).instanceFor(newTypeVariable)
		val paramType = listType.param(GenericTypeInfo.ELEMENT)

		beSealed(listType)
		elements.forEach [
			generateVariables
			paramType.beSupertypeOf(tvar)
		]
	}

	def dispatch void generate(WSetLiteral it) {
		val setType = genericType(SET, GenericTypeInfo.ELEMENT).instanceFor(newTypeVariable)
		val paramType = setType.param(GenericTypeInfo.ELEMENT)

		beSealed(setType)
		elements.forEach [
			generateVariables
			paramType.beSupertypeOf(tvar)
		]
	}

	def dispatch void generate(WVariableReference it) {
		if (ref.eIsProxy) {
			// Reference could not be resolved, we can't add constraint with the referenced element.
			// So we know almost nothing, but a variable reference can not be void.
			newTypeVariable.beNonVoid
		} else {
			newTypeVariable.beSupertypeOf(ref.tvar)
		}
	}

	def dispatch void generate(WSelf it) {
		asOwner.newSealed(declaringContext.asWollokType)
	}

	def dispatch void generate(WNullLiteral it) {
		// Now only generate ANY variable. 
		// Maybe we'll want another kind of variable for nullable types implementation.  
		newTypeVariable
	}

	def dispatch void generate(WSuperInvocation it) {
		newTypeVariable
		memberCallArguments.forEach[generateVariables]
		superInvocationConstraintsGenerator.add(it)
	}
	

	def dispatch void generate(WSelfDelegatingConstructorCall it) {
		newTypeVariable
		arguments.forEach[generateVariables]
		delegatingConstructorCallConstraintsGenerator.add(it)
	}

	def dispatch void generate(WSuperDelegatingConstructorCall it) {
		newTypeVariable
		arguments.forEach[generateVariables]
		delegatingConstructorCallConstraintsGenerator.add(it)
	}

	// ************************************************************************
	// ** Method overriding
	// ************************************************************************
	def addCrossReferenceConstraints() {
		overridingConstraintsGenerator.run()
		constructorConstraintsGenerator.run()
		superInvocationConstraintsGenerator.run()
		delegatingConstructorCallConstraintsGenerator.run()
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
