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
	
	public static String WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE;
	public static String WollokDslValidator_REFERENCIABLE_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_CANNOT_INSTANTIATE_ABSTRACT_CLASS;
	public static String WollokDslValidator_WCONSTRUCTOR_CALL__ARGUMENTS;
	
	// overrides
	public static String WollokDslValidator_METHOD_NOT_OVERRIDING;
	public static String WollokDslValidator_METHOD_MUST_HAVE_OVERRIDE_KEYWORD;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_RETURN_VALUE;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_NOT_RETURN_VALUE;
	public static String WollokDslValidator_OVERRIDING_METHOD_MUST_HAVE_A_BODY;
	
	public static String WollokDslValidator_GETTER_METHOD_SHOULD_RETURN_VALUE;
	public static String WollokDslValidator_CANNOT_MODIFY_VAL;
	public static String WollokDslValidator_CANNOT_ASSIGN_TO_ITSELF;
	public static String WollokDslValidator_DUPLICATED_METHOD;
	public static String WollokDslValidator_DUPLICATED_VARIABLE_IN_HIERARCHY;
	public static String WollokDslValidator_DUPLICATED_NAME;
	public static String WollokDslValidator_METHOD_ON_THIS_DOESNT_EXIST;
	public static String WollokDslValidator_METHOD_ON_WKO_DOESNT_EXIST;
	public static String WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES;
	public static String WollokDslValidator_WARN_VARIABLE_NEVER_ASSIGNED;
	public static String WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED;
	public static String WollokDslValidator_VARIABLE_NEVER_USED;
	public static String WollokDslValidator_SUPER_ONLY_IN_CLASSES;
	public static String WollokDslValidator_SUPER_ONLY_OVERRIDING_METHOD;
	public static String WollokDslValidator_SUPER_INCORRECT_ARGS;
	public static String WollokDslValidator_ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS;
	public static String WollokDslValidator_CATCH_ONLY_EXCEPTION;
	public static String WollokDslValidator_UNREACHABLE_CATCH;
	public static String WollokDslValidator_POSTFIX_ONLY_FOR_VAR;
	public static String WollokDslValidator_DUPLICATED_CLASS_IN_PACKAGE;
	public static String WollokDslValidator_DUPLICATED_PACKAGE;
	public static String WollokDslValidator_PROGRAM_IN_FILE;
	public static String WollokDslValidator_CLASSES_IN_FILE;
	public static String WollokDslValidator_NATIVE_METHOD_NO_BODY;
	public static String WollokDslValidator_NATIVE_METHOD_NO_OVERRIDE;
	public static String WollokDslValidator_NATIVE_METHOD_ONLY_IN_CLASSES;
	public static String WollokDslValidator_NATIVE_IN_NATIVE_SUBCLASS;
	public static String WollokDslValidator_BINARYOP_ONLY_ON_VARS;
	public static String WollokDslValidator_MUST_IMPLEMENT_ABSTRACT_METHODS;
	
	public static String WollokDslValidator_DONT_COMPARE_AGAINST_TRUE_OR_FALSE;
	
	public static String WollokDslValidator_NO_RETURN_EXPRESSION_IN_CONSTRUCTOR;
	public static String WollokDslValidator_CANNOT_RETURN_ASSIGNMENT;
	public static String WollokDslValidator_SUPER_EXPRESSION_IN_CONSTRUCTOR;
	public static String WollokDslValidator_RETURN_FORGOTTEN;
	public static String WollokDslValidator_METHOD_DOES_NOT_RETURN_A_VALUE_ON_EVERY_POSSIBLE_FLOW;
	public static String WollokDslValidator_VAR_ARG_PARAM_MUST_BE_THE_LAST_ONE;
	
	public static String WollokDslValidator_WRONG_IMPORT;
	
	public static String WollokDslValidator_NO_EXPRESSION_AFTER_RETURN;
	public static String WollokDslValidator_NO_EXPRESSION_AFTER_THROW;
	public static String WollokDslValidator_UNREACHABLE_CODE;
	public static String WollokDslValidator_BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION;
	
	// SELF
	public static String WollokDslValidator_CANNOT_USE_SELF_IN_A_PROGRAM;
	
	public static String WollokDslValidator_EXPECTING_BOOLEAN;
	public static String WollokDslValidator_UNNECESSARY_IF;
	public static String WollokDslValidator_UNNECESSARY_CONDITION;
	public static String WollokDslValidator_ALWAYS_EVALUATES_TO_FALSE;
	public static String WollokDslValidator_ALWAYS_EVALUATES_TO_TRUE;
	
	public static String CheckSeverity_ERROR;
	public static String CheckSeverity_WARN;
	public static String CheckSeverity_INFO;
	
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
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}
