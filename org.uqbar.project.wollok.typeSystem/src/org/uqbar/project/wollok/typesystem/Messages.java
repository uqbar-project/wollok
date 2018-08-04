package org.uqbar.project.wollok.typesystem;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.typesystem.messages"; //$NON-NLS-1$

	// ****************************
	// ** Type system preference page
	// ****************************

	public static String WollokTypeSystem_INFO_DESCRIPTION;
	public static String WollokTypeSystem_WARN_DESCRIPTION;
	public static String WollokTypeSystem_ERROR_DESCRIPTION;

	public static String WollokTypeSystemPreference_ENABLE_TYPE_SYSTEM_CHECKS_TITLE;
	public static String WollokTypeSystemPreference_TYPE_SYSTEM_IMPLEMENTATION_TITLE;
	public static String WollokTypeSystemPreference_TYPE_SYSTEM_ISSUE_SEVERITY_TITLE;
	
	public static String WollokTypeSystemPreference_SAVE_JOB_TITLE;
	public static String WollokTypeSystemPreference_CONFIRM_BUILD_PROJECT_TITLE;
	public static String WollokTypeSystemPreference_CONFIRM_BUILD_PROJECT_MESSAGE;
	public static String WollokTypeSystemPreference_CONFIRM_BUILD_ALL_MESSAGE;
	public static String WollokTypeSystemPreference_REBUILD_JOB_TITLE;
	
	// ****************************
	// ** Type system exceptions
	// ****************************
	public static String TypeSystemException_INCOMPATIBLE_TYPE;
	public static String TypeSystemException_INCOMPATIBLE_TYPE_DETAILED;
	public static String TypeSystemException_INCOMPATIBLE_TYPE_EXPECTED;
	public static String TypeSystemException_INCOMPATIBLE_TYPE_NOT_SUPPORTED_MESSAGES;
	public static String TypeSystemException_NOT_VALID_SUBSTITUTE;
	public static String TypeSystemException_MISSING_TYPE_INFORMATION;
	public static String TypeSystemException_REJECTED_MIN_TYPE_MESSAGE;
	
	public static String RuntimeTypeSystemException_CANT_FIND_MIN_TYPE;
	public static String RuntimeTypeSystemException_CANT_EXTRACT_METHOD_TYPE;
	public static String RuntimeTypeSystemException_WRONG_WAY_CLOSURE_TYPE;
	public static String RuntimeTypeSystemException_GENERIC_TYPE_EXPECTED;
	public static String RuntimeTypeSystemException_GENERIC_TYPE_MUST_BE_INSTANTIATED;
	public static String RuntimeTypeSystemException_BAD_TYPE_ANNOTATION;
	public static String RuntimeTypeSystemException_TYPE_VARIABLE_MUST_HAVE_AN_OWNER;
	public static String RuntimeTypeSystemException_STRUCTURAL_TYPES_NOT_SUPPORTED;
	public static String RuntimeTypeSystemException_EXTRACTING_TYPE_CLASS_NOT_IMPLEMENTED;
	public static String RuntimeTypeSystemException_ELEMENT_HAS_NO_ARGUMENTS;
	public static String RuntimeTypeSystemException_TRIED_TO_ADD_ERROR_TO_CORE_OBJECT;
	public static String RuntimeTypeSystemException_REQUIRES_PROGRAM_ELEMENT;
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}
