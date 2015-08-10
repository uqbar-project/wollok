package org.uqbar.project.wollok.ui.tests

import java.util.List
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier

class WollokUITestNotifier implements WollokRemoteUITestNotifier {
	override void assertError(String testName, String message, String expected, String actual, int lineNumber, String resource){
		println('''«testName»:«message»''')
	}

	override void testOk(String testName){
		println('''«testName»:Ok''')
	}

	override void testsToRun(List<String> testNames){
		println('''Tests to run:«testNames.join(", ")»''')
	}

	override void testStart(String testName){
		println('''Test Start: «testName»''')
	}
}