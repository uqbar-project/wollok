package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

@Accessors
class WollokTestFileContainer {
	var List<WollokTestSuite> containers = new ArrayList
	var URI mainResource
	var boolean processingManyFiles = false

	def void add(WollokTestSuite containerToAdd) {
		containers.add(containerToAdd)
	}

	def void addToFather(String suiteName) {
	}

	def String asText() {
		return mainResource.lastSegment
	}

	def testByName(String testName) {
		allTests.findFirst[name == testName]
	}

	def getAllTests() {
		this.containers.flatMap[allTests]
	}

	def allTestSize() {
		return this.allTests.size()
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return allTests.filter(predicate).size
	}

	def hasTests() {
		this.containers.size >= 1
	}

	def getNoEmptyDescribes() {
		val suitesWithName = containers.filter[suiteName !== null]
		if (suitesWithName.isEmpty) {
			return containers.head.tests
		}
		return containers.filter[container|!container.isEmpty]

	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.containers.forEach[container|container.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}

	def IProject getProject() {
		val path = new Path(mainResource.toFileString)
		ResourcesPlugin.workspace.root.getFileForLocation(path).project
	}

	def passed() {
		containers.forall[passed]
	}

	def running() {
		containers.exists[running]
	}

	def errored() {
		containers.exists[errored]
	}

	def failed() {
		containers.exists[failed]
	}

	def String getInternalImage() {
		if (running) {
			return "icons/wollok-icon-testrun_16.png"
		}
		if (errored) {
			return "icons/wollok-icon-testerr_16.png"
		}
		if (failed) {
			return "icons/wollok-icon-testfail_16.png"
		}
		if (passed) {
			return "icons/wollok-icon-testok_16.png"
		}
		"icons/wollok-icon-test_16.png"
	}

	def getImage() {
		Activator.getDefault.getImageDescriptor(internalImage)
	}

	def fileName() {
		if(mainResource !== null) mainResource.toString else ""
	}

	override toString() {
		"[" + allTests.map[name].join(",") + "]"
	}
	
	def getSuite(List<String> pathToSuite) {
		var suite = findSuiteByName(pathToSuite.head, containers)
		pathToSuite.drop(1).fold(suite)[currentSuite, path|
			val foundPath = findSuiteByName(path, currentSuite.containers)
			foundPath
		]
	}
	
	def findSuiteByName(String suiteName, List<WollokTestSuite> suites) {
		suites.findFirst[suite|suite.suiteName == suiteName]
	}
	
	def List<WollokTestSuite> containerAndAllChildrenOf(WollokTestSuite suite) {
		val suites = new ArrayList()
		suites.add(suite)
		suites.addAll(suite.containers.flatMap[container|containerAndAllChildrenOf(container)])
		suites
	}

}
