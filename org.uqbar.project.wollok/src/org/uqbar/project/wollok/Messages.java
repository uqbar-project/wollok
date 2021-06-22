package org.uqbar.project.wollok;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

/**
 * Holds keys for all i18nized texts.
 * Check for messages.properties file
 * 
 * @author jfernandes
 */
public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.messages"; //$NON-NLS-1$

	public static String LINKING_COULD_NOT_RESOLVE_REFERENCE;

	public static String WollokInterpreter_cannot_use_null_in_if;
	public static String WollokInterpreter_expression_in_if_must_evaluate_to_boolean;
	public static String WollokInterpreter_error_evaluating_line;
	public static String WollokInterpreter_errorWhileMessageNotUnderstood;
	public static String WollokInterpreter_unrecognizedVariable;
	public static String WollokInterpreter_lazyValuesOnlySupportEval;
	public static String WollokInterpreter_assertionExceptionNotValid;
	public static String WollokInterpreter_errorWhileResolvingOperation;
	public static String WollokInterpreter_operationNotSupported;
	public static String WollokInterpreter_operatorNotSupported;
	public static String WollokInterpreter_constructorCallNotAllowed;
	public static String WollokInterpreter_binaryOperationNotCompoundAssignment;
	public static String WollokInterpreter_visualObjectWithoutPosition;
	public static String WollokInterpreter_illegalOperationEmptyCollection;
	public static String WollokDslInterpreter_native_class_not_found;
	public static String WollokInterpreter_referenceAlreadyDefined;
	
	public static String WollokScopeProvider_unresolvedImport;
	
	public static String WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE;
	public static String WollokDslValidator_REFERENCIABLE_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_VARIABLE_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_PARAMETER_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_OBJECT_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_CANNOT_INSTANTIATE_ABSTRACT_CLASS;
	public static String WollokDslValidator_PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS;
	public static String WollokDslValidator_PROPERTY_NOT_WRITABLE;
	
	// overrides
	public static String WollokDslValidator_METHOD_NOT_OVERRIDING;
	public static String WollokDslValidator_METHOD_MUST_HAVE_OVERRIDE_KEYWORD;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_RETURN_VALUE;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_HAVE_A_BODY;
	public static String WollokDslValidator_METHOD_OVERRIDING_BASE_CLASS;
	public static String WollokDslValidator_METHOD_IS_RETURNING_BLOCK;

	public static String WollokDslValidator_GETTER_METHOD_SHOULD_RETURN_VALUE;
	public static String WollokDslValidator_CANNOT_MODIFY_VAL;
	public static String WollokDslValidator_CANNOT_MODIFY_REFERENCE;
	public static String WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF;
	public static String WollokDslValidator_CYCLIC_HIERARCHY;
	public static String WollokDslValidator_INVALID_MIXIN_HIERARCHY;
	public static String WollokDslValidator_CANNOT_USE_DERIVED_KEYWORD;
	public static String WollokDslValidator_CANNOT_DEFINE_MULTIPLE_PARENT_CLASSES;
	public static String WollokDslValidator_BAD_LINEARIZATION_DEFINITION;
	public static String WollokDslValidator_DUPLICATED_METHOD;
	public static String WollokDslValidator_DUPLICATED_VARIABLE_IN_HIERARCHY;
	public static String WollokDslValidator_DUPLICATED_VARIABLE_IN_CONSTRUCTOR_CALL;
	public static String WollokDslValidator_DUPLICATED_NAME;
	public static String WollokDslValidator_DUPLICATED_REFERENCE_FROM_IMPORTS;
	public static String WollokDslValidator_METHOD_ON_THIS_DOESNT_EXIST;
	public static String WollokDslValidator_METHOD_DOESNT_EXIST;
	public static String WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND;
	public static String WollokDslValidator_UNDEFINED_ATTRIBUTE_IN_CONSTRUCTOR_CALL;
	public static String WollokDslValidator_UNDEFINED_ATTRIBUTE_IN_LINEARIZATION;
	public static String WollokDslValidator_DUPLICATE_ATTRIBUTE_IN_LINEARIZATION;
	public static String WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE;
	public static String WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES;
	public static String WollokDslValidator_INITIALIZATION_VALUE_FOR_VARIABLE_NEVER_USED;
	public static String WollokDslValidator_WARN_VARIABLE_NEVER_ASSIGNED;
	public static String WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED;
	public static String WollokDslValidator_GLOBAL_VARIABLE_NOT_ALLOWED;
	public static String WollokDslValidator_MISSING_ASSIGNMENTS_IN_CONSTRUCTOR_CALL;
	public static String WollokDslValidator_VARIABLE_NEVER_USED;
	public static String WollokDslValidator_VARIABLE_SHOULD_BE_CONST;
	public static String WollokDslValidator_PARAMETER_NEVER_USED;
	public static String WollokDslValidator_SUPER_ONLY_IN_CLASSES;
	public static String WollokDslValidator_SUPER_ONLY_OVERRIDING_METHOD;
	public static String WollokDslValidator_SUPER_INCORRECT_ARGS;
	public static String WollokDslValidator_ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS;
	public static String WollokDslValidator_CATCH_ONLY_EXCEPTION;
	public static String WollokDslValidator_UNREACHABLE_CATCH;
	public static String WollokDslValidator_POSTFIX_ONLY_FOR_VAR;
	public static String WollokDslValidator_DUPLICATED_CLASS_IN_PACKAGE;
	public static String WollokDslValidator_DUPLICATED_CLASS_IN_FILE;
	public static String WollokDslValidator_DUPLICATED_PACKAGE;
	public static String WollokDslValidator_CANNOT_USE_CORE_NAME;
	public static String WollokDslValidator_PROGRAM_IN_FILE;
	public static String WollokDslValidator_PROGRAM_CANNOT_BE_EMPTY;
	public static String WollokDslValidator_CLASSES_IN_FILE;
	public static String WollokDslValidator_TESTS_IN_FILE;
	public static String WollokDslValidator_TESTS_CANNOT_BE_EMPTY;
	public static String WollokDslValidator_FIXTURE_CANNOT_BE_EMPTY;
	public static String WollokDslValidator_DESCRIBE_CANNOT_BE_EMPTY;
	public static String WollokDslValidator_DESCRIBE_WITH_EMPTY_DESCRIPTION;
	public static String WollokDslValidator_CANNOT_DUPLICATED_DESCRIBES_NAME;
	public static String WollokDslValidator_NATIVE_METHOD_NO_BODY;
	public static String WollokDslValidator_NATIVE_METHOD_NO_OVERRIDE;
	public static String WollokDslValidator_NATIVE_METHOD_ONLY_IN_CLASSES;
	public static String WollokDslValidator_NATIVE_IN_NATIVE_SUBCLASS;
	public static String WollokDslValidator_BINARYOP_ONLY_ON_VARS;
	public static String WollokDslValidator_CLASS_MUST_IMPLEMENT_ABSTRACT_METHODS;
	public static String WollokDslValidator_CLASS_WITHOUT_INHERITANCE_MUST_IMPLEMENT_ALL_METHODS;
	public static String WollokDslValidator_WKO_MUST_IMPLEMENT_ABSTRACT_METHODS;
	public static String WollokDslValidator_WKO_WITHOUT_INHERITANCE_MUST_IMPLEMENT_ALL_METHODS;
	public static String WollokDslValidator_INCONSISTENT_HIERARCHY_MIXIN_CALLING_SUPER_NOT_FULLFILLED;
	public static String WollokDslValidator_ABSTRACT_METHOD_DEFINITION;
	
	public static String WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE;
	public static String WollokDslValidator_DO_NOT_COMPARE_FOR_EQUALITY_WKO;
	
	public static String WollokDslValidator_CANNOT_RETURN_ASSIGNMENT;
	public static String WollokDslValidator_RETURN_FORGOTTEN;
	public static String WollokDslValidator_CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT;
	public static String WollokDslValidator_METHOD_DOES_NOT_RETURN_A_VALUE_ON_EVERY_POSSIBLE_FLOW;
	public static String WollokDslValidator_INVALID_EFFECTLESS_EXPRESSION_IN_SEQUENCE;
	public static String WollokDslValidator_VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE;
	public static String WollokDslValidator_REFERENCE_UNINITIALIZED;
	public static String WollokDslValidator_DONT_MIX_NAMED_AND_POSITIONAL_PARAMETERS;
	public static String WollokDslValidator_NAMED_PARAMETERS_NOT_ALLOWED;
	
	public static String WollokDslValidator_DONT_USE_LOCAL_VAR_ONLY_TO_RETURN;
	
	public static String WollokDslValidator_DONT_DUPLICATE_TEST_DESCRIPTION;
	public static String WollokDslValidator_TEST_WITH_EMPTY_DESCRIPTION;
	public static String WollokDslValidator_TEST_SHOULD_HAVE_AT_LEAST_ONE_ASSERT;
	public static String WollokDslValidator_TEST_WITH_ONLY_FLAG_SHOULD_BE_SINGLE;
	
	public static String WollokDslValidator_OVERRIDING_A_METHOD_SHOULD_DO_SOMETHING_DIFFERENT;
	
	public static String WollokRuntime_WrongMessage_EMPTY_LIST;
	
	public static String TestLauncher_CompilationErrorTitle;
	public static String TestLauncher_SeeProblemTab;
	public static String TestLauncher_LauncherError_Title;
	public static String TestLauncher_LauncherError_Message;
	public static String TestLauncher_NoTestToRun_Title;
	public static String TestLauncher_NoTestToRun_Message;
	
	public static String WollokDslValidator_WRONG_IMPORT;
	
	public static String WollokDslValidator_NO_EXPRESSION_AFTER_RETURN;
	public static String WollokDslValidator_NO_EXPRESSION_AFTER_THROW;
	public static String WollokDslValidator_UNREACHABLE_CODE;
	public static String WollokDslValidator_BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION;
	public static String WollokDslValidator_IF_USED_IN_AN_EXPRESSION_SHOULD_HAVE_AN_ELSE_STATEMENT;
	
	// SELF
	public static String WollokDslValidator_CANNOT_USE_SELF_IN_A_PROGRAM;
	public static String WollokDslValidator_DONT_USE_WKONAME_WITHIN_IT;
	
	public static String WollokDslValidator_EXPECTING_BOOLEAN;
	public static String WollokDslValidator_EXPECTING_BOOLEAN_COMPARING_VS_ASSIGNING;
	public static String WollokDslValidator_UNNECESSARY_IF;
	public static String WollokDslValidator_UNNECESSARY_CONDITION;
	public static String WollokDslValidator_ALWAYS_EVALUATES_TO_FALSE;
	public static String WollokDslValidator_ALWAYS_EVALUATES_TO_TRUE;
	
	public static String CheckSeverity_ERROR;
	public static String CheckSeverity_WARN;
	public static String CheckSeverity_INFO;
	public static String CheckSeverity_IGNORE;
	
	// ****************************
	// ** Check groups
	// ****************************

	public static String CheckGroup_DEFAULT_GROUP;
	public static String CheckGroup_CODE_STYLE;
	public static String CheckGroup_POTENTIAL_PROGRAMMING_PROBLEM;
	
	// ****************************
	// ** runtime interpreter
	// ****************************
	
	public static String OBJECT_DESCRIPTION_ARTICLE;
	public static String OBJECT_DESCRIPTION_AN_OBJECT;

	// ****************************
	// ** Element name validation
	// ****************************
	
	public static String ElementNameValidation_NameShouldBeAlphabetic;
	public static String ElementNameValidation_InvalidCharacterInName;
	
	// ****************************
	// ** Syntax message provider
	// ****************************

	public static String SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_METHODS;
	public static String SYNTAX_DIAGNOSIS_REFERENCES_NOT_ALLOWED_HERE_GENERIC;
	public static String SYNTAX_DIAGNOSIS_TESTS_NOT_ALLOWED_HERE;
	public static String SYNTAX_DIAGNOSIS_TESTS_NOT_ALLOWED_HERE_GENERIC;	
	public static String SYNTAX_DIAGNOSIS_FIXTURE_BEFORE_TESTS;
	public static String SYNTAX_DIAGNOSIS_FIXTURE_NOT_ALLOWED_HERE;
	public static String SYNTAX_DIAGNOSIS_FIXTURE_NOT_ALLOWED_HERE_GENERIC;	
	public static String SYNTAX_MISSING_BRACKETS_IN_METHOD;
	public static String SYNTAX_DIAGNOSIS_ORDER_PROBLEM;
	public static String SYNTAX_DIAGNOSIS_BAD_CHARACTER_IN_METHOD;
	public static String SYNTAX_DIAGNOSIS_BAD_MESSAGE;
	public static String SYNTAX_DIAGNOSIS_CODE_NOT_ALLOWED_IN_DESCRIBE;
	
	// ****************************
	// ** Conversions
	// ****************************
	
	public static String WollokConversion_INVALID_CONVERSION;
	public static String WollokConversion_UNSUPPORTED_CONVERSION_JAVA_WOLLOK;
	public static String WollokConversion_INTEGER_VALUE_REQUIRED;
	public static String WollokConversion_POSITIVE_INTEGER_VALUE_REQUIRED;
	public static String WollokConversion_DECIMAL_SCALE_REQUIRED;
	public static String WollokConversion_WARNING_NUMBER_VALUE_SCALED;
	public static String WollokConversion_WARNING_NUMBER_VALUE_INTEGER;
	public static String WollokConversion_INVALID_SCALE_NUMBER;
	public static String WollokConversion_INVALID_OPERATION_PARAMETER;
	public static String WollokConversion_INVALID_OPERATION_NULL_PARAMETER;
	public static String WollokConversion_MULTIPLE_MESSAGES_ERROR;
	public static String WollokConversion_INVALID_ARGUMENTS_SIZE;
	public static String WollokConversion_INVALID_ARGUMENTS_SIZE_IN_CLOSURE;
	public static String WollokConversion_INVALID_ARGUMENTS_SIZE_IN_CLOSURE_WITH_VARARGS;
	public static String WollokConversion_STRING_CONVERSION_FAILED;

	public static String WollokMessage_ELEMENT_NOT_FOUND;
	
	// ****************************
	// ** Wollok Number Preferences 
	// ****************************
	
	public static String WollokNumberPreferences_COERCING_STRATEGY_NOTFOUND;
	public static String WollokNumberPreferences_PRINTING_STRATEGY_NOTFOUND;
	
	public static String WollokDictionary_CANNOT_PUT_NULL_KEY;
	public static String WollokDictionary_CANNOT_PUT_NULL_VALUE;
	
	// ****************************
	// ** Wollok Type System
	// ****************************
	
	public static String WollokTypeSystem_AN_EXPRESSION_IS_EXPECTED_AT_THIS_POSITION;

	// ****************************
	// ** Wollok Game 
	// ****************************
	public static String WollokGame_VisualComponentNotFound;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() { }

}
