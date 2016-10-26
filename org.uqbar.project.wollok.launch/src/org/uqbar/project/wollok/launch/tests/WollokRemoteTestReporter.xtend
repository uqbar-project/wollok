package org.uqbar.project.wollok.launch.tests

import com.google.inject.Inject
import java.io.PrintWriter
import java.io.StringWriter
import java.util.ArrayList
import java.util.LinkedList
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

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

	@Inject
	def init() {
		client = new Client("localhost", parameters.testPort, callHandler)
		remoteTestNotifier = client.getGlobal(WollokRemoteUITestNotifier) as WollokRemoteUITestNotifier
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		testsResult.add(WollokResultTestDTO.assertionError(test.name, assertionError, lineNumber, resource?.toString))
	// remoteTestNotifier.assertError(test.name, assertionError, lineNumber, resource.toString)
	}

	override reportTestOk(WTest test) {
		testsResult.add(WollokResultTestDTO.ok(test.name))
	// remoteTestNotifier.testOk(test.name)
	}

	override testsToRun(WFile file, List<WTest> tests) {
		remoteTestNotifier.testsToRun(file.eResource.URI.toString, new ArrayList(tests.map[new WollokTestInfo(it)]))
	}

	override testStart(WTest test) {
		// remoteTestNotifier.testStart(test.name)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		testsResult.add(
			WollokResultTestDTO.error(test.name, exception.convertToString, exception.convertStackTrace, lineNumber,
				resource?.toString))
	// remoteTestNotifier.error(test.name, exception.convertToString, lineNumber, resource?.toString)
	}

	def dispatch String convertToString(Exception exception) {
		val sw = new StringWriter
		exception.printStackTrace(new PrintWriter(sw))
		sw.toString
	}

	def dispatch List<StackTraceElementDTO> convertStackTrace(Exception exception) {
		newArrayList
	}

	def dispatch List<StackTraceElementDTO> convertStackTrace(WollokProgramExceptionWrapper exception) {
		val stackTrace = exception.wollokException.call("getFullStackTrace").wollokToJava(List) as List<WollokObject>
		stackTrace.map [ wo |
			val contextDescription = wo.call("contextDescription").wollokToJava(String) as String
			val location = wo.call("location").wollokToJava(String) as String
			val data = location.split(",")
			val fileName = data.get(0)
			var Integer lineNumber = 0
			try {
				lineNumber = new Integer(data.get(1))
			} catch (NumberFormatException e) {
			}
			new StackTraceElementDTO(contextDescription, fileName, lineNumber)
		]
	}

	def dispatch List<StackTraceElementDTO> convertStackTrace(AssertionException exception) {
		exception.stackTrace.map [ ste |
			new StackTraceElementDTO(ste.methodName, ste.fileName, ste.lineNumber) 
		]
	}

	def dispatch String convertToString(WollokProgramExceptionWrapper exception) {
		val wollokException = exception.wollokException
		val className = wollokException.call("className").wollokToJava(String) as String
		val message = exception.wollokMessage
		val concatMessage = if (message != null) ": " + message else "" 
		return className + concatMessage
	}

	def dispatch void prepareExceptionForTrip(Throwable e) {
		if (e.cause != null)
			e.cause.prepareExceptionForTrip
	}

	def dispatch void prepareExceptionForTrip(WollokInterpreterException e) {
		e.sourceElement = null

		if (e.cause != null)
			e.cause.prepareExceptionForTrip
	}

	def dispatch void prepareExceptionForTrip(WollokProgramExceptionWrapper e) {
		e.URI = null
		if (e.cause != null)
			e.cause.prepareExceptionForTrip
	}

	override finished() {
		remoteTestNotifier.testsResult(testsResult)
	}

}
