package org.uqbar.project.wollok;

import org.eclipse.osgi.util.NLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.messages"; //$NON-NLS-1$

	public static String WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE;
	public static String WollokDslValidator_REFERENCIABLE_NAME_MUST_START_LOWERCASE;
	public static String WollokDslValidator_CANNOT_INSTANTIATE_ABSTRACT_CLASS;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}

	private Messages() {
	}

}
