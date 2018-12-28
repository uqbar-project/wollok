package org.uqbar.project.wollok.launch;

import org.eclipse.osgi.util.NLS;

/**
 * i18n keys for the REPL
 * 
 * @author jfernandes
 */
public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.launch.messages"; //$NON-NLS-1$
	
	public static String ALL_TEST_IN_PROJECT;
	public static String ALL_TEST_IN_FOLDER;
	public static String LINE;
	public static String REPL_WELCOME;
	public static String REPL_END;

	// ****************************
	// ** Launcher messages
	// ****************************
	public static String WollokLauncher_REQUEST_PORT_EVENTS_PORT_ARE_BOTH_REQUIRED;
	public static String WollokLauncher_REPL_ONLY_WITH_WLK_FILES;
	public static String WollokLauncher_FILE_OR_REPL_REQUIRED;
	public static String WollokLauncher_INVALID_PARAMETER_NUMBER;
	
	// ******************************
	// ** Launcher Options Messages
	// ******************************
	public static String WollokLauncherOptions_REPL;
	public static String WollokLauncherOptions_DYNAMIC_DIAGRAM_ACTIVATED;
	public static String WollokLauncherOptions_RUNNING_TESTS;
	public static String WollokLauncherOptions_JSON_TEST_OUTPUT;
	public static String WollokLauncherOptions_DISABLE_COLORS_REPL;
	public static String WollokLauncherOptions_SEVERAL_FILES;
	public static String WollokLauncherOptions_SERVER_PORT;
	public static String WollokLauncherOptions_DYNAMIC_DIAGRAM_PORT;
	public static String WollokLauncherOptions_REQUEST_PORT;
	public static String WollokLauncherOptions_EVENTS_PORT;
	public static String WollokLauncherOptions_SPECIFIC_FOLDER;
	public static String WollokLauncherOptions_NUMBER_DECIMALS;
	public static String WollokLauncherOptions_DECIMAL_PRINTING_STRATEGY;
	public static String WollokLauncherOptions_DECIMAL_CONVERSION_STRATEGY;
	public static String WollokLauncherOptions_JAR_LIBRARIES;
	public static String WollokLauncherOptions_WOLLOK_FILES;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}

	private Messages() {
	}
}
