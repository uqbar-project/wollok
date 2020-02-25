package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.Messages

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

@Accessors
class WollokTestGlobalContainer {
	var List<WollokTestFileContainer> testFiles = new ArrayList
	var boolean processingManyFiles = false
	long millisecondsElapsed = 0

	def void add(WollokTestFileContainer container) {
		val alreadyExists = this.testFiles.exists[file|file.mainResource == container.mainResource]
		if (!alreadyExists) {
			testFiles.add(container)
		}
	}

	def String asText() {
		if (processingManyFiles) {
			return Messages.ALL_TEST_IN_PROJECT
		}
		return Messages.TEST_RESULTS
	}

	def hasTests() {
		return !testFiles.empty
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.testFiles.forEach[testFile|testFile.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}

	def noEmptyFiles() {
		testFiles.filter[file|!file.noEmptyDescribes.isEmpty]
	}

	def getAllTests() {
		this.testFiles.flatMap [ allTests ]
	}

	def allTestsMatching((WollokTestResult)=>Boolean predicate) {
		return allTests.filter(predicate)
	}

	def WollokTestResult testByName(String file, String suiteName, String testName) {
		if (suiteName !== null) {
			testFiles
				.filter [testFile | testFile.fileName.equals(file) ]
				.flatMap [ containers ]
				.findFirst [ container | container.suiteName.equals(suiteName) ]
				.allTests
				.findFirst [ test | test.name == testName ]
		} else {
			testFiles
				.findFirst [testFile | testFile.fileName.equals(file) ]
				.allTests
				.findFirst [ test | test.name == testName ] 
		}
			
	}

	def getProject() {
		this.testFiles.get(0).project
	}

	def getFileContainer(String filePath) {
		val mainResource = URI.createURI(filePath)
		val file = testFiles.findFirst[file|file.mainResource == mainResource]
		if (file === null) {
			val fileContainer = new WollokTestFileContainer
			fileContainer.mainResource = mainResource
			return fileContainer
		}
		return file
	}

	def getParent(WollokTestContainer containerToFind) {
		testFiles.findFirst[file|file.containers.findFirst[container|container == containerToFind] !== null]
	}

	override toString() {
		"[" + testFiles.join(", ") + "]"
	}
	
}
