package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Singleton
import java.util.List
import java.util.Observable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.uqbar.project.wollok.ui.console.RunInUI
import wollok.lib.AssertionException

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier{
	
	@Accessors
	var WollokTestContainer container
	
	override assertError(String testName, AssertionException assertionException, int lineNumber, String resource) {
		testByName(testName).endedAssertError(assertionException, lineNumber, resource)
		
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
	
	override error(String testName, Exception exception, int lineNumber, String resource) {
		testByName(testName).endedError(exception, lineNumber, resource);
		
		this.setChanged
		this.notifyObservers		
	}
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
}
