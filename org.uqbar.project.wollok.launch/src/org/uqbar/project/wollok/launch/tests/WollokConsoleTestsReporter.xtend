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

import org.fusesource.jansi.Ansi

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

	public static int MIN_PERFORMANCE_TIME_ACCEPTED = 50
	public static int MAX_PERFORMANCE_TIME_ACCEPTED = 100
		
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
	
	new() {
		AnsiConsole.systemInstall
	}

	override folderStarted(String folder) {
		super.folderStarted(folder)
		this.resetTotalTestsCount
	}

	override testsToRun(String suiteName, WFile file, List<WTest> tests) {
		val fileSegments = file.eResource.URI.segments
		val filename = fileSegments.get(fileSegments.length - 1)
		if (suiteName ?: '' !== '') {
			println(ansi.bold.a('''Describe «suiteName» from «filename»''').reset)
		} else {
			println(ansi.bold.a('''Individual tests from «filename»''').reset)
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
		println(ansi.a("  ").bold.green("√ ").reset.gray(test.name).time(test.totalTime).reset)
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
	
	def resetTotalTestsCount() {
		totalTestsRun = 0
		totalTestsFailed = 0
		totalTestsErrored = 0
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
			.showStackTrace(assertionError, lineNumber, resource)
		)
	}
		
	def showStackTrace(Ansi ansi, AssertionException assertionError, int lineNumber, URI resource) {
		if ((resource === null) || lineNumber === 0) return ansi.reset
		return ansi.fg(YELLOW).a(" (").a(resource.trimFragment).a(":").a(lineNumber).a(")").reset
			.a("\n    ")
			.fg(YELLOW).a(assertionError.wollokException?.convertStackTrace.join("\n    ")).reset
			.a("\n")
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

	def green(Ansi ansi, String text) {
		ansi.displayInColor(text, GREEN)
	}
	
	def gray(Ansi ansi, String text) {
		ansi.displayInColor(text, WHITE)
	}
	
	def displayInColor(Ansi ansi, String text, Ansi$Color color) {
		ansi.fg(color).a(text).reset
	}
	
	def time(Ansi ansi, long time) {
		if (time > MAX_PERFORMANCE_TIME_ACCEPTED) return ansi.displayInColor(" (" + time + "ms)", RED)
		if (time >= MIN_PERFORMANCE_TIME_ACCEPTED && time < MAX_PERFORMANCE_TIME_ACCEPTED) return ansi.displayInColor(" (" + time + "ms)", YELLOW)
		ansi
	}

}

/**
 * Internal console for sanity tests in Eclipse/Xtext build - without colors
 */
class WollokSimpleConsoleTestsReporter extends WollokConsoleTestsReporter {
	
	new() {
		super()
		Ansi.setEnabled = false		
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