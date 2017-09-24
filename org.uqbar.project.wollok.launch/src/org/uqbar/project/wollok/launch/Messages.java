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
	public static String WVM_ERROR;

	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}

	private Messages() {
	}
}
