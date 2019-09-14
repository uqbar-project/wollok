package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.fusesource.jansi.AnsiConsole
import org.uqbar.project.wollok.interpreter.WollokTestsFailedException
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

import static extension org.uqbar.project.wollok.utils.StringUtils.*
import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

/**
 * Logs the events to the console output.
 * Used when running the tests from console without a remote client program (RMI)
 * like eclipse UI.
 * 
 * @author tesonep
 * @author dodain
 * 
 */
class WollokConsoleTestsReporter implements WollokTestsReporter {

	int testsFailed = 0
	int testsErrored = 0
	int totalTests = 0
	
	override testsToRun(String suiteName, WFile file, List<WTest> tests) {
		AnsiConsole.systemInstall
		totalTests = tests.size
		if (suiteName ?: '' !== '') {
			println('''Running all tests from suite «suiteName»''')
		} else {
			println('''Running «totalTests» tests...''')
		}
		resetTestsCount
	}

	override testStart(WTest test) {}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		incrementTestsFailed
		println(ansi
				.a("  ").fg(YELLOW).a(test.name).a(": ✗ FAILED => ").reset
				.fg(YELLOW).a(assertionError.message).reset
				.fg(YELLOW).a(" (").a(resource.trimFragment).a(":").a(lineNumber).a(")").reset
				.a("\n    ")
				.fg(YELLOW).a(assertionError.wollokException?.convertStackTrace.join("\n    ")).reset
				.a("\n")
		)
	}
	
	override reportTestOk(WTest test) {
		println(ansi.a("  ").fg(GREEN).a(test.name).a(": √ (Ok)").reset)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		incrementTestsErrored
		println(ansi.a("  ").fg(RED).a(test.name).a(": ✗ ERRORED => ").reset
			.fg(RED).a(exception.convertToString).reset
			.a("\n    ").fg(RED).a(exception.convertStackTrace.join("\n    ")).reset
			.a("\n")
		)
	}

	override finished(long millisecondsElapsed) {
		val STATUS = if (processWasOK) GREEN else RED
		println(ansi
			.fg(STATUS)
			.bold
			.a(totalTests).a(" tests, ")
			.a(testsFailed).a(if (testsFailed == 1) " failure and " else " failures and ")
			.a(testsErrored).a(if (testsErrored == 1) " error" else " errors")
			.a("\n")
			.a("Total time: ").a(millisecondsElapsed.asSeconds).a(" seconds")
			.a("\n")
			.reset
		)
		AnsiConsole.systemUninstall
		if (!processWasOK) {
			throw new WollokTestsFailedException
		}
	}

	override initProcessManyFiles(String folder) {}
	
	override endProcessManyFiles() {}

	def resetTestsCount() {
		testsFailed = 0
		testsErrored = 0	
	}
	
	def incrementTestsFailed() {
		testsFailed++
	}

	def incrementTestsErrored() {
		testsErrored++
	}
	
	def processWasOK() {
		testsFailed + testsErrored === 0
	}
	
	override startFile(WFile file) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override start(WFile file) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}
