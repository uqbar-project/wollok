package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Singleton
import java.util.List
import java.util.Observable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokResultTestDTO
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.uqbar.project.wollok.ui.console.RunInUI

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier { 

	boolean shouldShowOnlyFailuresAndErrors = false
		
	@Accessors
	var WollokTestGlobalContainer globalContainer = new WollokTestGlobalContainer
	
	override start(){
		globalContainer = new WollokTestGlobalContainer
	}
	
	override testsToRun(String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles) {
		val container = new WollokTestContainer
		container.suiteName = suiteName
		container.processingManyFiles = processingManyFiles
		container.mainResource = URI.createURI(containerResource)
		container.defineTests(newArrayList(tests.map[new WollokTestResult(it)]), this.shouldShowOnlyFailuresAndErrors)
		
		val fileContainer = globalContainer.getFileContainer(containerResource)
		fileContainer.processingManyFiles = processingManyFiles
		fileContainer.add(container)
		globalContainer.add(fileContainer)
		globalContainer.processingManyFiles = processingManyFiles
		
		this.setChanged
		this.notifyObservers("testReceived")		
	}
	
	override showFailuresAndErrorsOnly(boolean showFailuresAndErrors) {
		this.shouldShowOnlyFailuresAndErrors = showFailuresAndErrors
		this.globalContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)

		this.setChanged
		this.notifyObservers("testsEnded")		
	}

	
	def testByName(String suiteName, String testName){
		globalContainer.testByName(suiteName, testName)
	}
		
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests, long millisecondsElapsed) {
		tests.forEach [
			val test = testByName(suiteName, testName)
			if (ok()) {
				test.endedOk()
			}
			if (failure()) {
				test.endedAssertError(message, stackTrace, errorLineNumber, resource)
			}
			if (error()) {
				test.endedError(message, stackTrace, errorLineNumber, resource)
			}
		]		
		globalContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)
		globalContainer.millisecondsElapsed = millisecondsElapsed
		this.setChanged
		this.notifyObservers
	}
	
	
	

}