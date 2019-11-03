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
	
	override testsToRun(List<String> fathersPath, String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles) {
		val suite = new WollokTestSuite
		suite.suiteName = suiteName
		suite.fathersPath = fathersPath
		suite.processingManyFiles = processingManyFiles
		suite.mainResource = URI.createURI(containerResource)
		suite.defineTests(newArrayList(tests.map[new WollokTestResult(it)]), this.shouldShowOnlyFailuresAndErrors)
		
		val fileContainer = globalContainer.getFileContainer(containerResource)
		fileContainer.processingManyFiles = processingManyFiles
		
		if(fathersPath !== null) {
			val suiteFather = fileContainer.getSuite(fathersPath)
			suiteFather.addChild(suite)
		} else {
			fileContainer.add(suite)	
		}
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
	
	def testByName(String file, String suiteName, String testName){
		globalContainer.testByName(file, suiteName, testName)
	}
		
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests, long millisecondsElapsed) {
		tests.forEach [
			val test = testByName(file, suiteName, testName)
			if (ok()) {
				test.endedOk(totalTime)
			}
			if (failure()) {
				test.endedAssertError(message, stackTrace, errorLineNumber, resource, totalTime)
			}
			if (error()) {
				test.endedError(message, stackTrace, errorLineNumber, resource, totalTime)
			}
		]		
		globalContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)
		globalContainer.millisecondsElapsed = millisecondsElapsed
		this.setChanged
		this.notifyObservers
	}
	
}