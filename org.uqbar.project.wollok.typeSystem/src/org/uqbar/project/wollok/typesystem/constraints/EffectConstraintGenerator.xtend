package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WSuite

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WParameter

/**
 * @author npasserini
 */
class EffectConstraintGenerator {
	extension ConstraintBasedTypeSystem typeSystem
	extension TypeVariablesRegistry registry

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
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

	def dispatch void generate(Import it) {
		// Nothing?
	}

	def dispatch void generate(WProgram it) {
		elements.forEach[generateVariables]
	}

	def dispatch void generate(WNamedObject it) {
		parentParameters?.arguments?.forEach[generateVariables]
		members.forEach[generateVariables]
	}

	def dispatch void generate(WClass it) {
		members.forEach[generateVariables]
		constructors.forEach[generateVariables]
	}

	def dispatch void generate(WObjectLiteral it) {
		parentParameters?.arguments?.forEach[generateVariables]
		members.forEach[generateVariables]
	}
	
	def dispatch void generate(WSuite it) {
		members.forEach[generateVariables]
		fixture?.generateVariables
		tests.forEach[generateVariables]
	}

	// ************************************************************************
	// ** Methods and closures
	// ************************************************************************

	def dispatch void generate(WMethodDeclaration it) {
		parameters.forEach[p | effectDepends(p)]
		if (expression !== null) { effectDepends(expression) }
	}

//	def dispatch void generate(WClosure it) {
//		parameters.forEach[generateVariables]
//		expression.generateVariables
//
//		val closureType = closureType(parameters.length).instanceFor(newTypeVariable)
//
//		beSealed(closureType)
//		parameters.forEach [ parameter, index |
//			val paramName = GenericTypeInfo.PARAM(index)
//			closureType.param(paramName).beSubtypeOf(parameter.tvar)
//		]
//		closureType.param(GenericTypeInfo.RETURN).beSupertypeOf(expression.tvar)
//	}

	def dispatch void generate(WBlockExpression it) {
		expressions.forEach[ e | effectDepends(e) ]
	}

	def dispatch void generate(WReturnExpression it) {
		returnContext.body.effectDepends(expression)
	}

	def dispatch void generate(WParameter it) {
		effectStatus(Nothing)
	}
//	
//	def dispatch void generate(WFixture it) {
//		elements.forEach[generateVariables]
//	}
//	
//	def dispatch void generate(WTest it) {
//		elements.forEach[generateVariables]
//	}
//
//	// ************************************************************************
//	// ** Message sending
//	// ************************************************************************
//	def dispatch void generate(WMemberFeatureCall it) {
//		memberCallTarget.generateVariables
//		memberCallArguments.forEach[generateVariables]
//		memberCallTarget.tvar.messageSend(feature, memberCallArguments.map[tvar], it.newTypeVariable)
//	}
//
//	def dispatch void generate(WBinaryOperation it) {
//		leftOperand.generateVariables
//		rightOperand.generateVariables
//
//		if (isMultiOpAssignment) {
//			// Handling something of the form "a += b"
//			newTypeVariable => [beVoid]
//			val operator = feature.substring(0, 1)
//			leftOperand.tvar.messageSend(operator, newArrayList(rightOperand.tvar),
//				newParameter(tvar.owner, "ignoredResult"))
//		} else {
//			// Handling a proper BinaryExpression, such as "a + b"
//			leftOperand.tvar.messageSend(feature, newArrayList(rightOperand.tvar), newTypeVariable)
//		}
//	}
//
//	def dispatch void generate(WUnaryOperation it) {
//		operand.generateVariables
//		unaryOperationsConstraintsGenerator.generate(it)
//	}
//
//	def dispatch void generate(WPostfixOperation it) {
//		(operand as WVariableReference).ref.asOwner.newSealed(classType(NUMBER))
//		operand.generateVariables
//		newTypeVariable.beVoid
//	}
//
//	// ************************************************************************
//	// ** Constructor calling
//	// ************************************************************************
//	def dispatch void generate(WConstructorCall it) {
//		arguments.forEach[arg|arg.generateVariables]
//		beSealed(typeOrFactory(classRef).instanceFor(newTypeVariable))
//		constructorCallConstraintsGenerator.add(it)
//	}
//
//	def dispatch void generate(WInitializer it) {
//		initialValue.generateVariables
//		initializerConstraintsGenerator.add(it)
//	}
//	
//	// ************************************************************************
//	// ** Variables
//	// ************************************************************************
//	def dispatch void generate(WVariableDeclaration it) {
//		variable.newTypeVariable.beNonVoid
//
//		if (right !== null) {
//			right.generateVariables
//			variable.beSupertypeOf(right)
//		}
//
//		newTypeVariable.beVoid
//	}
//
	def dispatch void generate(WAssignment it) {
		effectStatus(Change)
	}
//
//	// ************************************************************************
//	// ** Flow control
//	// ************************************************************************
//	def dispatch void generate(WIfExpression it) {
//		condition.generateVariables
//		condition.beSealed(classType(BOOLEAN))
//
//		then.generateVariables
//
//		if (getElse !== null) {
//			getElse.generateVariables
//
//			// If there is a else branch, if can be an expression 
//			// and has to be a supertype of both (else, then) branches
//			newTypeVariable => [ v |
//				v.beSupertypeOf(then.tvar)
//				v.beSupertypeOf(getElse.tvar)
//			]
//		} else {
//			// If there is no else branch, if is NOT an expression, 
//			// it is a (void) statement.
//			newTypeVariable.beVoid
//		}
//	}
//
//	def dispatch void generate(WThrow it) {
//		exception.generateVariables
//		newTypeVariable.beVoid
//	}
//
//	def dispatch void generate(WTry it) {
//		expression.generateVariables
//		catchBlocks.forEach[generateVariables]
//		alwaysExpression?.generateVariables
//		newTypeVariable.beVoid
//	}
//
//	def dispatch void generate(WCatch it) {
//		exceptionVarName.newTypeVariable => [ tvar |
//			if (exceptionType !== null)
//				tvar.beSealed(classType(exceptionType))
//			else
//				tvar.beNonVoid
//		]
//		expression.generateVariables
//	}
//
	// ************************************************************************
	// ** Literals & terminals
	// ************************************************************************
	
	def dispatch void generate(WNumberLiteral it) { effectStatus(Nothing) }
//
//	def dispatch void generate(WStringLiteral it) {
//		newTypeVariable.beSealed(classType(STRING))
//	}
//
//	def dispatch void generate(WBooleanLiteral it) {
//		newTypeVariable.beSealed(classType(BOOLEAN))
//	}
//
//	def dispatch void generate(WListLiteral it) {
//		val listType = genericType(LIST, GenericTypeInfo.ELEMENT).instanceFor(newTypeVariable)
//		val paramType = listType.param(GenericTypeInfo.ELEMENT)
//
//		beSealed(listType)
//		elements.forEach [
//			generateVariables
//			paramType.beSupertypeOf(tvar)
//		]
//	}
//
//	def dispatch void generate(WSetLiteral it) {
//		val setType = genericType(SET, GenericTypeInfo.ELEMENT).instanceFor(newTypeVariable)
//		val paramType = setType.param(GenericTypeInfo.ELEMENT)
//
//		beSealed(setType)
//		elements.forEach [
//			generateVariables
//			paramType.beSupertypeOf(tvar)
//		]
//	}
//
//	def dispatch void generate(WVariableReference it) {
//		if (ref.eIsProxy) {
//			// Reference could not be resolved, we can't add constraint with the referenced element.
//			// So we know almost nothing, but a variable reference can not be void.
//			newTypeVariable.beNonVoid
//		} else {
//			newTypeVariable.beSupertypeOf(ref.tvar)
//		}
//	}
//
//	def dispatch void generate(WSelf it) {
//		asOwner.newSealed(declaringContext.asWollokType)
//	}
//
//	def dispatch void generate(WNullLiteral it) {
//		// Now only generate ANY variable. 
//		// Maybe we'll want another kind of variable for nullable types implementation.  
//		newTypeVariable
//	}
//
//	def dispatch void generate(WSuperInvocation it) {
//		newTypeVariable
//		memberCallArguments.forEach[generateVariables]
//		superInvocationConstraintsGenerator.add(it)
//	}
//	
//
//	def dispatch void generate(WSelfDelegatingConstructorCall it) {
//		newTypeVariable
//		arguments.forEach[generateVariables]
//		delegatingConstructorCallConstraintsGenerator.add(it)
//	}
//
//	def dispatch void generate(WSuperDelegatingConstructorCall it) {
//		newTypeVariable
//		arguments.forEach[generateVariables]
//		delegatingConstructorCallConstraintsGenerator.add(it)
//	}


	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	def effectDepends(EObject supertype, EObject subtype) {
		subtype.generateVariables
		supertype.tvar.effectDependencies.add(subtype.tvar)
	}
	
	def effectStatus(EObject node, EffectStatus status) {
		node.tvar.effectStatus= status
	}
}
