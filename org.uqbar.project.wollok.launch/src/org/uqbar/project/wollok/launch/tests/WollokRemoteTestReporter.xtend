package org.uqbar.project.wollok.launch.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.LinkedList
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import static extension org.uqbar.project.wollok.launch.tests.WollokExceptionUtils.*
import org.uqbar.project.wollok.launch.Messages
import org.eclipse.osgi.util.NLS

/**
 * WollokTestReporter implementation that sends the event to a remote
 * WollokRemoteUITestNotifier instance.
 * 
 * It uses RMI to communicate with another process (the UI)
 * 
 * @author tesonep
 */
class WollokRemoteTestReporter implements WollokTestsReporter {

	@Inject
	var WollokLauncherParameters parameters

	var Client client
	var callHandler = new CallHandler
	var WollokRemoteUITestNotifier remoteTestNotifier
	val testsResult = new LinkedList<WollokResultTestDTO>
	var boolean processingManyFiles
	
	String suiteName
	List<WTest> allTests

	@Inject
	def init() {
		client = new Client("localhost", parameters.testPort, callHandler)
		remoteTestNotifier = client.getGlobal(WollokRemoteUITestNotifier) as WollokRemoteUITestNotifier
		allTests = newArrayList
	}

	override reportTestAssertError(WTest test, AssertionException assertionException, int lineNumber, URI resource) {
		testsResult.add(WollokResultTestDTO.assertionError(test.name, assertionException.message, assertionException.wollokException?.convertStackTrace, lineNumber, resource?.toString))
	}

	override reportTestOk(WTest test) {
		testsResult.add(WollokResultTestDTO.ok(test.name))
	}

	override testsToRun(String _suiteName, WFile file, List<WTest> tests) {
		this.suiteName = _suiteName
		if (processingManyFiles) {
			this.suiteName = NLS.bind(Messages.ALL_TEST_IN_PROJECT, file.project.name)
			this.allTests.addAll(tests)
		} else {
			this.allTests = tests
			remoteTestNotifier.testsToRun(suiteName, file.eResource.URI.toString, new ArrayList(tests.map[new WollokTestInfo(it)]))
		}
	}

	override testStart(WTest test) {
		// for better performance we avoid a RMI call
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		testsResult.add(
			WollokResultTestDTO.error(test.name, exception.convertToString, exception.convertStackTrace, lineNumber,
				resource?.toString))
	}

	override finished() {
		if (!processingManyFiles) {
			remoteTestNotifier.testsResult(testsResult)
		}
	}

	override initProcessManyFiles() {
		processingManyFiles = true
	}
	
	override endProcessManyFiles() {
		processingManyFiles = false
		remoteTestNotifier.testsToRun(suiteName, "", runnedTestsInfo)
		remoteTestNotifier.testsResult(testsResult)
	}
	
	protected def List<WollokTestInfo> getRunnedTestsInfo() {
		new ArrayList(allTests.map[new WollokTestInfo(it)])
	}
	
}
