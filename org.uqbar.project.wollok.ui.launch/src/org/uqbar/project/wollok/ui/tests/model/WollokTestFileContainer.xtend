package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator

@Accessors
class WollokTestFileContainer {
	var List<WollokTestContainer> containers = new ArrayList
	var URI mainResource
	var boolean processingManyFiles = false

	def void add(WollokTestContainer container) {
		containers.add(container)
	}

	def String asText() {
		return mainResource.lastSegment
	}

	def testByName(String testName) {
		allTest.findFirst[name == testName]
	}

	def allTest() {
		val allTest = new ArrayList
		var unFlattedTests = this.containers.map[container|container.tests]
		unFlattedTests.forEach[tests|allTest.addAll(tests)]
		return allTest
	}

	def allTestSize() {
		return this.allTest().size()
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return allTest().filter(predicate).size
	}	

	def hasTests() {
		this.containers.size >= 1
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.containers.forEach[container|container.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}
	
	def getProject(){
		this.containers.get(0).project
	}
	
	def allTestsOk(){
		val allContainers = containers.filter[ container | container.isAllTestsOk ]
		return allContainers.size === containers.size
	}
	
	def isAnyRunning(){
		return containers.findFirst[ container | container.isAnyRunning ] !== null
	}
	
	def isAnyWithError(){
		return containers.findFirst[ container | container.isAnyWithError ] !== null
	}
	
	def isAnyWithFail(){
		return containers.findFirst[ container | container.isAnyWithFail ] !== null
	}
	
	def getImage(){
		var icon = "icons/wollok-icon-test_16.png"
		if(isAnyRunning){
			icon = "icons/wollok-icon-testrun_16.png"
		}
		if(isAnyWithError){
			icon = "icons/wollok-icon-testerr_16.png"
		}
		if(isAnyWithFail){
			icon = "icons/wollok-icon-testfail_16.png"
		}
		if(allTestsOk){
			icon = "icons/wollok-icon-testok_16.png"
		}
		return Activator.getDefault.getImageDescriptor(icon)
	}

}
