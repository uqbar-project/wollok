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
	
	new() {
		init
	}
	
	def void init() {
		allElements = newArrayList
		allMixins = newArrayList
	}

	def StaticDiagramBuilder addMixin(WMixin m) {
		if (!allMixins.map [ identifier ].contains(m.identifier)) {
			allMixins.add(m)
		}
		this
	}
		
	def StaticDiagramBuilder addElement(WMethodContainer m) {
		if (!allElements.map [ identifier ].contains(m.identifier)) {
			allElements.add(m)
			m.doAddElement
			m.mixins.forEach [ addMixin ]
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

	def StaticDiagramBuilder addClasses(List<WClass> classes) {
		classes.clone.forEach [ addElement ]
		this
	}

	def StaticDiagramBuilder addClasses(Iterable<WClass> classes) {
		addClasses(classes.toList)
	}

	def StaticDiagramBuilder addObjects(List<WNamedObject> objects) {
		objects.clone.forEach [ addElement ]
		this
	}

	def StaticDiagramBuilder addObjects(Iterable<WNamedObject> objects) {
		addObjects(objects.toList)
	}

	def StaticDiagramBuilder addMixins(List<WMixin> mixins) {
		mixins.forEach [ addMixin ]
		this
	}

	def StaticDiagramBuilder addMixins(Iterable<WMixin> mixins) {
		addMixins(mixins.toList)
	}
	
	def allElements() { allElements }
	
	def allMixins() { allMixins }
}