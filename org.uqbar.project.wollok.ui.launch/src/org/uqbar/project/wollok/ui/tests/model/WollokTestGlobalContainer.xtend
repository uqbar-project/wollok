package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.Messages
import org.uqbar.project.wollok.wollokDsl.WTest

@Accessors
public class WollokTestGlobalContainer {
	var List<WollokTestFileContainer> testFiles = new ArrayList
	var boolean processingManyFiles = false
	long millisecondsElapsed = 0

	def void add(WollokTestFileContainer container) {
		val alreadyExists = this.testFiles.exists [file|file.mainResource == container.mainResource]
		if (!alreadyExists) {
			testFiles.add(container)
		}
	}

	def String asText() {
		if (processingManyFiles) {
			return Messages.ALL_TEST_IN_PROJECT
		}
		return "Resultado de los test"
	}

	def hasTests() {
		return !testFiles.empty
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.testFiles.forEach[testFile|testFile.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}
	
	def noEmptyFiles () {
		testFiles.filter[ file | !file.noEmptyDescribes.isEmpty ]
	}

	def allTest() {
		val allTest = new ArrayList
		this.testFiles.forEach[file|allTest.addAll(file.allTest())]
		return allTest
	}
	def allContainers() {
		val allContainers = new ArrayList
		this.testFiles.forEach[file|allContainers.addAll(file.containers)]
		return allContainers
	}

	def allTest((WollokTestResult)=>Boolean predicate) {
		return allTest().filter(predicate)
	}

	def WollokTestResult testByName(String suiteName, String testName) {
		val WollokTestContainer container = allContainers.findFirst [ container | 
			 	container.suiteName == suiteName &&
			 	container.allTests.exists[ name == testName ]
		]
		container.allTests.findFirst[name == testName ]
	}
	
	def getProject(){
		this.testFiles.get(0).project
	}
	
	def getFileContainer(String filePath) {
		val mainResource = URI.createURI(filePath)
		val file = testFiles.findFirst[ file | file.mainResource == mainResource ]
		if(file === null){
			val fileContainer = new WollokTestFileContainer
			fileContainer.mainResource = mainResource
			return fileContainer
		}
		return file
	}
	
	def getParent(WollokTestContainer containerToFind){
		testFiles.findFirst [ file | file.containers.findFirst[ container | container == containerToFind ] !== null]
	}

}
