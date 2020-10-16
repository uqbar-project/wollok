package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
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
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.ProgramElementTypeVariableOwner
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo

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
		parameters.forEach[p|effectDepends(p)]
		if (expression !== null) {
			effectDepends(expression)
		}
	}

	def dispatch void generate(WClosure it) {
		parameters.forEach[generateVariables]
		expression.generateVariables
		literal
	}

	def dispatch void generate(WBlockExpression it) {
		if (expressions.empty) {
			effectStatus(Nothing)
		} else {
			expressions.forEach[e|effectDepends(e)]
		}
	}

	def dispatch void generate(WReturnExpression it) {
		returnContext.body.effectDepends(expression)
	}

	def dispatch void generate(WParameter it) {
		effectStatus(Nothing)
	}

	def dispatch void generate(WFixture it) {
		elements.forEach[generateVariables]
	}

	def dispatch void generate(WTest it) {
		elements.forEach[generateVariables]
	}

	// ************************************************************************
	// ** Message sending
	// ************************************************************************
	def dispatch void generate(WMemberFeatureCall it) {
		effectDepends(memberCallTarget)
		memberCallArguments.forEach[args|effectDepends(args)]
	}

	def dispatch void generate(WBinaryOperation it) {
		effectDepends(leftOperand)
		effectDepends(rightOperand)
		if (isMultiOpAssignment) {
			// Handling something of the form "a += b"
			effectStatus(Change)
		}
	}

	def dispatch void generate(WUnaryOperation it) {
		effectDepends(operand)
	}

	def dispatch void generate(WPostfixOperation it) {
		effectDepends(operand)
		effectStatus(Change)
	}

	// ************************************************************************
	// ** Constructor calling
	// ************************************************************************
	def dispatch void generate(WConstructorCall it) {
		if (hasNamedParameters) {
			initializers.forEach[generateVariables]
		} else {
			it.values.forEach[arg|effectDepends(arg)]
		}
		effectStatus(Nothing)
	}

	def dispatch void generate(WInitializer it) {
		declaringConstructorCall.effectDepends(initialValue)
	}

	// ************************************************************************
	// ** Variables
	// ************************************************************************
	def dispatch void generate(WVariableDeclaration it) {
		if (right !== null) {
			effectDepends(right)
		}
	}

	def dispatch void generate(WAssignment it) {
		effectDepends(value)
		effectStatus(Change(feature.ref.declarationContext.tvarEffect))
	}
	
	//TODO: Abstraer esto
	def dispatch tvarEffect(EObject it) { if (isGlobal) null else tvar }
	def dispatch tvarEffect(WClass it) { TypeVariable.methodTypeParameter(asOwner, new GenericType(it, typeSystem), "", GenericTypeInfo.SELF ) => [ register ] }


	//TODO: Duplicated
	def asOwner(EObject programElement) {
		new ProgramElementTypeVariableOwner(programElement)
	}

	// ************************************************************************
	// ** Flow control
	// ************************************************************************
	def dispatch void generate(WIfExpression it) {
		effectDepends(condition)
		effectDepends(then)
		if (getElse !== null) {
			effectDepends(getElse)
		}
	}

	def dispatch void generate(WThrow it) {
		effectDepends(exception)
		effectStatus(ThrowException)
	}

	def dispatch void generate(WTry it) {
		effectDepends(expression)
		catchBlocks.forEach[block|effectDepends(block)]
		if (alwaysExpression !== null) {
			effectDepends(alwaysExpression)
		}
	}

	def dispatch void generate(WCatch it) {
		effectDepends(expression)
	}

	// ************************************************************************
	// ** Literals & terminals
	// ************************************************************************
	def void literal(EObject it) { effectStatus(Nothing) }

	def dispatch void generate(WNumberLiteral it) { literal }

	def dispatch void generate(WStringLiteral it) { literal }

	def dispatch void generate(WBooleanLiteral it) { literal }

	def dispatch void generate(WListLiteral it) {
		literal
		elements.forEach[e|effectDepends(e)]
	}

	def dispatch void generate(WSetLiteral it) {
		literal
		elements.forEach[e|effectDepends(e)]
	}

	def dispatch void generate(WVariableReference it) {
		effectStatus(Nothing)
	}

	def dispatch void generate(WSelf it) { literal }

	def dispatch void generate(WNullLiteral it) { literal }

	def dispatch void generate(WSuperInvocation it) {
		memberCallArguments.forEach[arg|effectDepends(arg)]
		effectDepends(superMethod)
	}

	def dispatch void generate(WSelfDelegatingConstructorCall it) {
		arguments.forEach[arg|effectDepends(arg)]
		effectDepends(declaringContext.resolveConstructorReference(it))
		declaringConstructor.effectDepends(it)
	}

	def dispatch void generate(WSuperDelegatingConstructorCall it) {
		arguments.forEach[arg|effectDepends(arg)]
		effectDepends(declaringContext.resolveConstructorReference(it))
		declaringConstructor.effectDepends(it)
	}

	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	def effectDepends(EObject supertype, EObject subtype) {
		subtype.generateVariables
		supertype.tvar.effectDependencies.add(subtype.tvar)
	}

	def effectStatus(EObject node, EffectStatus status) {
		node.tvar.effectStatus = status
	}
}
