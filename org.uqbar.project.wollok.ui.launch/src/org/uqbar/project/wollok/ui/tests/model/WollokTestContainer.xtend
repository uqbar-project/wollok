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
	
	def passed() {
		tests.forall [ test | test.state === WollokTestState.OK ]
	}
	
	def running() {
		tests.exists [ test | test.state === WollokTestState.RUNNING ]
	}
	
	def errored() {
		tests.exists [ test | test.state === WollokTestState.ERROR ]
	}
	
	def failed() {
		tests.exists [ test | test.state === WollokTestState.ASSERT ]
	}
	
	def getInternalImage() {
		if (running) {
			return "icons/describe_run" + themeSuffix + ".png"
		}
		if (errored) {
			return "icons/describe_error" + themeSuffix + ".png"
		}
		if (failed) {
			return "icons/describe_fail" + themeSuffix + ".png"
		}
		if (passed) {
			return "icons/describe_ok.png"
		}
		"icons/describe.png"
	}

	def getImage(){
		Activator.getDefault.getImageDescriptor(internalImage)
	}
	
	def void defineTests(List<WollokTestResult> tests, boolean shouldShowOnlyFailuresAndErrors) {
		this.allTests = tests
		filterTestByState(shouldShowOnlyFailuresAndErrors)
		this.tests.forEach [ test | test.started ]
	} 
	
	def testByName(String testName) {
		this.allTests.findFirst[name == testName]
	}
	
	def asText() {
		if (this.hasSuiteName) return this.suiteName
		this.mainResource.toIFile.projectRelativePath.toPortableString
	}
	
}