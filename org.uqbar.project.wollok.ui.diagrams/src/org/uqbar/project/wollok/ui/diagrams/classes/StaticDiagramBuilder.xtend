package org.uqbar.project.wollok.ui.diagrams.classes

import java.util.List
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * A Builder for collecting 
 * 
 * - hierarchy elements (classes, wko)
 * - mixins
 *
 * Avoids adding twice same element (class, wko, mixin)
 *  
 */
class StaticDiagramBuilder {
	
	List<WMethodContainer> allElements
	List<WMixin> allMixins
	List<WNamedObject> allSingleObjects
	
	new() {
		init
	}
	
	def void init() {
		allElements = newArrayList
		allMixins = newArrayList
		allSingleObjects = newArrayList
	}

	def dispatch StaticDiagramBuilder addElements(List<? extends WMethodContainer> elements) {
		elements.clone.forEach [ element | addElement(element) ]
		this
	}

	def dispatch StaticDiagramBuilder addElements(Iterable<? extends WMethodContainer> elements) {
		addElements(elements.toList)
	}

	def dispatch StaticDiagramBuilder addElement(WMixin m) {
		if (!allMixins.map [ identifier ].contains(m.identifier)) {
			allMixins.add(m)
		}
		this
	}
	
	def dispatch void addToRightCollection(WNamedObject o) {
		if (o.hasRealParent) {
			allElements.add(o)
		} else {
			allSingleObjects.add(o)
		}
	}

	def dispatch void addToRightCollection(WMethodContainer mc) {
		allElements.add(mc)
	}
	
	def dispatch StaticDiagramBuilder addElement(WMethodContainer m) {
		if (!allElements.map [ identifier ].contains(m.identifier)) {
			m.addToRightCollection
			m.doAddElement
			m.mixins.forEach [ addElement ]
		}
		this
	}
	
	def dispatch void doAddElement(WClass c) {
		c.superClassesIncludingYourself.forEach [ addElement ]
	}

	def dispatch void doAddElement(WNamedObject o) {
		val parent = o.parent
		if (parent !== null) {
			parent.superClassesIncludingYourself.forEach [ addElement ]
		}
	}

	def allElements() { allElements }
	
	def allMixins() { allMixins }
	
	def allSingleObjects() { allSingleObjects }
}