package org.uqbar.project.wollok.tests.interpreter.repl

import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

/**
 * @author tesonep
 */
class WollokReplInjector extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		new WollokLauncherSetup().createInjectorAndDoEMFRegistration
	}

}