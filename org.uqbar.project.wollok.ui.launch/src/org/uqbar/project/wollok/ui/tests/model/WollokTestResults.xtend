package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Singleton
import java.util.List
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Observable
import org.uqbar.project.wollok.ui.console.RunInUI
import org.eclipse.emf.common.util.URI

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier{
	
	@Accessors
	var WollokTestContainer container
	
	override assertError(String testName, String message, String expected, String actual, int lineNumber, String resource) {
		testByName(testName).endedAssertError(message, expected, actual, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers
	}

	override testOk(String testName) {
		testByName(testName).endedOk();

		this.setChanged
		this.notifyObservers		
	}
	
	override testsToRun(String containerResource, List<WollokTestInfo> tests) {
		this.container = new WollokTestContainer
		this.container.mainResource = URI.createURI(containerResource)
		this.container.tests = newArrayList(tests.map[new WollokTestResult(it)])
		
		this.setChanged
		this.notifyObservers		
	}

	override testStart(String testName) {
		testByName(testName).started();

		this.setChanged
		this.notifyObservers				
	}

	def testByName(String testName){
		this.container.tests.findFirst[name == testName]
	}
	
	override error(String testName, String message, int lineNumber, String resource) {
		testByName(testName).endedError(message, lineNumber, resource);
		
		this.setChanged
		this.notifyObservers		
	}
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
}
