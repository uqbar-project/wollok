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
class WollokConsoleTestsReporter extends DefaultWollokTestsReporter {

	boolean processingManyFiles = false
	long startTime = 0
	long startGroupTime = 0
	int totalTestsRun = 0
	int totalTestsFailed = 0
	int totalTestsErrored = 0
	int testsGroupRun = 0
	int testsGroupFailed = 0
	int testsGroupErrored = 0
	int testsFailed = 0
	int testsErrored = 0
	int testsRun = 0
	
	override testsToRun(String suiteName, WFile file, List<WTest> tests, boolean reset) {
		AnsiConsole.systemInstall
		if (suiteName ?: '' !== '') {
			println('''Running all tests from describe «suiteName»''')
		} else {
			println('''Running «tests.size» test«if (tests.size !== 1) "s"»...''')
		}
		testsRun += tests.size
		testsGroupRun += tests.size
		totalTestsRun += tests.size
		if (reset) {
			resetTestsCount
		}
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		test.testFinished
		incrementTestsFailed
		println(ansi
				.a("  ").fg(YELLOW).a(test.name).a(": ✗ FAILED (").a(test.totalTime).a("ms) => ").reset
				.fg(YELLOW).a(assertionError.message).reset
				.fg(YELLOW).a(" (").a(resource.trimFragment).a(":").a(lineNumber).a(")").reset
				.a("\n    ")
				.fg(YELLOW).a(assertionError.wollokException?.convertStackTrace.join("\n    ")).reset
				.a("\n")
		)
	}
	
	override reportTestOk(WTest test) {
		test.testFinished
		println(ansi.a("  ").fg(GREEN).a(test.name).a(": √ OK (").a(test.totalTime).a("ms)").reset)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		test.testFinished
		incrementTestsErrored
		println(ansi.a("  ").fg(RED).a(test.name).a(": ✗ ERRORED (").a(test.totalTime).a("ms) => ").reset
			.fg(RED).a(exception.convertToString).reset
			.a("\n    ").fg(RED).a(exception.convertStackTrace.join("\n    ")).reset
			.a("\n")
		)
	}

	override finished() {
		val millisecondsElapsed = System.currentTimeMillis - startGroupTime
		printTestsResults(testsGroupRun, testsGroupFailed, testsGroupErrored, millisecondsElapsed)
		resetGroupTestsCount
		if (testsGroupFailed + testsGroupErrored > 0 && !processingManyFiles) throw new WollokTestsFailedException
	}

	override initProcessManyFiles(String folder) {
		processingManyFiles = true
		startTime = System.currentTimeMillis
		resetTestsCount
		resetGroupTestsCount
	}
	
	override endProcessManyFiles() {
		this.printTestsResults(totalTestsRun, totalTestsFailed, totalTestsErrored, System.currentTimeMillis - startTime)
		if (!overallProcessWasOK) throw new WollokTestsFailedException
	}

	def resetTestsCount() {
		testsFailed = 0
		testsErrored = 0
		testsRun = 0
	}

	def resetGroupTestsCount() {
		testsGroupRun = 0
		testsGroupFailed = 0
		testsGroupErrored = 0
	}
	
	def incrementTestsFailed() {
		testsFailed++
		testsGroupFailed++
		totalTestsFailed++
	}

	def incrementTestsErrored() {
		testsErrored++
		testsGroupErrored++
		totalTestsErrored++
	}
	
	def overallProcessWasOK() {
		testsGroupFailed + testsGroupErrored === 0
	}
	
	override start() {
		startGroupTime = System.currentTimeMillis
	}
	
	def printTestsResults(int totalTests, int failedTests, int erroredTests, long millisecondsElapsed) {
		val STATUS = if (failedTests + erroredTests === 0) GREEN else RED
		println(ansi
			.fg(STATUS)
			.bold
			.a(totalTests).a(if (totalTests == 1) " test, " else " tests, ")
			.a(failedTests).a(if (failedTests == 1) " failure and " else " failures and ")
			.a(erroredTests).a(if (erroredTests == 1) " error" else " errors")
			.a("\n")
			.a("Total time: ").a(millisecondsElapsed).a("ms")
			.a("\n")
			.reset
		)
		AnsiConsole.systemUninstall
	}
}
