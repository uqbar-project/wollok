package org.uqbar.project.wollok.ui.wizard;

import org.uqbar.project.wollok.Wollok;

public class WollokDslProjectInfo extends org.eclipse.xtext.ui.wizard.DefaultProjectInfo {

	public String getVersion() { return Wollok.VERSION; }

	public String getAuthor() { return System.getProperty("user.name"); }
}
