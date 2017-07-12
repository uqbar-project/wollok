package org.uqbar.project.wollok.ui.tests.model

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import org.eclipse.core.resources.ResourcesPlugin

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
		val base = URI.createURI(ResourcesPlugin.getWorkspace.root.locationURI.toString + "/")
		this.mainResource.deresolve(base).toFileString
	}
	
}