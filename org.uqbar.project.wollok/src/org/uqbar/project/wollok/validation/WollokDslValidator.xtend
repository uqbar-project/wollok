package org.uqbar.project.wollok.validation

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.Messages.*
import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.WollokConstants.*
import static extension org.uqbar.project.wollok.model.FlowControlExtensions.*
import static extension org.uqbar.project.wollok.model.WBlockExtensions.*
import static extension org.uqbar.project.wollok.model.WEvaluationExtension.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WVariableReferenceElements
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation

/**
 * Custom validation rules.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 *
 * @author jfernandes
 */
class WollokDslValidator extends AbstractConfigurableDslValidator {
	List<WollokValidatorExtension> wollokValidatorExtensions
	@Inject
	WollokClassFinder classFinder
	@Inject
	WollokGlobalScopeProvider scopeProvider

	// ERROR KEYS
	public static val CANNOT_ASSIGN_TO_VAL = "CANNOT_ASSIGN_TO_VAL"
	public static val CANNOT_ASSIGN_TO_ITSELF = "CANNOT_ASSIGN_TO_ITSELF"
	public static val CANNOT_ASSIGN_TO_NON_MODIFIABLE = "CANNOT_ASSIGN_TO_NON_MODIFIABLE"
	public static val CANNOT_INSTANTIATE_ABSTRACT_CLASS = "CANNOT_INSTANTIATE_ABSTRACT_CLASS"
	public static val CLASS_NAME_MUST_START_UPPERCASE = "CLASS_NAME_MUST_START_UPPERCASE"
	public static val REFERENCIABLE_NAME_MUST_START_LOWERCASE = "REFERENCIABLE_NAME_MUST_START_LOWERCASE"
	public static val PARAMETER_NAME_MUST_START_LOWERCASE = "PARAMETER_NAME_MUST_START_LOWERCASE"
	public static val VARIABLE_NAME_MUST_START_LOWERCASE = "VARIABLE_NAME_MUST_START_LOWERCASE"
	public static val OBJECT_NAME_MUST_START_LOWERCASE = "OBJECT_NAME_MUST_START_LOWERCASE"
	public static val METHOD_ON_THIS_DOESNT_EXIST = "METHOD_ON_THIS_DOESNT_EXIST"
	public static val METHOD_ON_WKO_DOESNT_EXIST = "METHOD_ON_WKO_DOESNT_EXIST"
	public static val VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES = "VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES"
	public static val METHOD_MUST_HAVE_OVERRIDE_KEYWORD = "METHOD_MUST_HAVE_OVERRIDE_KEYWORD"
	public static val OVERRIDING_METHOD_MUST_RETURN_VALUE = "OVERRIDING_METHOD_MUST_RETURN_VALUE"
	public static val OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE = "OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE"
	public static val GETTER_METHOD_SHOULD_RETURN_VALUE = "GETTER_METHOD_SHOULD_RETURN_VALUE"
	public static val ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS = "ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS"
	public static val REQUIRED_SUPERCLASS_CONSTRUCTOR = "REQUIRED_SUPERCLASS_CONSTRUCTOR"
	public static val DUPLICATED_CONSTRUCTOR = "DUPLICATED_CONSTRUCTOR"
	public static val MUST_CALL_SUPER = "MUST_CALL_SUPER"
	public static val TYPE_SYSTEM_ERROR = "TYPE_SYSTEM_ERROR"
	public static val NATIVE_METHOD_CANNOT_OVERRIDES = "NATIVE_METHOD_CANNOT_OVERRIDES"
	public static val BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION = "BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION"
	public static val CONSTRUCTOR_IN_SUPER_DOESNT_EXIST = "CONSTRUCTOR_IN_SUPER_DOESNT_EXIST"
	public static val METHOD_DOESNT_OVERRIDE_ANYTHING = "METHOD_DOESNT_OVERRIDE_ANYTHING"
	public static val DUPLICATED_METHOD = "DUPLICATED_METHOD"
	public static val VARIABLE_NEVER_ASSIGNED = "VARIABLE_NEVER_ASSIGNED"
	public static val RETURN_FORGOTTEN = "RETURN_FORGOTTEN"
	public static val VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE = "VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE"

	// WARNING KEYS
	public static val WARNING_UNUSED_VARIABLE = "WARNING_UNUSED_VARIABLE"

	def validatorExtensions() {
		if (wollokValidatorExtensions != null)
			return wollokValidatorExtensions

		val configs = Platform.getExtensionRegistry.getConfigurationElementsFor("org.uqbar.project.wollok.wollokValidationExtension")
		wollokValidatorExtensions = configs.map[it.createExecutableExtension("class") as WollokValidatorExtension]
	}

	@Check
	@NotConfigurable
	def checkValidationExtensions(WFile wfile){
		validatorExtensions.forEach[ check(wfile, this)]
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def classNameMustStartWithUpperCase(WClass c) {
		if (Character.isLowerCase(c.name.charAt(0))) report(WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE, c, WNAMED__NAME, CLASS_NAME_MUST_START_UPPERCASE)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def referenciableNameMustStartWithLowerCase(WNamedObject c) {
		if (Character.isUpperCase(c.name.charAt(0))) report(WollokDslValidator_OBJECT_NAME_MUST_START_LOWERCASE, c, WNAMED__NAME, OBJECT_NAME_MUST_START_LOWERCASE)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def referenciableNameMustStartWithLowerCase(WParameter c) {
		if (Character.isUpperCase(c.name.charAt(0))) report(WollokDslValidator_PARAMETER_NAME_MUST_START_LOWERCASE, c, WNAMED__NAME, PARAMETER_NAME_MUST_START_LOWERCASE)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def referenciableNameMustStartWithLowerCase(WVariable c) {
		if (Character.isUpperCase(c.name.charAt(0))) report(WollokDslValidator_VARIABLE_NAME_MUST_START_LOWERCASE, c, WNAMED__NAME, VARIABLE_NAME_MUST_START_LOWERCASE)
	}	
	// **************************************
	// ** instantiation and constructors
	// **************************************

	@Check
	@DefaultSeverity(ERROR)
	def cannotInstantiateAbstractClasses(WConstructorCall it) {
		if (classRef == null) return
		val abstractMethods = classRef.unimplementedAbstractMethods
		if (!abstractMethods.empty) {
			val methodDescriptions = abstractMethods.map[methodName].join(", ")
			report('''«WollokDslValidator_MUST_IMPLEMENT_ABSTRACT_METHODS»: «methodDescriptions»''', it, WCONSTRUCTOR_CALL__CLASS_REF)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def invalidConstructorCall(WConstructorCall c) {
		if (!c.isValidConstructorCall()) {
			val expectedMessage =
				" new " + c.classRef.name +
					if (c.classRef.constructors == null)
						""
					else
						c.classRef.constructors.map[ '(' + parameters.map[name].join(",") + ')'].join(' or ')
			report(WollokDslValidator_WCONSTRUCTOR_CALL__ARGUMENTS +  expectedMessage, c, WCONSTRUCTOR_CALL__ARGUMENTS)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def requiredSuperClassConstructorCall(WClass it) {
		if (!hasConstructorDefinitions && superClassRequiresNonEmptyConstructor)
			report('''No default constructor in super type «parent.name». «name» must define an explicit constructor.''', it, WNAMED__NAME, REQUIRED_SUPERCLASS_CONSTRUCTOR)
	}

	@Check
	@DefaultSeverity(ERROR)
	def cannotHaveTwoConstructorsWithSameArity(WClass it) {
		val repeated = constructors.filter[c | constructors.exists[c2 | c2 != c && c.matches(c2.parameters.size)]]
		repeated.forEach[r|
			report("Duplicated constructor with same number of parameters", r, WCONSTRUCTOR__PARAMETERS, DUPLICATED_CONSTRUCTOR)
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	def construtorMustExpliclityCallSuper(WConstructor it) {
		if (delegatingConstructorCall == null && wollokClass.superClassRequiresNonEmptyConstructor) {
			report("Must call a super class constructor explicitly", it, WCONSTRUCTOR__PARAMETERS, MUST_CALL_SUPER)
		}
	}
	
	// SELF

	@Check
	@DefaultSeverity(ERROR)
	def cannotUseSelfInConstructorDelegation(WSelf it) {
		if (EcoreUtil2.getContainerOfType(it, WDelegatingConstructorCall) != null)
			report("Cannot access instance methods within constructor delegation.", it)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	def cannotUseSelfInAProgram(WSelf it) {
		if (!it.isInASelfContext)
			report(WollokDslValidator_CANNOT_USE_SELF_IN_A_PROGRAM, it)
	}

	@Check
	@DefaultSeverity(ERROR)
	def dontUseWKONameOnWKOUseSelfInstead(WVariableReference it) {
		if (it.ref == getSelfContext)
			report(WollokDslValidator_DONT_USE_WKONAME_WITHIN_IT, it)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	def cannotUseSuperInConstructorDelegation(WSuperInvocation it) {
		if (EcoreUtil2.getContainerOfType(it, WDelegatingConstructorCall) != null)
			report("Cannot access super methods within constructor delegation.", it)
	}

	@Check
	@DefaultSeverity(ERROR)
	def cannotUseInstanceVariablesInConstructorDelegation(WDelegatingConstructorCall it) {
		eAllContents.filter(WVariableReference).forEach[ref|
			if (ref.ref instanceof WVariable) {
				report("Cannot access instance variables within constructor delegation.", ref, WVARIABLE_REFERENCE__REF)
			}
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	def delegatedConstructorExists(WDelegatingConstructorCall it) {
		try {
			val resolved = it.wollokClass.resolveConstructorReference(it)
			if (resolved == null) {
				// we could actually show the available options
				report("Invalid constructor call. Does Not exist", it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL, CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
			}
		}
		catch (WollokRuntimeException e) {
			// mmm... terrible
			report("Invalid constructor call. Does Not exist", it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL, CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def methodActuallyOverrides(WMethodDeclaration m) {
		val overrides = m.actuallyOverrides
		if (m.overrides && !overrides) m.report(WollokDslValidator_METHOD_NOT_OVERRIDING, METHOD_DOESNT_OVERRIDE_ANYTHING)
		if (overrides && !m.overrides)
			m.report(WollokDslValidator_METHOD_MUST_HAVE_OVERRIDE_KEYWORD, METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	}

	@Check
	@DefaultSeverity(ERROR)
	def overridingMethodMustReturnAValueIfOriginalMethodReturnsAValue(WMethodDeclaration m) {
		if (m.overrides && !m.native) {
			val overriden = m.overridenMethod
			if (overriden != null && !overriden.abstract) {
				if (overriden.supposedToReturnValue && !m.returnsOnAllPossibleFlows)
					m.report(WollokDslValidator_OVERRIDING_METHOD_MUST_RETURN_VALUE, OVERRIDING_METHOD_MUST_RETURN_VALUE)
				if (!overriden.supposedToReturnValue && m.returnsOnAllPossibleFlows)
					m.report(WollokDslValidator_OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE, OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE)
			}
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def methodDoesNotReturnAValueOnEveryPossibleFlow(WMethodDeclaration it) {
		if (supposedToReturnValue  && !returnsOnAllPossibleFlows)
			report(WollokDslValidator_METHOD_DOES_NOT_RETURN_A_VALUE_ON_EVERY_POSSIBLE_FLOW)
	}

	@Check
	@DefaultSeverity(WARN)
	def getterMethodShouldReturnAValue(WMethodDeclaration m) {
		if (m.isGetter && !m.abstract && !m.supposedToReturnValue)
			m.report(WollokDslValidator_GETTER_METHOD_SHOULD_RETURN_VALUE, GETTER_METHOD_SHOULD_RETURN_VALUE)
	}

	@Check
	@DefaultSeverity(ERROR)
	def cannotReassignValues(WAssignment a) {
		if(!a.feature.ref.isModifiableFrom(a)) report(WollokDslValidator_CANNOT_MODIFY_VAL, a, WASSIGNMENT__FEATURE, cannotModifyErrorId(a.feature))
	}
	def dispatch String cannotModifyErrorId(WReferenciable it) { CANNOT_ASSIGN_TO_NON_MODIFIABLE }
	def dispatch String cannotModifyErrorId(WVariableDeclaration it) { CANNOT_ASSIGN_TO_VAL }
	def dispatch String cannotModifyErrorId(WVariableReference it) { cannotModifyErrorId(ref) }

	@Check
	@DefaultSeverity(ERROR)
	def cannotAssignToItself(WAssignment a) {
		if(!(a.value instanceof WVariableReference))
			return

		val rightSide = a.value as WVariableReference
		if(a.feature.ref == rightSide.ref)
			report(WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF, a, WASSIGNMENT__FEATURE, CANNOT_ASSIGN_TO_ITSELF)
	}

	@Check
	@DefaultSeverity(ERROR)
	def cannotAssignToItselfInVariableDeclaration(WVariableDeclaration a) {
		if(!(a.right instanceof WVariableReference))
			return

		val rightSide = a.right as WVariableReference
		if(a.variable == rightSide.ref)
			report(WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF, a, WVARIABLE_DECLARATION__VARIABLE, CANNOT_ASSIGN_TO_ITSELF)
	}

	@Check
	@DefaultSeverity(ERROR)
	def duplicatedMethod(WMethodDeclaration it) {
		// can we allow methods with same name but different arg size ?
		if (declaringContext.methods.exists[m | m != it && hasSameSignatureThan(m)] )
			report(WollokDslValidator_DUPLICATED_METHOD, DUPLICATED_METHOD)
	}

	@Check
	@DefaultSeverity(ERROR)
	def duplicatedVariableFromSuperclass(WMethodContainer m) {
		val inheritedVariables = m.parents.map[variables].flatten
		m.variables.filter[v | inheritedVariables.exists[name == v.name ]]
		.forEach [
			report(WollokDslValidator_DUPLICATED_VARIABLE_IN_HIERARCHY)
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	def duplicatedVariableOrParameter(WReferenciable p) {
		if (p.isDuplicated) p.report(WollokDslValidator_DUPLICATED_NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	def methodInvocationToThisMustExist(WMemberFeatureCall call) {
		if (call.callOnThis && call.method != null && !call.method.declaringContext.isValidCall(call, classFinder)) {
			report(WollokDslValidator_METHOD_ON_THIS_DOESNT_EXIST, call, WMEMBER_FEATURE_CALL__FEATURE, METHOD_ON_THIS_DOESNT_EXIST)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def methodInvocationToWellKnownObjectMustExist(WMemberFeatureCall call) {
		try {
			if (call.callToWellKnownObject && !call.isValidCallToWKObject(classFinder)) {
				report(WollokDslValidator_METHOD_ON_WKO_DOESNT_EXIST, call, WMEMBER_FEATURE_CALL__FEATURE, METHOD_ON_WKO_DOESNT_EXIST)
			}
		} catch (Exception e) {
			e.printStackTrace
			throw e
		}
	}

	// WKO
	@Check
	@DefaultSeverity(ERROR)
	def objectMustExplicitlyCallASuperclassConstructor(WNamedObject it) {
		if (parent != null && parentParameters.empty && superClassRequiresNonEmptyConstructor) {
			report('''No default constructor in super type «parent.name». You must explicitly call a constructor: «parent.constructors.map["(" + parameters.map[name].join(",") + ")"].join(", ")»''', it, WNAMED_OBJECT__PARENT, REQUIRED_SUPERCLASS_CONSTRUCTOR)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def objectSuperClassConstructorMustExists(WNamedObject it) {
		if (parent != null && !parentParameters.empty && !parent.hasConstructorForArgs(parentParameters.size)) {
			report('''No superclass constructor or wrong number of arguments. You must explicitly call a constructor: «parent.constructors.map["(" + parameters.map[name].join(",") + ")"].join(", ")»''', it, WNAMED_OBJECT__PARENT)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def objectMustImplementAbstractMethods(WNamedObject it) {
		val abstractMethods = unimplementedAbstractMethods
		if (!abstractMethods.empty) {
			val methodDescriptions = abstractMethods.map[methodName].join(", ")
			report('''«WollokDslValidator_MUST_IMPLEMENT_ABSTRACT_METHODS»: «methodDescriptions»''', it, WNAMED__NAME)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def voidMessagesCannotBeUsedAsValues(WMemberFeatureCall call) {
		val method = call.resolveMethod(classFinder)
		if (method != null && !method.native && !method.abstract && !method.supposedToReturnValue && call.isUsedAsValue(classFinder)) {
			report(WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES, call, WMEMBER_FEATURE_CALL__FEATURE, VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES)
		}
	}

	@Check
	//TODO: a single method performs many checks ! cannot configure that
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unusedVariables(WVariableDeclaration it) {
		val assignments = variable.assignments
		if (assignments.empty) {
			if (writeable)
				warning(WollokDslValidator_WARN_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE, VARIABLE_NEVER_ASSIGNED)
			else if (!writeable)
				error(WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE, VARIABLE_NEVER_ASSIGNED)
		}
		if (variable.uses.empty)
			warning(WollokDslValidator_VARIABLE_NEVER_USED, it, WVARIABLE_DECLARATION__VARIABLE, WARNING_UNUSED_VARIABLE)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def nonBooleanValueInIfCondition(WIfExpression it) {
		if (!condition.isBooleanOrUnknownType) {
			report(WollokDslValidator_EXPECTING_BOOLEAN, it, WIF_EXPRESSION__CONDITION)
		}
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def nonBooleanValueInBooleanOperationComponent(WBinaryOperation it) {
		if (isBooleanExpression) {
			if(!leftOperand.isBooleanOrUnknownType)
				report(WollokDslValidator_EXPECTING_BOOLEAN, it, WBINARY_OPERATION__LEFT_OPERAND)
			if(!rightOperand.isBooleanOrUnknownType)
				report(WollokDslValidator_EXPECTING_BOOLEAN, it, WBINARY_OPERATION__RIGHT_OPERAND)	
		}
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def nonBooleanValueInNotUnaryExpression(WUnaryOperation it) {
		if (isNotOperation && !operand.isBooleanOrUnknownType)
			report(WollokDslValidator_EXPECTING_BOOLEAN, it, WUNARY_OPERATION__OPERAND)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unnecessaryIf(WIfExpression it) {
		if (^else == null && condition.isTrueLiteral)
			report(WollokDslValidator_UNNECESSARY_IF, it, WIF_EXPRESSION__CONDITION)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unreachableCodeInIf(WIfExpression it) {
		if (^else != null && condition.isTrueLiteral)
			report(WollokDslValidator_UNREACHABLE_CODE, it, WIF_EXPRESSION__ELSE)
		if (condition.isFalseLiteral)
			report(WollokDslValidator_UNREACHABLE_CODE, it, WIF_EXPRESSION__THEN)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unreachableCodeInBooleanBinaryOperation(WBinaryOperation it) {
		if (!isBooleanExpression || leftOperand == null || rightOperand == null)
			return;
		// and
		if (isAndExpression) {
			// left
			if (leftOperand.isTrueLiteral)
				report(WollokDslValidator_UNNECESSARY_CONDITION, it, WBINARY_OPERATION__LEFT_OPERAND)
			else if (leftOperand.isFalseLiteral)
				report(WollokDslValidator_UNREACHABLE_CODE, it, WBINARY_OPERATION__RIGHT_OPERAND)
			// right
			if (rightOperand.isTrueLiteral)
				report(WollokDslValidator_UNNECESSARY_CONDITION, it, WBINARY_OPERATION__RIGHT_OPERAND)
			else if (rightOperand.isFalseLiteral)
				report(WollokDslValidator_ALWAYS_EVALUATES_TO_FALSE, it)
		}
		else if (isOrExpression) {
			// left
			if (leftOperand.isTrueLiteral)
				report(WollokDslValidator_UNREACHABLE_CODE, it, WBINARY_OPERATION__RIGHT_OPERAND)
			else if (leftOperand.isFalseLiteral)
				report(WollokDslValidator_UNNECESSARY_CONDITION, it, WBINARY_OPERATION__LEFT_OPERAND)
			// right
			if (rightOperand.isTrueLiteral)
				report(WollokDslValidator_ALWAYS_EVALUATES_TO_TRUE, it)
			else if (rightOperand.isFalseLiteral)
				report(WollokDslValidator_UNNECESSARY_CONDITION, it, WBINARY_OPERATION__RIGHT_OPERAND)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	def superInvocationOnlyInValidMethod(WSuperInvocation sup) {
		if (!sup.method.overrides && !sup.isInMixin)
			report(WollokDslValidator_SUPER_ONLY_OVERRIDING_METHOD, sup)
		else if (sup.memberCallArguments.size != sup.method.parameters.size)
			report('''«WollokDslValidator_SUPER_INCORRECT_ARGS» «sup.method.parameters.size»: «sup.method.overridenMethod.parameters.map[name].join(", ")»''', sup)
	}

	// ***********************
	// ** Exceptions
	// ***********************

	@Check
	@DefaultSeverity(ERROR)
	def tryMustHaveEitherCatchOrAlways(WTry tri) {
		if ((tri.catchBlocks == null || tri.catchBlocks.empty) && tri.alwaysExpression == null)
			report(WollokDslValidator_ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS, tri, WTRY__EXPRESSION, ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	}

	@Check
	@DefaultSeverity(ERROR)
	def catchExceptionTypeMustExtendException(WCatch it) {
		if (exceptionType != null && !exceptionType.exception) report(WollokDslValidator_CATCH_ONLY_EXCEPTION, it, WCATCH__EXCEPTION_TYPE)
	}

	@Check
	@DefaultSeverity(ERROR)
	def unreachableCatch(WCatch it) {
		val hidingCatch = catchesBefore.findFirst[c|
			c.exceptionType == null || c.exceptionType.isSameOrSuperClassOf(it.exceptionType)
		]
		if (hidingCatch != null)
			report(WollokDslValidator_UNREACHABLE_CATCH, it, WCATCH__EXCEPTION_VAR_NAME)
	}

	def boolean isSameOrSuperClassOf(WClass one, WClass other) {
		one == other || one.isSuperTypeOf(other)
	}

	@Check
	@DefaultSeverity(ERROR)
	def postFixOperationOnlyValidforVariables(WPostfixOperation op) {
		if (!(op.operand.isWritableVarRef))
			report(op.feature + WollokDslValidator_POSTFIX_ONLY_FOR_VAR, op, WPOSTFIX_OPERATION__OPERAND)
	}

	@Check
	@DefaultSeverity(ERROR)
	def classNameCannotBeDuplicatedWithinPackage(WPackage p) {
		val classes = p.elements.filter(WClass)
		val repeated = classes.filter[c| classes.exists[it != c && name == c.name] ]
		repeated.forEach[
			report(WollokDslValidator_DUPLICATED_CLASS_IN_PACKAGE + p.name, it, WNAMED__NAME)
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	def duplicatedPackageName(WPackage p) {
		if (p.eContainer.eContents.filter(WPackage).exists[it != p && name == p.name])
			report(WollokDslValidator_DUPLICATED_PACKAGE + " " + p.name, p, WNAMED__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	def multiOpOnlyValidforVarReferences(WBinaryOperation op) {
		if (op.feature.isMultiOpAssignment && !op.leftOperand.isWritableVarRef)
			report(op.feature + WollokDslValidator_BINARYOP_ONLY_ON_VARS, op, WBINARY_OPERATION__LEFT_OPERAND)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def dontCompareAgainstTrueOrFalse(WBinaryOperation it) {
		if (OP_EQUALITY.contains(feature) && leftOperand instanceof WBooleanLiteral)
			report(WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE, it, WBINARY_OPERATION__LEFT_OPERAND)
		if (OP_EQUALITY.contains(feature) && rightOperand instanceof WBooleanLiteral)
			report(WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE, it, WBINARY_OPERATION__RIGHT_OPERAND)
	}

	@Check
	@DefaultSeverity(ERROR)
	def programInProgramFile(WProgram p){
		if(p.eResource.URI.nonXPectFileExtension != WollokConstants.PROGRAM_EXTENSION)
			report(WollokDslValidator_PROGRAM_IN_FILE + ''' «WollokConstants.PROGRAM_EXTENSION»''', p, WPROGRAM__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	def testInTestFile(WTest t) {
		if(t.eResource.URI.nonXPectFileExtension != WollokConstants.TEST_EXTENSION)
			report(WollokDslValidator_CLASSES_IN_FILE + ''' «WollokConstants.TEST_EXTENSION»''', t, WTEST__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def badUsageOfIfAsBooleanExpression(WIfExpression t) {
		if (t.then?.evaluatesToBoolean && t.^else?.evaluatesToBoolean) {
			val inlineResult = if (t.then.isReturnTrue) t.condition.sourceCode else ("!(" + t.condition.sourceCode + ")")
			val replacement = " return " + inlineResult
			report(WollokDslValidator_BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION + replacement, t, WIF_EXPRESSION__CONDITION, BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION)
		}
	}

	/**
	 * Returns the "wollok" file extension o a file, ignoring a possible final ".xt"
	 *
	 * This is a workaround for XPext testing. XPect test definition requires to add ".xt" to program file names,
	 * therefore fileExtension-dependent validations will fail if this is not taken into account.
	 */
	def nonXPectFileExtension(URI uri) {
		if (uri.fileExtension == 'xt') {
			val fileName = uri.segments.last()
			val fileNameParts = fileName.split("\\.")
			fileNameParts.get(fileNameParts.length - 2) // Penultimate part (last part is .xt)
		}
		else uri.fileExtension
	}

	@Check
	@DefaultSeverity(ERROR)
	def noExtraSentencesAfterReturnStatement(WBlockExpression it){
		checkNoAfter(first(WReturnExpression), WollokDslValidator_NO_EXPRESSION_AFTER_RETURN)
		checkNoAfter(first(WThrow), WollokDslValidator_NO_EXPRESSION_AFTER_THROW)
		expressions.filter(WTry).filter[t | t.cutsTheFlow ].forEach[t | checkNoAfter(t, WollokDslValidator_UNREACHABLE_CODE)]
	}

	def checkNoAfter(WBlockExpression it, WExpression riturn, String errorKey) {
		if (riturn != null) {
			it.getExpressionsAfter(riturn).forEach[e|
				report(errorKey, it, WBLOCK_EXPRESSION__EXPRESSIONS, it.expressions.indexOf(e))
			]
		}
	}


	@Check
	@DefaultSeverity(ERROR)
	def noReturnStatementInConstructor(WReturnExpression it){
		if (it.inConstructor)
			report(WollokDslValidator_NO_RETURN_EXPRESSION_IN_CONSTRUCTOR, it, WRETURN_EXPRESSION__EXPRESSION)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	def cannotReturnAssignment(WReturnExpression it){
		if (expression != null && expression instanceof WAssignment)
			report(WollokDslValidator_CANNOT_RETURN_ASSIGNMENT, it, WRETURN_EXPRESSION__EXPRESSION)
	}

	@Check
	@DefaultSeverity(ERROR)
	def noSuperInConstructorBody(WSuperInvocation it){
		if(it.isInConstructorBody)
			report(WollokDslValidator_SUPER_EXPRESSION_IN_CONSTRUCTOR, it, WSUPER_INVOCATION__MEMBER_CALL_ARGUMENTS)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def methodBodyProducesAValueButItIsNotBeingReturned(WMethodDeclaration it){
		if (!native && !abstract && !supposedToReturnValue && expression.isEvaluatesToAValue(classFinder))
			report(WollokDslValidator_RETURN_FORGOTTEN, it, WMETHOD_DECLARATION__EXPRESSION, RETURN_FORGOTTEN)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	def overridingMethodMustHaveABody(WMethodDeclaration it) {
		if (overrides && expression == null && !native)
			report(WollokDslValidator_OVERRIDING_METHOD_MUST_HAVE_A_BODY, it) 
	}
	

	@Check
	@DefaultSeverity(ERROR)
	def wrongImport(Import it) {
		val importedString = importedNamespaceWithoutWildcard
		val found = it.getScope(scopeProvider).getElements(importedString.toFQN)
		if (found.empty)
				report(WollokDslValidator_WRONG_IMPORT + " " + importedNamespace, it, IMPORT__IMPORTED_NAMESPACE)
	}

	@Check
	@DefaultSeverity(ERROR)
	def varArgMustBeTheLastParameter(WParameter it) {
		if (isVarArg && eContainer.parameters().last != it) {
			report(WollokDslValidator_VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE, it, WPARAMETER__VAR_ARG, VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE)
		}
	}

	// ******************************
	// ** native methods
	// ******************************

	@Check
	@DefaultSeverity(ERROR)
	def nativeMethodsChecks(WMethodDeclaration it) {
		if (native) {
			 if (expression != null) report("Native methods cannot have a body", it, WMETHOD_DECLARATION__EXPRESSION)
			 if (overrides) report("Native methods cannot override anything", it, WMETHOD_DECLARATION__OVERRIDES, NATIVE_METHOD_CANNOT_OVERRIDES)
			 if (declaringContext instanceof WObjectLiteral) report("Native methods can only be defined in classes", it, WMETHOD_DECLARATION__NATIVE)
			 // this is currently a limitation on native objects
//			 if(declaringContext instanceof WClass)
//				 if ((declaringContext as WClass).parent != null && (declaringContext as WClass).parent.native)
//				 	error(WollokDslValidator_NATIVE_IN_NATIVE_SUBCLASS, it, WMETHOD_DECLARATION__NATIVE)
		}
	}

}


