package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class WollokTestSuperContainer {
	var List<WollokTestContainer> containers = new ArrayList
	var URI mainResource
	
	def void add(WollokTestContainer container) {
		containers.add(container)
	}

	def String asText() {
		return mainResource.lastSegment
	}

	def allTestSize() {
		return this.containers.map[container|container.tests.size].fold(0)[seed, container|seed + container]
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return this.containers.map[container|container.tests.filter(predicate).size].fold(0) [seed, container|
			seed + container
		]
	}

	def long getMillisecondsElapsed() {
		return containers.fold(0l)[seed, container|container.millisecondsElapsed + seed]
	}
	
	def hasTests() {
		this.containers.size >= 1
	}

}
