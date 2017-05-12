package org.uqbar.project.wollok.launch.setup

import org.uqbar.project.wollok.WollokDslRuntimeModule
import org.uqbar.project.wollok.launch.DefaultWollokLauncherIssueHandler
import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.launch.WollokLauncherIssueHandler
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.tests.DefaultWollokTestsReporter
import org.uqbar.project.wollok.launch.tests.WollokConsoleTestsReporter
import org.uqbar.project.wollok.launch.tests.WollokRemoteTestReporter
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.launch.tests.json.WollokJSONTestsReporter
import org.uqbar.project.wollok.launch.tests.json.WollokLauncherIssueHandlerJSON
import org.uqbar.project.wollok.scoping.WollokReplGlobalScopeProvider
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.interpreter.WollokREPLInterpreterEvaluator

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
		if (params.hasRepl)
			return WollokReplGlobalScopeProvider
		else
			return WollokGlobalScopeProvider
	}

	override bindXInterpreterEvaluator() {
		if (params.hasRepl)
			return WollokREPLInterpreterEvaluator
		else
			return WollokLauncherInterpreterEvaluator
	}
	
	override libs() {
		params.libraries
	}
	

	def Class<? extends WollokTestsReporter> bindWollokTestsReporter() {
		if (params.tests) {
			if (params.testPort != null && params.testPort != 0)
				return WollokRemoteTestReporter
			else if (params.jsonOutput)
				return WollokJSONTestsReporter
			else
				return WollokConsoleTestsReporter
		} else
			return DefaultWollokTestsReporter
	}

	def Class<? extends WollokLauncherIssueHandler> bindWollokLauncherIssueHandler() {
		if (params.tests && params.jsonOutput)
			WollokLauncherIssueHandlerJSON
		else
			DefaultWollokLauncherIssueHandler
	}
}
