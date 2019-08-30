package org.uqbar.project.wollok.ui.tests.model

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

@Accessors
class WollokTestContainer {
	var String suiteName
	var URI mainResource
	var List<WollokTestResult> tests = newArrayList
	var List<WollokTestResult> allTests = newArrayList
	var boolean processingManyFiles = false
	long millisecondsElapsed = 0
	
	override toString(){
		mainResource.toString
	}
	
	def hasSuiteName() {
		suiteName !== null && !suiteName.isEmpty
	}
	
	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.tests = newArrayList(allTests.filter [ result | result.failed || !shouldShowOnlyFailuresAndErrors ])
	}
	
	def void defineTests(List<WollokTestResult> tests, boolean shouldShowOnlyFailuresAndErrors) {
		this.allTests.addAll(tests)
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