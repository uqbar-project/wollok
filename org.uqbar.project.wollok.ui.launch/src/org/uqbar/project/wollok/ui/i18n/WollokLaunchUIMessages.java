package org.uqbar.project.wollok.ui.i18n;

import org.eclipse.osgi.util.NLS;

public class WollokLaunchUIMessages extends NLS {
	private static final String BASE_NAME = "org.uqbar.project.wollok.ui.i18n.messages"; //$NON-NLS-1$

	public static String PROBLEM_LAUNCHING_WOLLOK;
	public static String ADD_LAUNCH_PLUGIN_DEPENDENCY;
	
	public static String WollokMainTab_PROGRAM_FILE;
	public static String WollokMainTab_TEST_FILE;
	public static String WollokMainTab_BROWSE;
	public static String WollokMainTab_BROWSE_PROGRAM_TITLE;
	public static String WollokMainTab_BROWSE_PROGRAM_DESCRIPTION;
	public static String WollokMainTab_FILE_DOES_NOT_EXIST;
	public static String WollokMainTab_SPECIFY_NEW_FILE;
	public static String WollokMainTab_BROWSE_TEST_TITLE;
	public static String WollokMainTab_BROWSE_TEST_DESCRIPTION;
	
	public static String WollokLaunch_GENERAL_ERROR_MESSAGE;
	public static String WollokTestLaunch_TITLE;
	public static String WollokTestLaunch_ERROR_MESSAGE;
	
	public static String WollokDebugger_GENERAL_ERROR_MESSAGE;
	
	public static String WollokTestState_ASSERTION_ERROR;
	public static String WollokTestState_ASSERT;
	public static String WollokTestState_ERROR;
	public static String WollokTestState_OK;
	public static String WollokTestState_PENDING;
	public static String WollokTestState_RUNNING;
	
	public static String WollokTestResultView_TOTAL_TESTS;
	public static String WollokTestResultView_RUN_TESTS;
	public static String WollokTestResultView_FAILED_TESTS;
	public static String WollokTestResultView_ERROR_TESTS;

	public static String WollokTestState_ASSERT_WAS_NOT_TRUE;
	public static String WollokTestState_ASSERT_WAS_NOT_FALSE;
	public static String WollokTestState_ASSERT_WAS_NOT_EQUALS;
	public static String WollokTestState_ASSERT_WAS_NOT_DIFFERENT;
	
	public static String WollokRepl_STOP_TITLE;
	public static String WollokRepl_EXPORT_HISTORY_TITLE;
	public static String WollokRepl_SYNCED_MESSAGE;
	public static String WollokRepl_OUTDATED_MESSAGE;
	public static String WollokRepl_SYNCED_TOOLTIP;
	public static String WollokRepl_OUTDATED_TOOLTIP;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BASE_NAME, WollokLaunchUIMessages.class);
	}

	private WollokLaunchUIMessages() {
	}

}
