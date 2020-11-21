package org.uqbar.project.wollok.validation

import com.google.inject.Inject
import java.io.File
import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.osgi.util.NLS
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.MixedMethodContainer
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.scoping.WollokImportedNamespaceAwareLocalScopeProvider
import org.uqbar.project.wollok.scoping.WollokResourceCache
import org.uqbar.project.wollok.scoping.root.WollokRootLocator
import org.uqbar.project.wollok.validation.rules.DontCompareEqualityOfWKORule
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
import org.uqbar.project.wollok.wollokDsl.WIfExpression
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
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.Messages.*
import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.libraries.WollokLibExtensions.*
import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.model.FlowControlExtensions.*
import static extension org.uqbar.project.wollok.model.WBlockExtensions.*
import static extension org.uqbar.project.wollok.model.WEvaluationExtension.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * Custom validation rules.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 *
 * @author jfernandes
 * @author fdodino
 * @author ptesone
 * @author npasserini
 * @author jcontardo
 * @author fbulgarelli
 */
class WollokDslValidator extends AbstractConfigurableDslValidator {
	List<WollokValidatorExtension> wollokValidatorExtensions
	
	@Inject
	WollokClassFinder classFinder
	
	@Inject
	WollokGlobalScopeProvider scopeProvider

	@Inject
	IQualifiedNameConverter qualifiedNameConverter
	
	@Inject
	WollokImportedNamespaceAwareLocalScopeProvider localScopeProvider

	// ERROR KEYS
	public static val CANNOT_ASSIGN_TO_VAL = "CANNOT_ASSIGN_TO_VAL"
	public static val CANNOT_ASSIGN_TO_ITSELF = "CANNOT_ASSIGN_TO_ITSELF"
	public static val CANNOT_ASSIGN_TO_NON_MODIFIABLE = "CANNOT_ASSIGN_TO_NON_MODIFIABLE"

	public static val INVALID_NAME_FOR_FILE = "INVALID_NAME_FOR_FILE"

	public static val CLASS_NAME_MUST_START_UPPERCASE = "CLASS_NAME_MUST_START_UPPERCASE"
	public static val REFERENCIABLE_NAME_MUST_START_LOWERCASE = "REFERENCIABLE_NAME_MUST_START_LOWERCASE"
	public static val PARAMETER_NAME_MUST_START_LOWERCASE = "PARAMETER_NAME_MUST_START_LOWERCASE"
	public static val VARIABLE_NAME_MUST_START_LOWERCASE = "VARIABLE_NAME_MUST_START_LOWERCASE"
	public static val OBJECT_NAME_MUST_START_LOWERCASE = "OBJECT_NAME_MUST_START_LOWERCASE"
	public static val PROPERTY_NOT_WRITABLE_ON_THIS = "PROPERTY_NOT_WRITABLE_ON_THIS"
	public static val METHOD_ON_THIS_DOESNT_EXIST = "METHOD_ON_THIS_DOESNT_EXIST"
	public static val METHOD_ON_THIS_DOESNT_EXIST_SEVERAL_ARGS = "METHOD_ON_THIS_DOESNT_EXIST_SEVERAL_ARGS"
	public static val PROPERTY_NOT_WRITABLE_ON_WKO = "PROPERTY_NOT_WRITABLE_ON_WKO"
	public static val METHOD_ON_WKO_DOESNT_EXIST = "METHOD_ON_WKO_DOESNT_EXIST"
	public static val METHOD_ON_WKO_DOESNT_EXIST_SEVERAL_ARGS = "METHOD_ON_WKO_DOESNT_EXIST_SEVERAL_ARGS"
	public static val VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES = "VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES"
	public static val METHOD_MUST_HAVE_OVERRIDE_KEYWORD = "METHOD_MUST_HAVE_OVERRIDE_KEYWORD"
	public static val OVERRIDING_METHOD_MUST_RETURN_VALUE = "OVERRIDING_METHOD_MUST_RETURN_VALUE"
	public static val OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE = "OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE"
	public static val GETTER_METHOD_SHOULD_RETURN_VALUE = "GETTER_METHOD_SHOULD_RETURN_VALUE"
	public static val ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS = "ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS"
	public static val REQUIRED_SUPERCLASS_CONSTRUCTOR = "REQUIRED_SUPERCLASS_CONSTRUCTOR"
	public static val DUPLICATED_CONSTRUCTOR = "DUPLICATED_CONSTRUCTOR"
	public static val UNNECESARY_OVERRIDE = "UNNECESARY_OVERRIDE"
	public static val ATTRIBUTE_NOT_FOUND_IN_NAMED_PARAMETER_CONSTRUCTOR = "ATTRIBUTE_NOT_FOUND_IN_NAMED_PARAMETER_CONSTRUCTOR"
	public static val MISSING_ASSIGNMENTS_IN_NAMED_PARAMETER_CONSTRUCTOR = "MISSING_ASSIGNMENTS_IN_NAMED_PARAMETER_CONSTRUCTOR"
	public static val MUST_CALL_SUPER = "MUST_CALL_SUPER"
	public static val TYPE_SYSTEM_ERROR = "TYPE_SYSTEM_ERROR"
	public static val NATIVE_METHOD_CANNOT_OVERRIDES = "NATIVE_METHOD_CANNOT_OVERRIDES"
	public static val BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION = "BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION"
	public static val CONSTRUCTOR_IN_SUPER_DOESNT_EXIST = "CONSTRUCTOR_IN_SUPER_DOESNT_EXIST"
	public static val CANT_OVERRIDE_FROM_BASE_CLASS = "CANT_OVERRIDE_FROM_BASE_CLASS"
	public static val METHOD_DOESNT_OVERRIDE_ANYTHING = "METHOD_DOESNT_OVERRIDE_ANYTHING"
	public static val DUPLICATED_METHOD = "DUPLICATED_METHOD"
	public static val CYCLIC_HIERARCHY = "CYCLIC_HIERARCHY"
	public static val INITIALIZATION_VALUE_NEVER_USED = "INITIALIZATION_VALUE_NEVER_USED"
	public static val VARIABLE_NEVER_ASSIGNED = "VARIABLE_NEVER_ASSIGNED"
	public static val RETURN_FORGOTTEN = "RETURN_FORGOTTEN"
	public static val DONT_USE_WKONAME_WITHIN_IT = "DONT_USE_WKONAME_WITHIN_IT"
	public static val CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT = "CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT"
	public static val VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE = "VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE"
	public static val PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS = "PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS"
	public static val WRONG_NUMBER_ARGUMENTS_CONSTRUCTOR_CALL = "WRONG_NUMBER_ARGUMENTS_CONSTRUCTOR_CALL" 
	public static val ASSIGNMENT_INSIDE_IF = "ASSIGNMENT_INSIDE_IF"

	// WARNING KEYS
	public static val WARNING_UNUSED_VARIABLE = "WARNING_UNUSED_VARIABLE"
	public static val WARNING_UNUSED_PARAMETER = "WARNING_UNUSED_PARAMETER"
	public static val WARNING_VARIABLE_SHOULD_BE_CONST = "WARNING_VARIABLE_SHOULD_BE_CONST"
	public static val GLOBAL_VARIABLE_NOT_ALLOWED = "GLOBAL_VARIABLE_NOT_ALLOWED"

	def validatorExtensions() {
		if (wollokValidatorExtensions !== null)
			return wollokValidatorExtensions

		val registry = Platform.getExtensionRegistry
		if(registry === null)
			return #{}

		val configs = registry.getConfigurationElementsFor("org.uqbar.project.wollok.wollokValidationExtension")
		wollokValidatorExtensions = configs.map[it.createExecutableExtension("class") as WollokValidatorExtension]
	}

	@NotConfigurable
	@Check
	def checkValidationExtensions(WFile wfile) {
		validatorExtensions.forEach[ ext |
			if(ext.shouldRun)
				ext.check(wfile, this)
		]
	}
	
	protected def shouldRun(WollokValidatorExtension ext){
		val method = ext.class.getMethod("check", WFile, WollokDslValidator)
		val annotation = method.getAnnotation(Check)
		
		if(annotation === null) 
			throw new RuntimeException("Extension " + ext.class.name + " should use the @Check annotation")
		
		this.checkMode.shouldCheck(annotation.value)
	}
	

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def classNameMustStartWithUpperCase(WClass c) {
		if(Character.isLowerCase(c.name.charAt(0))) report(WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE, c,
			WNAMED__NAME, CLASS_NAME_MUST_START_UPPERCASE)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def namedObjectMustStartWithLowerCase(WNamedObject c) {
		if(Character.isUpperCase(c.name.charAt(0))) report(WollokDslValidator_OBJECT_NAME_MUST_START_LOWERCASE, c,
			WNAMED__NAME, OBJECT_NAME_MUST_START_LOWERCASE)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def parameterNameMustStartWithLowerCase(WParameter c) {
		if(Character.isUpperCase(c.name.charAt(0))) report(WollokDslValidator_PARAMETER_NAME_MUST_START_LOWERCASE, c,
			WNAMED__NAME, PARAMETER_NAME_MUST_START_LOWERCASE)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def variableNameMustStartWithLowerCase(WVariable c) {
		if(Character.isUpperCase(c.name.charAt(0)) && !c.isGlobal) report(WollokDslValidator_VARIABLE_NAME_MUST_START_LOWERCASE, c,
			WNAMED__NAME, VARIABLE_NAME_MUST_START_LOWERCASE)
	}

	// **************************************
	// ** instantiation and constructors
	// **************************************
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def cannotInstantiateAbstractClasses(WConstructorCall it) {
		if(classRef === null) return
		val abstractMethods = unimplementedAbstractMethods
		val inheritingAbstractMethods = abstractMethods.exists[ m | m.declaringContext !== classRef ]
		if (!abstractMethods.empty) {
			if (inheritingAbstractMethods) {
				val methodDescriptions = abstractMethods.map [
					NLS.bind(WollokDslValidator_ABSTRACT_METHOD_DEFINITION, messageName, declaringContext.name)
				].join(", ")
				report('''«NLS.bind(WollokDslValidator_CLASS_MUST_IMPLEMENT_ABSTRACT_METHODS, it.classRef.name)»: «methodDescriptions»''',
					it, WCONSTRUCTOR_CALL__CLASS_REF)
			} else {
				val methodDescriptions = abstractMethods.map [ messageName ].join(", ")
				report('''«NLS.bind(WollokDslValidator_CLASS_WITHOUT_INHERITANCE_MUST_IMPLEMENT_ALL_METHODS, it.classRef.name)»: «methodDescriptions»''',
					it, WCONSTRUCTOR_CALL__CLASS_REF)
			}
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def checkUnexistentNamedParametersInConstructor(WConstructorCall it) {
		if (!hasNamedParameters) return;
		classRef.validateNamedParameters(argumentList, mixins)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def checkUnexistentNamedParametersInheritingConstructor(WNamedObject it) {
		if (parent === null || parentParameters === null || !parentParameters.hasNamedParameters) return;
		parent.validateNamedParameters(parentParameters)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def checkUnexistentNamedParametersInheritingConstructor(WObjectLiteral it) {
		if (parent === null || parentParameters === null || !parentParameters.hasNamedParameters) return;
		parent.validateNamedParameters(parentParameters)
	}

	def void validateNamedParameters(WClass clazz, WArgumentList parameterList) {
		validateNamedParameters(clazz, parameterList, #[])
	}

	def void validateNamedParameters(WClass clazz, WArgumentList parameterList, List<WMixin> additionalMixins) {
		if (clazz.name === null) return;  // avoid validation for non-existent classes
		val validAttributes = clazz.allVariableNames + (clazz.mixins + additionalMixins).flatMap [ allVariableNames ]
		val invalidInitializers = parameterList.initializers.filter [ !validAttributes.contains(initializer.name) ]
		invalidInitializers.forEach [ 
			reportEObject(NLS.bind(WollokDslValidator_UNDEFINED_ATTRIBUTE_IN_CONSTRUCTOR, initializer.name, clazz.name), initializer.eContainer, WollokDslValidator.ATTRIBUTE_NOT_FOUND_IN_NAMED_PARAMETER_CONSTRUCTOR)
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.INITIALIZATION)
	def checkUninitializedAttributesInConstructorNamedParameters(WConstructorCall it) {
		if (hasNamedParameters || (!classRef.hasConstructors() && !classRef.hasInitializeMethod())) {
			val unusedVarDeclarations = uninitializedNamedParameters
			if (!unusedVarDeclarations.isEmpty) {
				val variableNames = unusedVarDeclarations.map [ variable.name ].join(", ")
				reportEObject(NLS.bind(WollokDslValidator_MISSING_ASSIGNMENTS_IN_CONSTRUCTOR_CALL, variableNames), it, MISSING_ASSIGNMENTS_IN_NAMED_PARAMETER_CONSTRUCTOR)
			}
		}
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def noSuperMethodRequiredByMixinAtInstantiationTime(WConstructorCall it) {
		if (!mixins.empty)
			checkUnboundedSuperCallingMethodsOnMixins(new MixedMethodContainer(classRef, mixins), it,
				WCONSTRUCTOR_CALL__CLASS_REF)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def invalidConstructorCall(WConstructorCall c) {
		if (c.classRef?.name !== null && !c.hasNamedParameters && !c.isValidConstructorCall()) {
			reportEObject(WollokDslValidator_WCONSTRUCTOR_CALL__ARGUMENTS + " " + c.prettyPrint, c, WRONG_NUMBER_ARGUMENTS_CONSTRUCTOR_CALL)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@NotConfigurable	
	def constructorMustExplicitlyCallSuper(WConstructor it) {
		if (delegatingConstructorCall === null && wollokClass.superClassRequiresNonEmptyConstructor) {
			report(WollokDslValidator_MUST_CALL_SUPERCLASS_CONSTRUCTOR, it, WCONSTRUCTOR__PARAMETERS, MUST_CALL_SUPER)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cyclicConstructorDefinition(WConstructor it) {
		if (hasCyclicDefinition) {
			report(WollokDslValidator_CONSTRUCTOR_HAS_CYCLIC_DELEGATION, it, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL)			
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotUseInstanceVariablesInConstructorDelegation(WDelegatingConstructorCall it) {
		val namedParameters = if (argumentList === null) newArrayList else argumentList.variables
		eAllContents.filter(WVariableReference).forEach [ ref |
			if (ref.ref instanceof WVariable && !namedParameters.contains(ref)) {
				report(WollokDslValidator_CANNOT_ACCESS_INSTANCE_VARIABLES_WITHIN_CONSTRUCTOR_DELEGATION, ref, WVARIABLE_REFERENCE__REF)
			}
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotUseNamedParametersInConstructorDelegation(WDelegatingConstructorCall it) {
		if (argumentList.notNullAnd[!variables.isEmpty])
			report(WollokDslValidator_NAMED_PARAMETERS_NOT_ALLOWED, it, WDELEGATING_CONSTRUCTOR_CALL__ARGUMENT_LIST)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotMixNamedAndPositionalParametersInObjectLiteral(WObjectLiteral it) {
		if (parentParameters === null) return;
		if (!parentParameters.values.isEmpty && !parentParameters.variables.isEmpty)
			report(WollokDslValidator_DONT_MIX_NAMED_AND_POSITIONAL_PARAMETERS, it, WOBJECT_LITERAL__PARENT_PARAMETERS)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotMixNamedAndPositionalParametersInWKO(WNamedObject it) {
		if (parentParameters === null) return;
		if (!parentParameters.values.isEmpty && !parentParameters.variables.isEmpty)
			report(WollokDslValidator_DONT_MIX_NAMED_AND_POSITIONAL_PARAMETERS, it, WNAMED_OBJECT__PARENT_PARAMETERS)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def delegatedConstructorDoesntExist(WDelegatingConstructorCall it) {
		val validConstructors = it.constructorsFor(it.wollokClass).map[constr|constr.constructorName(it)].join(",")
		val resolved = it.wollokClass.resolveConstructorReference(it)
		if (resolved === null) {
			if (!validConstructors.isEmpty) {
				report(NLS.bind(WollokDslValidator_INVALID_CONSTRUCTOR_CALL, validConstructors, it.constructorPrefix),
					it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL, CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
			} else {
				report(NLS.bind(WollokDslValidator_INVALID_CONSTRUCTOR_CALL_SUPERCLASS_WITHOUT_CONSTRUCTORS,
					it.constructorPrefix), it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL,
					CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
			}
		}	
	}

	def static dispatch constructorPrefix(WSuperDelegatingConstructorCall c) { "super " }
	def static dispatch constructorPrefix(WDelegatingConstructorCall c) { "" }
		 
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotHaveTwoConstructorsWithSameArity(WClass it) {
		val repeated = constructors.filter[c|constructors.exists[c2|c2 != c && c.matches(c2.parameters.size)]]
		repeated.forEach [ r |
			report(WollokDslValidator_DUPLICATED_CONSTRUCTOR, r, WCONSTRUCTOR__PARAMETERS,
				DUPLICATED_CONSTRUCTOR)
		]
	}

	// **************************************
	// ** method container validations
	// **************************************

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def propertyOnlyAllowedInMethodContainer(WVariableDeclaration it) {
		if (property && !isPropertyAllowed) {
			report(WollokDslValidator_PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS, it,
			WVARIABLE_DECLARATION__PROPERTY, PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS)
		} 
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def noSuperMethodRequiredByMixin(WMethodContainer it) {
		checkUnboundedSuperCallingMethodsOnMixins(it, WNAMED__NAME)
	}

	def checkUnboundedSuperCallingMethodsOnMixins(WMethodContainer it, EObject target, EStructuralFeature attribute) {
		if(it instanceof WMixin) return // no checks for mixin. Since a mixin by itself has no hierarchy
		val methods = it.unboundedSuperCallingMethodsOnMixins
		if (!methods.empty) {
			val methodDescriptions = methods.map[methodName].join(", ")
			report('''«WollokDslValidator_INCONSISTENT_HIERARCHY_MIXIN_CALLING_SUPER_NOT_FULLFILLED»: «methodDescriptions»''',
				target, attribute)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def definingAMethodThatOnlyCallsToSuper(WMethodDeclaration it) {
		if (redefinesSendingOnlySuper) {
			report(WollokDslValidator_OVERRIDING_A_METHOD_SHOULD_DO_SOMETHING_DIFFERENT, it,
			WNAMED__NAME, UNNECESARY_OVERRIDE)
		}
	}

	// SELF
	@Check
	@DefaultSeverity(WARN)
	@NotConfigurable	
	def cannotUseSelfInConstructorDelegation(WSelf it) {
		if (EcoreUtil2.getContainerOfType(it, WDelegatingConstructorCall) !== null)
			report(WollokDslValidator_CANNOT_ACCESS_INSTANCE_METHOD_WITHIN_CONSTRUCTOR_DELEGATION, it)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotUseSelfInAProgram(WSelf it) {
		if (!it.isInASelfContext)
			report(WollokDslValidator_CANNOT_USE_SELF_IN_A_PROGRAM, it)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.GLOBAL_REFERENCE)
	def dontUseWKONameOnWKOUseSelfInstead(WVariableReference it) {
		if (ref == declaringContext)
			report(WollokDslValidator_DONT_USE_WKONAME_WITHIN_IT, it, null, DONT_USE_WKONAME_WITHIN_IT)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotUseSuperInConstructorDelegation(WSuperInvocation it) {
		if (EcoreUtil2.getContainerOfType(it, WDelegatingConstructorCall) !== null)
			report(WollokDslValidator_CANNOT_ACCESS_SUPER_METHODS_WITHIN_CONSTRUCTOR_DELEGATION, it)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotReassignValues(WAssignment a) {
		val variable = a.feature.ref
		if(!variable.isModifiableFrom(a)
			&& !a.isWithinConstructor) {
			report(WollokDslValidator_CANNOT_MODIFY_VAL, a, WASSIGNMENT__FEATURE,
			cannotModifyErrorId(a.feature))
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotReassignValuesInConstructors(WAssignment a) {
		val declaringConstructor = a.declaringConstructor
		if (declaringConstructor === null) return;
		val variable = a.feature.ref
		if (declaringConstructor.hasSeveralAssignmentsFor(variable)) {
			if (!variable.writableVarRef) {
				error(WollokDslValidator_CANNOT_MODIFY_VAL, a, WASSIGNMENT__FEATURE,
					cannotModifyErrorId(a.feature))
			}
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotReassignValuesInFixture(WAssignment a) {
		val declaringFixture = a.declaringFixture
		if (declaringFixture === null) return;
		val variable = a.feature.ref
		if (declaringFixture.hasSeveralAssignmentsFor(variable)) {
			if (!variable.writableVarRef) {
				report(WollokDslValidator_CANNOT_MODIFY_VAL, a, WASSIGNMENT__FEATURE,
					cannotModifyErrorId(a.feature))
			}
		}
	}

	def dispatch boolean hasSeveralAssignmentsFor(WFixture it, WReferenciable variable) {
		elements.filter [ hasAssignmentsFor(variable) ].size > 1
	}

	def dispatch boolean hasSeveralAssignmentsFor(WConstructor it, WReferenciable variable) {
		if (expression === null) return false
		expression.hasSeveralAssignmentsFor(variable)
	}

	def dispatch boolean hasSeveralAssignmentsFor(WBlockExpression it, WReferenciable variable) {
		expressions.filter [ hasAssignmentsFor(variable) ].size > 1
	}
	
	def dispatch boolean hasAssignmentsFor(EObject e, WReferenciable variable) {
		false
	}
	
	def dispatch boolean hasAssignmentsFor(WAssignment assignment, WReferenciable variable) {
		assignment.feature.ref === variable
	}

	def dispatch String cannotModifyErrorId(WReferenciable it) { CANNOT_ASSIGN_TO_NON_MODIFIABLE }

	def dispatch String cannotModifyErrorId(WVariable it) { CANNOT_ASSIGN_TO_VAL }

	def dispatch String cannotModifyErrorId(WVariableDeclaration it) { CANNOT_ASSIGN_TO_NON_MODIFIABLE }

	def dispatch String cannotModifyErrorId(WVariableReference it) { cannotModifyErrorId(ref) }

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotAssignToItself(WAssignment a) {
		if (!(a.value instanceof WVariableReference))
			return

		val rightSide = a.value as WVariableReference
		if (a.feature.ref == rightSide.ref)
			report(WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF, a, WASSIGNMENT__FEATURE, CANNOT_ASSIGN_TO_ITSELF)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cannotAssignToItselfInVariableDeclaration(WVariableDeclaration a) {
		if (!(a.right instanceof WVariableReference))
			return

		val rightSide = a.right as WVariableReference
		if (a.variable == rightSide.ref)
			report(WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF, a, WVARIABLE_DECLARATION__VARIABLE,
				CANNOT_ASSIGN_TO_ITSELF)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable	
	def cyclicHierarchy(WMethodContainer it) {
		if (declaringContext.hasCyclicHierarchy) {
			report(WollokDslValidator_CYCLIC_HIERARCHY, it, WCLASS__PARENT)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def methodDoesntOverride(WMethodDeclaration m) {
		val overrides = m.actuallyOverrides
		val container = m.eContainer as WMethodContainer
		if (m.overrides && !overrides) {
			if (container.inheritsFromLibClass) {
				m.report(WollokDslValidator_METHOD_OVERRIDING_BASE_CLASS, CANT_OVERRIDE_FROM_BASE_CLASS)
			} else {
				m.report(WollokDslValidator_METHOD_NOT_OVERRIDING, METHOD_DOESNT_OVERRIDE_ANYTHING)
			}
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.EXPLICIT_INTENTION)
	def methodActuallyOverrides(WMethodDeclaration m) {
		val overrides = m.actuallyOverrides
		if (overrides && !m.overrides)
			m.report(WollokDslValidator_METHOD_MUST_HAVE_OVERRIDE_KEYWORD, METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def overridingMethodMustReturnAValueIfOriginalMethodReturnsAValue(WMethodDeclaration m) {
		if (m.overrides && !m.native) {
			val overridden = m.overriddenMethod
			if (overridden !== null && !overridden.abstract) {
				if (overridden.supposedToReturnValue && !m.returnsOnAllPossibleFlows(overridden.supposedToReturnValue))
					m.report(WollokDslValidator_OVERRIDING_METHOD_MUST_RETURN_VALUE,
						OVERRIDING_METHOD_MUST_RETURN_VALUE)
				if (!overridden.supposedToReturnValue && m.returnsOnAllPossibleFlows(overridden.supposedToReturnValue))
					m.report(WollokDslValidator_OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE,
						OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE)
			}
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def methodDoesNotReturnAValueOnEveryPossibleFlow(WMethodDeclaration it) {
		if (supposedToReturnValue && !returnsOnAllPossibleFlows(supposedToReturnValue))
			report(WollokDslValidator_METHOD_DOES_NOT_RETURN_A_VALUE_ON_EVERY_POSSIBLE_FLOW)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def getterMethodShouldReturnAValue(WMethodDeclaration m) {
		if (m.isGetter && !m.abstract && !m.supposedToReturnValue)
			m.report(WollokDslValidator_GETTER_METHOD_SHOULD_RETURN_VALUE, GETTER_METHOD_SHOULD_RETURN_VALUE)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def duplicatedMethod(WMethodDeclaration it) {
		if (declaringContext.methods.exists[m|m != it && hasSameSignatureThan(m)])
			report(WollokDslValidator_DUPLICATED_METHOD, DUPLICATED_METHOD)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def duplicatedVariableFromSuperclass(WMethodContainer m) {
		val inheritedVariables = (m.mixins + m.parents).map[variables].flatten
		m.variables.filter[v|inheritedVariables.exists[name == v.name]].forEach [
			report(WollokDslValidator_DUPLICATED_VARIABLE_IN_HIERARCHY)
		]
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def duplicatedMethodContainerFromImports(WNamed it) {
		duplicatedReferenceFromImports(it)
	}
	
	def duplicatedReferenceFromImports(EObject it) {
		val imports = it.allImports
		val duplicatedReference = it.duplicatedReference(imports, scopeProvider)
		if (duplicatedReference !== null) {
			report(
				NLS.bind(WollokDslValidator_DUPLICATED_REFERENCE_FROM_IMPORTS,
					duplicatedReference.EObjectURI.lastSegment), it, WNAMED__NAME)
		}
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def duplicatedVariableOrParameter(WReferenciable p) {
		if(p.isDuplicated) p.report(WollokDslValidator_DUPLICATED_NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def methodInvocationToSelfMustExist(WMemberFeatureCall call) {
		val declaringContext = call.declaringContext
		if (call.callOnThis && declaringContext !== null && !declaringContext.isValidCall(call)) {
			var message = WollokDslValidator_METHOD_ON_THIS_DOESNT_EXIST
			val args = call.memberCallArguments.size
			var issueId = METHOD_ON_THIS_DOESNT_EXIST
			if (args == 1) {
				issueId = PROPERTY_NOT_WRITABLE_ON_THIS
				if (declaringContext.constantProperty(call.feature, 1)) {
					message = NLS.bind(WollokDslValidator_PROPERTY_NOT_WRITABLE, call.feature)
				}
			}
			if (args > 1) {
				issueId = METHOD_ON_THIS_DOESNT_EXIST_SEVERAL_ARGS
			}
			report(message, call, WMEMBER_FEATURE_CALL__FEATURE, issueId)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def methodInvocationToWellKnownObjectMustExist(WMemberFeatureCall call) {
		try {
			if (call.callToWellKnownObject && !call.isValidCallToWKObject(classFinder)) {
				val wko = call.resolveWKO(classFinder)
				val similarMethods = wko.findMethodsByName(call.feature)
				if (similarMethods.empty) {
					val caseSensitiveMethod = wko.findMethodIgnoreCase(call.feature, call.memberCallArguments.size)
					if (caseSensitiveMethod !== null) {
						report(NLS.bind(WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE, #[wko.name, call.fullMessage, #[caseSensitiveMethod].convertToString]), call, WMEMBER_FEATURE_CALL__FEATURE)
					} else {
						var issueId = METHOD_ON_WKO_DOESNT_EXIST
						val args = call.memberCallArguments.size
						var message = NLS.bind(WollokDslValidator_METHOD_DOESNT_EXIST, wko.name, call.fullMessage)
						if (args == 1) {
							issueId = PROPERTY_NOT_WRITABLE_ON_WKO
							if (wko.constantProperty(call.feature, 1)) {
								message = NLS.bind(WollokDslValidator_PROPERTY_NOT_WRITABLE, call.feature)
							}	
						}
						if (args > 1) {
							issueId = METHOD_ON_WKO_DOESNT_EXIST_SEVERAL_ARGS	
						}
						report(message, call, WMEMBER_FEATURE_CALL__FEATURE, issueId)
					}
				} else {
					val similarDefinitions = similarMethods.convertToString
					report(NLS.bind(WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND, #[wko.name, call.fullMessage, similarDefinitions]), call, WMEMBER_FEATURE_CALL__FEATURE)
				}
			}
		} catch (Exception e) {
			e.printStackTrace
			throw e
		}
	}

	// WKO
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def objectMustExplicitlyCallASuperclassConstructor(WNamedObject it) {
		if (parent !== null && !hasParentParameterValues && !hasParentParameterInitializers && superClassRequiresNonEmptyConstructor) {
			report(NLS.bind(WollokDslValidator_OBJECT_MUST_CALL_SUPERCLASS_CONSTRUCTOR, parent.name, parent.constructorParameters),
				it, WNAMED_OBJECT__PARENT, REQUIRED_SUPERCLASS_CONSTRUCTOR)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def objectSuperClassConstructorMustExist(WNamedObject it) {
		if (parent !== null && parentParameters !== null && !hasParentParameterInitializers && !parent.hasConstructorForArgs(parentParametersValues)) {
			report(NLS.bind(WollokDslValidator_NO_SUPERCLASS_CONSTRUCTOR, parent.constructorParameters),
				it, WNAMED_OBJECT__PARENT)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def objectMustImplementAbstractMethods(WNamedObject it) {
		val abstractMethods = unimplementedAbstractMethods
		val inheritingAbstractMethods = abstractMethods.exists[ m | m.declaringContext !== it ]
		if (!abstractMethods.empty) {
			if (inheritingAbstractMethods) {
				val methodDescriptions = abstractMethods.map[methodName].join(", ")
				report('''«WollokDslValidator_WKO_MUST_IMPLEMENT_ABSTRACT_METHODS»: «methodDescriptions»''',
					it, WNAMED__NAME)
			} else {
				abstractMethods.forEach [ abstractMethod |
					report('''«WollokDslValidator_WKO_WITHOUT_INHERITANCE_MUST_IMPLEMENT_ALL_METHODS»''',
						abstractMethod, WNAMED__NAME)
				]
			}
		}
	}

	// Object Literals
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def unnamedObjectMustExplicitlyCallASuperclassConstructor(WObjectLiteral it) {
		if (parent !== null && !hasParentParameterValues && !hasParentParameterInitializers && superClassRequiresNonEmptyConstructor) {
			report(NLS.bind(WollokDslValidator_OBJECT_MUST_CALL_SUPERCLASS_CONSTRUCTOR, parent.name, parent.constructorParameters),
				it, WOBJECT_LITERAL__PARENT, REQUIRED_SUPERCLASS_CONSTRUCTOR)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def unnamedObjectSuperClassConstructorMustExist(WObjectLiteral it) {
		if (parent !== null && parentParameters !== null && !hasParentParameterInitializers && !parent.hasConstructorForArgs(parentParametersValues)) {
			report(NLS.bind(WollokDslValidator_NO_SUPERCLASS_CONSTRUCTOR, parent.constructorParameters),
				it, WOBJECT_LITERAL__PARENT)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def unnamedObjectMustImplementAbstractMethods(WObjectLiteral it) {
		val abstractMethods = unimplementedAbstractMethods
		val inheritingAbstractMethods = abstractMethods.exists[ m | m.declaringContext !== it ]
		if (!abstractMethods.empty) {
			if (inheritingAbstractMethods) {
				val methodDescriptions = abstractMethods.map[methodName].join(", ")
				report('''«WollokDslValidator_WKO_MUST_IMPLEMENT_ABSTRACT_METHODS»: «methodDescriptions»''',
					it)
			} else {
				abstractMethods.forEach [ abstractMethod |
					report('''«WollokDslValidator_WKO_WITHOUT_INHERITANCE_MUST_IMPLEMENT_ALL_METHODS»''',
						abstractMethod, WNAMED__NAME)
				]
			}
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def voidMessagesCannotBeUsedAsValues(WMemberFeatureCall call) {
		val method = call.resolveMethod(classFinder)
		if (method !== null && !method.native && !method.abstract && !method.supposedToReturnValue &&
			call.isUsedAsValue(classFinder)) {
			report(NLS.bind(WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES, call.fullMessage), call, WMEMBER_FEATURE_CALL__FEATURE,
				VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def defaultValueForVariableNeverUsed(WVariableDeclaration it) {
		if (!isLocal && declaringContext !== null && right !== null && !declaringContext.getConstructors.empty && !declaringContext.getConstructors.exists [ constructor | variable.assignments(constructor).isEmpty ]) {
			report(WollokDslValidator_INITIALIZATION_VALUE_FOR_VARIABLE_NEVER_USED, it, WVARIABLE_DECLARATION__RIGHT, INITIALIZATION_VALUE_NEVER_USED)
		}
	}
	
	// TODO: a single method performs many checks ! cannot configure that
	@Check
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unusedVariablesAndInitializedConstants(WVariableDeclaration it) {
		val assignments = variable.assignments
		val declaringContext = it.declaringContext
		val shouldCheckInitialization = declaringContext === null || declaringContext.shouldCheckInitialization
		// Variable has no assignments
		if (assignments.empty && shouldCheckInitialization) {
			if (writeable)
				warning(WollokDslValidator_WARN_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE,
					VARIABLE_NEVER_ASSIGNED)
			else if (!writeable)
				error(WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE,
					VARIABLE_NEVER_ASSIGNED)
		}
		// Variable has no assignment in its definition and there are several assignments
		if (!assignments.empty && right === null && declaringContext !== null && !isLocalToMethod) {
			declaringContext
				.getConstructors
				.filter [ constructor | variable.assignments(constructor).isEmpty ]
				.forEach [ constructor |
					if (!writeable)
						error(NLS.bind(WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED_IN_CONSTRUCTOR, variable.name), constructor, WCONSTRUCTOR__EXPRESSION)
					else
						warning(NLS.bind(WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED_IN_CONSTRUCTOR, variable.name), constructor, WCONSTRUCTOR__EXPRESSION)
				]
		}
		// Variable is never used
		if (!variable.isUsed && !variable.isGlobal && !property)
			warning(WollokDslValidator_VARIABLE_NEVER_USED, it, WVARIABLE_DECLARATION__VARIABLE,
				WARNING_UNUSED_VARIABLE)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def globalVariablesNotAllowed(WVariableDeclaration it) {
		if (writeable && isGlobal) {
			report(WollokDslValidator_GLOBAL_VARIABLE_NOT_ALLOWED, it, WVARIABLE_DECLARATION__VARIABLE, GLOBAL_VARIABLE_NOT_ALLOWED)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def unusedParameters(WConstructor it) {
		checkUnusedParameters(it.parameters)
	}
	
	@Check
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def variableSingleAssignmentShouldBeConst(WVariableDeclaration it) {
		val assignments = variable.assignments(container)
		if (writeable && !isProperty && assignments.size === 1 && right !== null && !isGlobal) {
			warning(WollokDslValidator_VARIABLE_SHOULD_BE_CONST, it, WVARIABLE_DECLARATION__VARIABLE,
				WARNING_VARIABLE_SHOULD_BE_CONST)
		}
	}
	
	def void checkUnusedParameters(List<WParameter> parameters) {
		parameters.forEach [ parameter |
			if (!parameter.isUsed) {
				warning(WollokDslValidator_PARAMETER_NEVER_USED, parameter, WPARAMETER__VAR_ARG,
					WARNING_UNUSED_PARAMETER)
			}
		]
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def comparingEqualityOfWellKnownObject(WBinaryOperation it) {
		DontCompareEqualityOfWKORule.validate(this, it)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def nonBooleanValueInIfCondition(WIfExpression it) {
		if (!condition.isBooleanOrUnknownType) {
			checkBooleanExpression(condition, it, WIF_EXPRESSION__CONDITION)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def nonBooleanValueInBooleanOperationComponent(WBinaryOperation it) {
		if (isBooleanExpression) {
			if (!leftOperand.isBooleanOrUnknownType)
				checkBooleanExpression(leftOperand, it, WBINARY_OPERATION__LEFT_OPERAND)
			if (rightOperand !== null && !rightOperand.isBooleanOrUnknownType)
				checkBooleanExpression(rightOperand, it, WBINARY_OPERATION__RIGHT_OPERAND)
		}
	}

	private def checkBooleanExpression(WExpression expression, EObject container, EStructuralFeature feature) {
		if (expression instanceof WAssignment) {
			report(WollokDslValidator_EXPECTING_BOOLEAN_COMPARING_VS_ASSIGNING, container, feature, ASSIGNMENT_INSIDE_IF)
		} else {
			report(WollokDslValidator_EXPECTING_BOOLEAN, container, feature)
		}
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def nonBooleanValueInNotExpression(WUnaryOperation it) {
		if (isNotOperation && operand !== null && !operand.isBooleanOrUnknownType)
			report(WollokDslValidator_EXPECTING_BOOLEAN, it, WUNARY_OPERATION__OPERAND)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def unnecessaryIf(WIfExpression it) {
		if (^else === null && condition.isTrueLiteral)
			report(WollokDslValidator_UNNECESSARY_IF, it, WIF_EXPRESSION__CONDITION)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def unreachableCodeInIf(WIfExpression it) {
		if (^else !== null && condition.isTrueLiteral)
			report(WollokDslValidator_UNREACHABLE_CODE, it, WIF_EXPRESSION__ELSE)
		if (condition.isFalseLiteral)
			report(WollokDslValidator_UNREACHABLE_CODE, it, WIF_EXPRESSION__THEN)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def unreachableCodeInBooleanBinaryOperation(WBinaryOperation it) {
		if (!isBooleanExpression || leftOperand === null || rightOperand === null)
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
		} else if (isOrExpression) {
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
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def superInvocationOnlyInValidMethod(WSuperInvocation sup) {
		if (!sup.method.overrides && !sup.isInMixin)
			report(WollokDslValidator_SUPER_ONLY_OVERRIDING_METHOD, sup)
		else if (sup.memberCallArguments.size != sup.method.parameters.size)
			report('''«WollokDslValidator_SUPER_INCORRECT_ARGS» «sup.method.parameters.size»: «sup.method.overriddenMethod.parameters.map[name].join(", ")»''',
				sup)
	}

	// ***********************
	// ** Exceptions
	// ***********************
	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def tryMustHaveEitherCatchOrAlways(WTry tri) {
		if ((tri.catchBlocks === null || tri.catchBlocks.empty) && tri.alwaysExpression === null)
			report(WollokDslValidator_ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS, tri, WTRY__EXPRESSION,
				ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def catchExceptionTypeMustExtendException(WCatch it) {
		if(exceptionType !== null && !exceptionType.exception) report(WollokDslValidator_CATCH_ONLY_EXCEPTION, it,
			WCATCH__EXCEPTION_TYPE)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def unreachableCatch(WCatch it) {
		val hidingCatch = catchesBefore.findFirst [ c |
			c.exceptionType === null || c.exceptionType.isSameOrSuperClassOf(it.exceptionType)
		]
		if (hidingCatch !== null)
			report(WollokDslValidator_UNREACHABLE_CATCH, it, WCATCH__EXCEPTION_VAR_NAME)
	}

	def boolean isSameOrSuperClassOf(WClass one, WClass other) {
		other !== null && (one.fqn == other.fqn || one.isSuperTypeOf(other))
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def postFixOperationOnlyValidforVariables(WPostfixOperation op) {
		if (!(op.operand.isWritableVarRef))
			report(op.feature + WollokDslValidator_POSTFIX_ONLY_FOR_VAR, op, WPOSTFIX_OPERATION__OPERAND)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def classNameCannotBeDuplicatedInFileOrPackage(WClass c) {
		val container = c.eContainer
		val classes = container.eContents.filter(WClass)
		val repeated = classes.filter[_c|c != _c && c.name == _c.name]
		var errorMessage = ""
		if (container instanceof WPackage)
			errorMessage = WollokDslValidator_DUPLICATED_CLASS_IN_PACKAGE + " " + container.name
		else
			errorMessage = WollokDslValidator_DUPLICATED_CLASS_IN_FILE
		val message = errorMessage
		repeated.forEach [
			report(message, it, WNAMED__NAME)
		]
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.NAMING_CONVENTION)
	def classNameCannotBeCoreReservedWord(WClass c) {
		if (ALL_LIBS_FILE.contains(c.eResource.URI.lastSegment)) {
			return
		}
		if ((WollokResourceCache.allCoreClasses.map[name].toList.contains(c.name) || isCoreLib(c.fqn))) {
			report(NLS.bind(WollokDslValidator_CANNOT_USE_CORE_NAME,c.name),c,WNAMED__NAME)
		}	
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def duplicatedPackageName(WPackage p) {
		if (p.eContainer.eContents.filter(WPackage).exists[it != p && name == p.name])
			report(WollokDslValidator_DUPLICATED_PACKAGE + " " + p.name, p, WNAMED__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def multiOpOnlyValidforVarReferences(WBinaryOperation op) {
		if (op.feature.isMultiOpAssignment && !op.leftOperand.isWritableVarRef)
			report(op.feature + WollokDslValidator_BINARYOP_ONLY_ON_VARS, op, WBINARY_OPERATION__LEFT_OPERAND)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.CODE_STYLE)
	def dontCompareAgainstTrueOrFalse(WBinaryOperation it) {
		if (OP_EQUALITY.contains(feature) && leftOperand instanceof WBooleanLiteral)
			report(WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE, it, WBINARY_OPERATION__LEFT_OPERAND)
		if (OP_EQUALITY.contains(feature) && rightOperand instanceof WBooleanLiteral)
			report(WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE, it, WBINARY_OPERATION__RIGHT_OPERAND)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def programInProgramFile(WProgram p) {
		if (p.eResource.URI.nonXPectFileExtension != WollokConstants.PROGRAM_EXTENSION)
			report(WollokDslValidator_PROGRAM_IN_FILE + ''' «WollokConstants.PROGRAM_EXTENSION»''', p, WPROGRAM__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def testInTestFile(WTest t) {
		if (t.eResource.URI.nonXPectFileExtension != WollokConstants.TEST_EXTENSION)
			report(WollokDslValidator_TESTS_IN_FILE + ''' «WollokConstants.TEST_EXTENSION»''', t, WTEST__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def validFileNameAsPackage(WFile f) {
		val validation = ElementNameValidation.validateName(f.eResource.URI.lastSegment)
		if (!validation.ok) {
			report(validation.message, f, WFILE__ELEMENTS, INVALID_NAME_FOR_FILE)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def dontDuplicateTestDescription(WTest wtest) {
		val tests = wtest.siblings
		if (tests.exists[it !== wtest && name == wtest.name])
			report(WollokDslValidator_DONT_DUPLICATE_TEST_DESCRIPTION, wtest, WTEST__NAME)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def testWithEmptyDescription(WTest it) {
		if (name.nullOr[equals("")])
			report(WollokDslValidator_TEST_WITH_EMPTY_DESCRIPTION, it, WTEST__NAME)
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def testShouldSendOneAssertMessage(WTest test) {
		if (!test.elements.empty && !test.elements.exists [ sendsMessageToAssert ])
			report(WollokDslValidator_TEST_SHOULD_HAVE_AT_LEAST_ONE_ASSERT, test, WTEST__ELEMENTS)
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def badUsageOfIfAsBooleanExpression(WIfExpression it) {
		if (then.evaluatesToBoolean && ^else.evaluatesToBoolean) {
			then.checkBadBooleanUsage(^else, it)
		} else {
			val counterpart = nextExpression
			if (counterpart !== null && then.evaluatesToBoolean && counterpart.returnsABoolean) {
				then.checkBadBooleanUsage(counterpart, it)
			}
		}
	}

	def checkBadBooleanUsage(WExpression first, WExpression second, WIfExpression it) {
		if (first.isReturnTrue !== second.isReturnTrue) {
			// uno retorna un booleano y el otro retorna el contrario
			val inlineResult = if (first.isReturnTrue) condition.sourceCode else ("!(" + condition.sourceCode + ")")
			val replacement = " return " + inlineResult
			report(WollokDslValidator_BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION + replacement, it, WIF_EXPRESSION__CONDITION,
				BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION)
		} else {
			// ambos retornan lo mismo
			report(WollokDslValidator_UNNECESSARY_CONDITION, it, WIF_EXPRESSION__CONDITION,
				WollokDslValidator_UNNECESSARY_CONDITION)
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def usingIfInAnExpressionWithoutElse(WIfExpression t) {
		if (t.then === null || t.^else === null && t.eContainer.expectsExpression) {
			report(WollokDslValidator_IF_USED_IN_AN_EXPRESSION_SHOULD_HAVE_AN_ELSE_STATEMENT, t, WIF_EXPRESSION__CONDITION)
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
		} else
			uri.fileExtension
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.UNNECESARY_CODE)
	def noExtraSentencesAfterReturnStatement(WBlockExpression it) {
		checkNoAfter(first(WReturnExpression), WollokDslValidator_NO_EXPRESSION_AFTER_RETURN)
		checkNoAfter(first(WThrow), WollokDslValidator_NO_EXPRESSION_AFTER_THROW)
		expressions.filter(WTry).filter[t|t.cutsTheFlow].forEach[t|checkNoAfter(t, WollokDslValidator_UNREACHABLE_CODE)]
	}

	def checkNoAfter(WBlockExpression it, WExpression riturn, String errorKey) {
		if (riturn !== null) {
			it.getExpressionsAfter(riturn).forEach [ e |
				report(errorKey, it, WBLOCK_EXPRESSION__EXPRESSIONS, it.expressions.indexOf(e))
			]
		}
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def noReturnStatementInConstructor(WReturnExpression it) {
		if (it.inConstructor)
			report(WollokDslValidator_NO_RETURN_EXPRESSION_IN_CONSTRUCTOR, it, WRETURN_EXPRESSION__EXPRESSION)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def cannotReturnAssignment(WReturnExpression it) {
		if (expression !== null && expression.isAssignment)
			report(WollokDslValidator_CANNOT_RETURN_ASSIGNMENT, it, WRETURN_EXPRESSION__EXPRESSION)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def returnUsedInAnExpression(WReturnExpression it) {
		if (expression !== null && !isValidReturnExpression)
			report(WollokDslValidator_CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT, it, WRETURN_EXPRESSION__EXPRESSION, CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT)
	}
	
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def noSuperInConstructorBody(WSuperInvocation it) {
		if (it.isInConstructorBody)
			report(WollokDslValidator_SUPER_EXPRESSION_IN_CONSTRUCTOR, it, WSUPER_INVOCATION__MEMBER_CALL_ARGUMENTS)
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def methodBodyProducesAValueButItIsNotBeingReturned(WMethodDeclaration it) {
		if (!native && !getter && !abstract && !supposedToReturnValue && expression.isEvaluatesToAValue(classFinder)) {
			report(WollokDslValidator_RETURN_FORGOTTEN, it, WMETHOD_DECLARATION__EXPRESSION, RETURN_FORGOTTEN)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def noEffectlessExpressionsInProgram(WProgram sequence) {
		sequence.elements.allButLast.forEach[ it, index |
			if (isPure)
				report(WollokDslValidator_INVALID_EFFECTLESS_EXPRESSION_IN_SEQUENCE, it.eContainer, WPROGRAM__ELEMENTS, index)
		]
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_PROGRAMMING_PROBLEM)
	def noEffectlessExpressionsInSequence(WBlockExpression sequence) {
		sequence.expressions.allButLast.forEach[ it, index |
			if (isPure)
				report(WollokDslValidator_INVALID_EFFECTLESS_EXPRESSION_IN_SEQUENCE, it.eContainer, WBLOCK_EXPRESSION__EXPRESSIONS, index)
		]
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def overridingMethodMustHaveABody(WMethodDeclaration it) {
		if (overrides && expression === null && !native)
			report(WollokDslValidator_OVERRIDING_METHOD_MUST_HAVE_A_BODY, it)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def void wrongImport(Import it) {
		val importedString = importedNamespaceWithoutWildcard
		val scope = it.getScope(scopeProvider)
		val allImports = #[importedString] + localScopeProvider.allRelativeImports(importedString, it)

		allImports.exists [ anImport |
			val found = scope.getElements(qualifiedNameConverter.toQualifiedName(anImport))
			!found.empty
		]

		if(allImports.exists [ anImport | 
			val found = scope.getElements(qualifiedNameConverter.toQualifiedName(anImport))
			!found.empty
		])
			return
		
		//Check now if it is a directory, if it is a directory would not be in the returned collection (a directorio is not a ECore element)
		val rootDirectory = WollokRootLocator.rootDirectory(it.eResource)
		if(allImports.exists [ anImport | 
			val file = new File(rootDirectory + '/' + anImport.replace('.', '/'))
			file.exists
		])
			return;
		
		report(WollokDslValidator_WRONG_IMPORT + " " + importedNamespace, it, IMPORT__IMPORTED_NAMESPACE)
	}

	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def varArgMustBeTheLastParameter(WParameter it) {
		if (isVarArg && eContainer.parameters().last != it) {
			report(WollokDslValidator_VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE, it, WPARAMETER__VAR_ARG,
				VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def dontUseLocalVarOnlyToReturn(WVariableDeclaration it) {
		if (isLocalToMethod && onlyUsedInReturn) {
			report(WollokDslValidator_DONT_USE_LOCAL_VAR_ONLY_TO_RETURN, it, WVARIABLE_DECLARATION__VARIABLE)
		}
	}

	// ******************************
	// ** native methods
	// ******************************
	@Check
	@DefaultSeverity(ERROR)
	@NotConfigurable
	def nativeMethodsChecks(WMethodDeclaration it) {
		if (native) {
			if(expression !== null) report(WollokDslValidator_NATIVE_METHOD_NO_BODY, it, WMETHOD_DECLARATION__EXPRESSION)
			if(declaringContext instanceof WObjectLiteral) report(WollokDslValidator_NATIVE_METHOD_ONLY_IN_CLASSES, it,
				WMETHOD_DECLARATION__NATIVE)
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)	
	def emptyPrograms(WProgram it) {
		if (elements.isEmpty) {
			report(WollokDslValidator_PROGRAM_CANNOT_BE_EMPTY, it, WPROGRAM__ELEMENTS)
		}
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)	
	def emptyTest(WTest it) {
		if (elements.isEmpty) {
			report(WollokDslValidator_TESTS_CANNOT_BE_EMPTY, it, WTEST__ELEMENTS)
		}
	}	

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)	
	def emptyFixture(WFixture it) {
		if (elements.isEmpty) {
			report(WollokDslValidator_FIXTURE_CANNOT_BE_EMPTY, it, WFIXTURE__ELEMENTS)
		}
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)	
	def emptyDescribe(WSuite it) {	
		if (tests.isEmpty()) {
			val errors = syntaxErrorsOf(eResource)		 
			if(errors.isEmpty()){
				report(WollokDslValidator_DESCRIBE_CANNOT_BE_EMPTY, it, WSUITE__NAME)
			}else{
				val errorsInSuite = errors.filter[ error | error.parent.semanticElement == it ].toList
				if(errorsInSuite.isEmpty){
					report(WollokDslValidator_DESCRIBE_CANNOT_BE_EMPTY, it, WSUITE__NAME)
				}
			}
		}
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def describeWithEmptyDescription(WSuite it) {
		if ((name ?: "").equals(""))
			report(WollokDslValidator_DESCRIBE_WITH_EMPTY_DESCRIPTION, it, WSUITE__NAME)
	}

	@Check
	@DefaultSeverity(ERROR)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def duplicatedDescribeNames(WFile it){
		suites.forEach[ suite |
			if(suites.exists[ aSuite | aSuite !== suite && aSuite.name == suite.name]){
				report(WollokDslValidator_CANNOT_DUPLICATED_DESCRIBES_NAME, suite, WSUITE__NAME)
			}
		]
	}
	
	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def severalTestsMarkedAsOnly(WFile it) {
		tests.validateTestsMarkedAsOnly
	}

	@Check
	@DefaultSeverity(WARN)
	@CheckGroup(WollokCheckGroup.POTENTIAL_DESIGN_PROBLEM)
	def suiteWithSeveralTestsMarkedAsOnly(WSuite it) {
		tests.validateTestsMarkedAsOnly
	}

	private def void validateTestsMarkedAsOnly(List<WTest> possibleTests) {
		val testsWithOnlyFlag = possibleTests.filter [ only !== null ].toList
		if (testsWithOnlyFlag.size > 1) {
			testsWithOnlyFlag.forEach [ test | report(WollokDslValidator_TEST_WITH_ONLY_FLAG_SHOULD_BE_SINGLE, test, WTEST__NAME) ]
		}
	}	

	def syntaxErrorsOf(Resource resource) {
		val errors = (resource as XtextResource).parseResult.syntaxErrors.toList
		return errors.filter[ error | error.syntaxErrorMessage !== null ].toList
	}
	
}
