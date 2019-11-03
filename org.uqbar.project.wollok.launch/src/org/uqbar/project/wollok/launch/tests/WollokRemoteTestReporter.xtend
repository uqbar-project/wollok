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

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * WollokTestReporter implementation that sends the event to a remote
 * WollokRemoteUITestNotifier instance.
 * 
 * It uses RMI to communicate with another process (the UI)
 * 
 * @author tesonep
 * @author dodain     Extracted common behavior with console test reporter and added performance measurement
 * 
 */
class WollokRemoteTestReporter extends DefaultWollokTestsReporter {

	@Inject
	var WollokLauncherParameters parameters

	Client client
	var callHandler = new CallHandler
	WollokRemoteUITestNotifier remoteTestNotifier
	val testsResult = new LinkedList<WollokResultTestDTO>

	// TODO: Is a temporary variable, we should refactor and add a grouping WollokTestInfo
	String suiteName
	String suiteFatherName

	List<WollokTestInfo> testFiles

	@Inject
	def init() {
		client = new Client("localhost", parameters.testPort, callHandler)
		remoteTestNotifier = client.getGlobal(WollokRemoteUITestNotifier) as WollokRemoteUITestNotifier
		testFiles = newArrayList
	}

	override reportTestAssertError(WTest test, AssertionException assertionException, int lineNumber, URI resource) {
		test.testFinished
		val file = test.file.URI.toString
		val wollokResultDTO = WollokResultTestDTO.assertionError(
			file,
			suiteName,
			test.getFullName(processingManyFiles),
			assertionException.message,
			assertionException.wollokException?.convertStackTrace,
			lineNumber,
			resource?.toString
		) => [totalTime = test.totalTime]
		testsResult.add(wollokResultDTO)
	}

	override reportTestOk(WTest test) {
		test.testFinished
		val file = test.file.URI.toString
		val wollokResultDTO = WollokResultTestDTO.ok(file, suiteName, test.getFullName(processingManyFiles)) => [
			totalTime = test.totalTime
		]
		testsResult.add(wollokResultDTO)
	}

	override testsToRun(String _suiteName, WFile file, List<WTest> tests) {
		this.suiteName = _suiteName
		val fileURI = file.eResource.URI.toString
		remoteTestNotifier.testsToRun(null, suiteName, fileURI, getRunnedTestsInfo(tests, fileURI), processingManyFiles)
	}

	override testsToRun(List<String> fathersPath, String suiteName, WFile file, List<WTest> tests) {
		// this.suiteFatherName = suiteFatherName
		val fileURI = file.eResource.URI.toString
		remoteTestNotifier.testsToRun(fathersPath, suiteName, fileURI, getRunnedTestsInfo(tests, fileURI),
			processingManyFiles)

	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		test.testFinished
		val file = test.file.URI.toString
		val wollokResultDTO = WollokResultTestDTO.error(file, suiteName, test.getFullName(processingManyFiles),
			exception.convertToString, exception.convertStackTrace, lineNumber, resource?.toString) => [
			totalTime = test.totalTime
		]
		testsResult.add(wollokResultDTO)
	}

	override finished() {
		super.finished
		remoteTestNotifier.testsResult(testsResult, overallTimeElapsedInMilliseconds)
	}

	protected def List<WollokTestInfo> getRunnedTestsInfo(List<WTest> tests, String fileURI) {
		new ArrayList(tests.map [ test |
			new WollokTestInfo(test, fileURI, processingManyFiles)
		])
	}

	override started() {
		super.started
		remoteTestNotifier.start()
	}

}
