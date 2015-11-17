package org.uqbar.project.wollok.launch.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

class WollokRemoteTestReporter implements WollokTestsReporter {

	@Inject
	var WollokLauncherParameters parameters

	var Client client
	var CallHandler callHandler = new CallHandler
	var WollokRemoteUITestNotifier remoteTestNotifier

	@Inject
	def init() {
		client = new Client("localhost", parameters.testPort, callHandler)
		remoteTestNotifier = client.getGlobal(WollokRemoteUITestNotifier) as WollokRemoteUITestNotifier
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		remoteTestNotifier.assertError(test.name, assertionError, lineNumber, resource.toString)
	}

	override reportTestOk(WTest test) {
		remoteTestNotifier.testOk(test.name)
	}

	override testsToRun(WFile file, List<WTest> tests) {
		remoteTestNotifier.testsToRun(file.eResource.URI.toString, new ArrayList(tests.map[new WollokTestInfo(it)]))
	}

	override testStart(WTest test) {
		remoteTestNotifier.testStart(test.name)
	}

	override reportTestError(WTest test, WollokInterpreterException exception, int lineNumber, URI resource) {
		exception.prepareExceptionForTrip
		remoteTestNotifier.error(test.name, exception, lineNumber, resource.toString)
	}

	def dispatch Object prepareExceptionForTrip(Throwable e) {
		if(e.cause == null)
			return null
			
		e.cause.prepareExceptionForTrip()
	}
	
	def dispatch Object prepareExceptionForTrip(WollokInterpreterException e) {
		e.sourceElement = null;

		if(e.cause == null)
			return null
			
		e.cause.prepareExceptionForTrip()
	}
}
