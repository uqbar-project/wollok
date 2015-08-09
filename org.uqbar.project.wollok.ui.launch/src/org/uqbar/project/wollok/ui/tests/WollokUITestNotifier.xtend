package org.uqbar.project.wollok.ui.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier

class WollokUITestNotifier implements WollokRemoteUITestNotifier {
	def void assertError(String testName, String message, String expected, String actual, int lineNumber, String resource){
		println('''«testName»:«message»''')
	}

	def void testOk(String testName){
		println('''«testName»:Ok''')
	}

	def void testsToRun(List<String> testNames){
		println('''Tests to run:«testNames.join(", ")»''')
	}

	def void testStart(String testName){
		println('''Test Start: «testName»''')
	}
}