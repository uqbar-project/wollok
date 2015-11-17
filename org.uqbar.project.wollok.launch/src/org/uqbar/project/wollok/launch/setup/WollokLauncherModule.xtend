package org.uqbar.project.wollok.launch.setup

import org.uqbar.project.wollok.WollokDslRuntimeModule
import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.tests.DefaultWollokTestsReporter
import org.uqbar.project.wollok.launch.tests.WollokConsoleTestsReporter
import org.uqbar.project.wollok.launch.tests.WollokRemoteTestReporter
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.scoping.WollokReplGlobalScopeProvider

/**
 * Runtime module for the launcher.
 * It changes the test reporter for test execution
 * 
 * @author tesonep
 */
class WollokLauncherModule extends WollokDslRuntimeModule {
	val WollokLauncherParameters params
	
	new(WollokLauncherParameters params) {
		this.params = params
	}
	
	override bindIGlobalScopeProvider() {
		return WollokReplGlobalScopeProvider
	}
	
	override bindXInterpreterEvaluator() {
		return WollokLauncherInterpreterEvaluator
	}
	
	def Class<? extends WollokTestsReporter> bindWollokTestsReporter() {
		if (params.tests) {
			if (params.testPort != null && params.testPort != 0)
				return WollokRemoteTestReporter
			else
				return WollokConsoleTestsReporter
		}
		else
			return DefaultWollokTestsReporter
	}
	
}
