package org.uqbar.project.wollok.tests.xpect

import org.eclipse.xtext.testing.InjectWith
import org.junit.runner.RunWith
import org.junit.runner.Runner
import org.junit.runner.notification.RunNotifier
import org.junit.runners.model.InitializationError
import org.xpect.runner.XpectRunner
import org.xpect.xtext.lib.tests.XtextTests
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import wollok.lang.WDate
import java.time.format.DateTimeFormatter

/**
 * @author jfernandes
 */
@RunWith(WollokXpectRunner)
@InjectWith(WollokTestInjectorProvider)
class WollokXPectTest extends XtextTests {
}

class WollokXpectRunner extends XpectRunner {
	new(Class<?> testClass) throws InitializationError {
		super(testClass)
		// This makes the Date string representation independent of the current user's locale
		WDate.FORMATTER = DateTimeFormatter.ofPattern("d/M/yy")
	}

	override runChild(Runner child, RunNotifier notifier) {
		super.runChild(child, notifier)
	}
}
