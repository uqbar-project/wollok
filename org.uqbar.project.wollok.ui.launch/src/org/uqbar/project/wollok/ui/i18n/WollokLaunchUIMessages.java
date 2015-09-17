package org.uqbar.project.wollok.ui.i18n;

import org.eclipse.osgi.util.NLS;

public class WollokLaunchUIMessages extends NLS {
	private static final String BASE_NAME = "org.uqbar.project.wollok.ui.i18n.messages"; //$NON-NLS-1$

	public static String WollokTestState_ASSERTION_ERROR;
	public static String WollokTestState_ASSERT;
	public static String WollokTestState_ERROR;
	public static String WollokTestState_OK;
	public static String WollokTestState_PENDING;
	public static String WollokTestState_RUNNING;

	public static String WollokTestResultView_TOTAL_TESTS;
	public static String WollokTestResultView_RUN_TESTS;
	public static String WollokTestResultView_ERROR_TESTS;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BASE_NAME, WollokLaunchUIMessages.class);
	}

	private WollokLaunchUIMessages() {
	}

}
