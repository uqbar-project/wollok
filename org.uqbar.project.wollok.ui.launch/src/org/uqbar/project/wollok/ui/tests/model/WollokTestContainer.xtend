package org.uqbar.project.wollok.ui.tests.model

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

@Accessors
class WollokTestContainer {
	var String suiteName
	var URI mainResource
	var List<WollokTestResult> tests = newArrayList
	var List<WollokTestResult> allTests = newArrayList
	var boolean processingManyFiles = false
	
	override toString(){
		mainResource.toString
	}
	
	def hasSuiteName() {
		suiteName !== null && !suiteName.isEmpty
	}
	
	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.tests = newArrayList(allTests.filter [ result | result.failed || !shouldShowOnlyFailuresAndErrors ])
	}
	
	def isAllTestsOk(){
		val allTestsOk = tests.filter[ test | test.state === WollokTestState.OK ]
		return allTestsOk.size === tests.size
	}
	
	def isAnyRunning(){
		return tests.findFirst[ test | test.state === WollokTestState.RUNNING ] !== null
	}
	
	def isAnyWithError(){
		return tests.findFirst[ test | test.state === WollokTestState.ERROR ] !== null
	}
	
	def isAnyWithFail(){
		return tests.findFirst[ test | test.state === WollokTestState.ASSERT ] !== null
	}
	
	def getImage(){
		var icon = "icons/suite.png"
		if(isAnyRunning){
			icon = "icons/suiterun.png"
		}
		if(isAnyWithError){
			icon = "icons/suiteerr.png"
		}
		if(isAnyWithFail){
			icon = "icons/suitefail.png"
		}
		if(allTestsOk){
			icon = "icons/suiteok.png"
		}
		return Activator.getDefault.getImageDescriptor(icon)
	}
	
	def void defineTests(List<WollokTestResult> tests, boolean shouldShowOnlyFailuresAndErrors) {
		this.allTests = tests
		filterTestByState(shouldShowOnlyFailuresAndErrors)
		this.tests.forEach [ test | test.started ]
	} 
	
	def testByName(String testName) {
		this.allTests.findFirst[name == testName]
	}
	
	def getProject() {
		if (this.allTests.empty) return null
		this.allTests.head.testResource.toIFile.project
	}
	
	def asText() {
		if (this.hasSuiteName) return this.suiteName
		this.mainResource.toIFile.projectRelativePath.toPortableString
	}
	
}