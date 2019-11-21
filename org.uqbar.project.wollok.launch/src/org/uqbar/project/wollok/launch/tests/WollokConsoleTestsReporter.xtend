package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.fusesource.jansi.AnsiConsole
import org.uqbar.project.wollok.interpreter.WollokTestsFailedException
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.utils.StringUtils.*

/**
 * Logs the events to the console output.
 * Used when running the tests from console without a remote client program (RMI)
 * like eclipse UI.
 * 
 * @author tesonep
 * @author dodain   Added performance measurement & extract common behavior
 *
 */
class WollokConsoleTestsReporter extends DefaultWollokTestsReporter {

	int totalTestsRun = 0
	int totalTestsFailed = 0
	int totalTestsErrored = 0
	int testsGroupRun = 0
	int testsGroupFailed = 0
	int testsGroupErrored = 0
	int testsFailed = 0
	int testsErrored = 0
	int testsRun = 0
	List<WTestFailed> reportTestsFailed = newArrayList

	public static String FINAL_SEPARATOR = "====================================================================================================="
		
	override testsToRun(String suiteName, WFile file, List<WTest> tests) {
		AnsiConsole.systemInstall
		if (suiteName ?: '' !== '') {
			println('''Running all tests from describe «suiteName»''')
		} else {
			println('''Running «tests.size.singularOrPlural("test")» ...''')
		}
		testsRun += tests.size
		testsGroupRun += tests.size
		totalTestsRun += tests.size
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		test.testFinished
		incrementTestsFailed
		test.printAssertionException(assertionError, lineNumber, resource)
		reportTestsFailed.add(new WTestFailed(test, assertionError, null, lineNumber, resource))
	}
	
	override reportTestOk(WTest test) {
		test.testFinished
		println(ansi.a("  ").fg(GREEN).a(test.name).a(": √ OK (").a(test.totalTime).a("ms)").reset)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		test.testFinished
		incrementTestsErrored
		test.printException(exception, lineNumber, resource)
		reportTestsFailed.add(new WTestFailed(test, null, exception, lineNumber, resource))
	}

	override finished() {
		super.finished

		val ok = overallProcessWasOK
		ok.printSeparator
		val STATUS = if (ok) GREEN else RED
		println(ansi
			.fg(STATUS)
			.bold
			.a("FINAL REPORT")
			.reset
		)
		if (!ok) {
			printTestsFailed
		}
		println()
		printTestsResults(totalTestsRun, totalTestsFailed, totalTestsErrored, overallTimeElapsedInMilliseconds)
		println()
		ok.printSeparator
		
		resetGroupTestsCount
		if (!ok) throw new WollokTestsFailedException
	}

	override groupStarted(String groupName) {
		super.groupStarted(groupName)
		resetTestsCount
		resetGroupTestsCount
	}
	
	override groupFinished(String groupName) {
		super.groupFinished(groupName)
		printTestsResults(testsGroupRun, testsGroupFailed, testsGroupErrored, groupTimeElapsedInMilliseconds)
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
		totalTestsFailed + totalTestsErrored === 0
	}
	
	def printTestsResults(int totalTests, int failedTests, int erroredTests, long millisecondsElapsed) {
		val STATUS = if (failedTests + erroredTests === 0) GREEN else RED
		println(ansi
			.fg(STATUS)
			.bold
			.a(totalTests.singularOrPlural("test")).a(", ")
			.a(failedTests.singularOrPlural("failure")).a(" and ")
			.a(erroredTests.singularOrPlural("error"))
			.a("\n")
			.a("Total time: ").a(millisecondsElapsed).a("ms")
			.a("\n")
			.reset
		)
		AnsiConsole.systemUninstall
	}
	
	private def printAssertionException(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		println(ansi
			.a("  ").fg(YELLOW).a(test.name).a(": ✗ FAILED (").a(test.totalTime).a("ms) => ").reset
			.fg(YELLOW).a(assertionError.message).reset
			.fg(YELLOW).a(" (").a(resource.trimFragment).a(":").a(lineNumber).a(")").reset
			.a("\n    ")
			.fg(YELLOW).a(assertionError.wollokException?.convertStackTrace.join("\n    ")).reset
			.a("\n")
		)
	}
	
	private def printException(WTest test, Exception exception, int lineNumber, URI resource) {
		println(ansi.a("  ").fg(RED).a(test.name).a(": ✗ ERRORED (").a(test.totalTime).a("ms) => ").reset
			.fg(RED).a(exception.convertToString).reset
			.a("\n    ").fg(RED).a(exception.convertStackTrace.join("\n    ")).reset
			.a("\n")
		)
	}

	private def printSeparator(boolean ok) {
		val STATUS = if (ok) GREEN else RED
		println(ansi
			.fg(STATUS)
			.bold
			.a(FINAL_SEPARATOR)
			.a("\n")
			.reset
		)
	}

	private def printTestsFailed() {
		println(ansi
			.fg(RED)
			.a("\n")
		)
		reportTestsFailed.forEach [
			if (assertionOrigin) test.printAssertionException(assertionException, lineNumber, resource)
			else test.printException(exception, lineNumber, resource)
		]
	}

}

@Accessors
@Data
class WTestFailed {
	WTest test
	AssertionException assertionException
	Exception exception
	int lineNumber
	URI resource
	
	def isAssertionOrigin() {
		assertionException !== null
	}
}