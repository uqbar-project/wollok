package org.uqbar.project.wollok.tests.interpreter.repl

import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

class WollokReplInjector extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		return new WollokLauncherSetup().createInjectorAndDoEMFRegistration();
	}
	
}