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
import org.uqbar.project.wollok.launch.tests.WollokResultTestDTO

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier { 
	
	@Accessors
	var WollokTestContainer container
	
	override assertError(String testName, AssertionException assertionException, int lineNumber, String resource) {
		testByName(testName).endedAssertError(assertionException, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers
	}

	override testOk(String testName) {
		testByName(testName).endedOk()

		this.setChanged
		this.notifyObservers
	}
	
	override testsToRun(String containerResource, List<WollokTestInfo> tests) {
		this.container = new WollokTestContainer
		this.container.mainResource = URI.createURI(containerResource)
		this.container.tests = newArrayList(tests.map[new WollokTestResult(it)])
		this.container.tests.forEach [ test | testStart(test.name) ]
		
		this.setChanged
		this.notifyObservers		
	}

	override testStart(String testName) {
		testByName(testName).started()

		this.setChanged
		this.notifyObservers
	}

	def testByName(String testName){
		this.container.tests.findFirst[name == testName]
	}
	
	override error(String testName, String exceptionAsString, int lineNumber, String resource) {
		testByName(testName).endedError(exceptionAsString, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers		
	}
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests) {
		tests.forEach [ 
			val test = testByName(it.testName)
			if (it.ok()) {
				test.endedOk()
			}
			if (it.failure()) {
				test.endedAssertError(it.assertionException, it.errorLineNumber, it.resource)
			}
			if (it.error()) {
				test.endedError(it.exceptionAsString, it.errorLineNumber, it.resource)
			}
		]

		this.setChanged
		this.notifyObservers
	}
	
}