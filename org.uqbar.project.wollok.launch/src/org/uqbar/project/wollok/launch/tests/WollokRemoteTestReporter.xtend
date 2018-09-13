package org.uqbar.project.wollok.launch.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.LinkedList
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.common.util.URI
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.launch.Messages
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

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
	var String folder
	
	String suiteName
	List<WollokTestInfo> testFiles
	
	@Inject
	def init() {
		client = new Client("localhost", parameters.testPort, callHandler)
		remoteTestNotifier = client.getGlobal(WollokRemoteUITestNotifier) as WollokRemoteUITestNotifier
		testFiles = newArrayList
	}

	override reportTestAssertError(WTest test, AssertionException assertionException, int lineNumber, URI resource) {
		testsResult.add(WollokResultTestDTO.assertionError(test.getFullName(processingManyFiles), assertionException.message, assertionException.wollokException?.convertStackTrace, lineNumber, resource?.toString))
	}

	override reportTestOk(WTest test) {
		testsResult.add(WollokResultTestDTO.ok(test.getFullName(processingManyFiles)))
	}

	override testsToRun(String _suiteName, WFile file, List<WTest> tests) {
		this.suiteName = _suiteName
		val fileURI = file.eResource.URI.toString
		if (processingManyFiles) {
			if (this.folder !== null) {
				this.suiteName = NLS.bind(Messages.ALL_TEST_IN_FOLDER, this.folder)
			} else {
				this.suiteName = Messages.ALL_TEST_IN_PROJECT
			}
			this.testFiles.addAll(getRunnedTestsInfo(tests, fileURI))
		} else {
			remoteTestNotifier.testsToRun(suiteName, fileURI, getRunnedTestsInfo(tests, fileURI), false)
		}
	}

	override testStart(WTest test) {
		// for better performance we avoid a RMI call
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		testsResult.add(
			WollokResultTestDTO.error(test.getFullName(processingManyFiles), exception.convertToString, exception.convertStackTrace, lineNumber,
				resource?.toString))
	}

	override finished() {
		if (!processingManyFiles) {
			remoteTestNotifier.testsResult(testsResult)
		}
	}

	override initProcessManyFiles(String folder) {
		this.processingManyFiles = true
		this.folder = folder
	}
	
	override endProcessManyFiles() {
		remoteTestNotifier => [
			testsToRun(suiteName, "", this.testFiles, true)
			testsResult(testsResult)
		]
		processingManyFiles = false
	}
	
	protected def List<WollokTestInfo> getRunnedTestsInfo(List<WTest> tests, String fileURI) {
		new ArrayList(tests.map[new WollokTestInfo(it, fileURI, processingManyFiles)])
	}
	
}
