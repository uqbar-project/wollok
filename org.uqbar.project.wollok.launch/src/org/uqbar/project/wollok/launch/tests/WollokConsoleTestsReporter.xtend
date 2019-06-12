package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.fusesource.jansi.AnsiConsole
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
 */
class WollokConsoleTestsReporter implements WollokTestsReporter {

	override testsToRun(String suiteName, WFile file, List<WTest> tests) {
		AnsiConsole.systemInstall
		if (suiteName ?: '' !== '') {
			println('''Running all tests from suite «suiteName»''')
		} else {
			println('''Running «tests.size» tests...''')
		}
	}

	override testStart(WTest test) {}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		println(ansi
				.a("  ").fg(YELLOW).a(test.name).a(": ✗ FAILED => ")
				.a(assertionError.message)
				.a(" (").a(resource.trimFragment).a(":").a(lineNumber)
				.reset
				.a("\n    ")
				.a(assertionError.wollokException?.convertStackTrace.join("\n    "))
		)
	}

	override reportTestOk(WTest test) {
		println(ansi.a("  ").fg(GREEN).a(test.name).a(": √ (Ok)").reset)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		println(ansi.a("  ").fg(RED).a(test.name).a(": ✗ ERRORED => ")
			.a(exception.message)
			.a(" (").a(resource.trimFragment).a(":").a(lineNumber)
			.reset.a("\n    ").a(exception.convertStackTrace.join("\n    "))
		)
	}

	override finished() {
		AnsiConsole.systemUninstall
	}

	override initProcessManyFiles(String folder) {
	}
	
	override endProcessManyFiles() {
	}

}
