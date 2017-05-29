package org.uqbar.project.wollok.ui.diagrams.classes.model

import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension java.lang.Integer.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Common class for modeling
 * - classes
 * - named objects (wko)
 * - mixins
 * as a models of a static diagram
 * 
 * Main responsibilities includes: size & location of shapes and naming convention
 */
abstract class AbstractModel extends Shape {

	protected static List<WMethodContainer> allComponents = newArrayList
	protected static Map<Integer, Integer> levelHeight
	protected static Map<Integer, Integer> levelWidth
	protected static Map<String, Integer> initialWidthForElement
	
	protected val static LETTER_WIDTH = 8
	protected val static FILE_HEIGHT = 18
	protected val static HEIGHT_SEPARATION_BETWEEN_ELEMENTS = 20
	
	protected val static ELEMENT_WIDTH = 50
	protected val static MAX_ELEMENT_WIDTH = 230
	protected val static MAX_ELEMENT_HEIGHT = 280
	protected val static ELEMENT_HEIGHT = 55
	protected val static WIDTH_SEPARATION_BETWEEN_ELEMENTS = 20
	protected val static INITIAL_MARGIN = 5

	@Accessors protected WMethodContainer component

	new(WMethodContainer mc) {
		component = mc
		component.defineSize
	}
	
	static def void init(List<WMethodContainer> _classes) {
		levelHeight = newHashMap
		levelWidth = newHashMap
		initialWidthForElement = newHashMap
		allComponents = _classes
	}
	
	/**
	 * ******************************************************************************* 
	 *    WIDTH CALCULATIONS
	 * ******************************************************************************* 
	 */
	def defaultWidth() { 120 }
	
	def int getInitialWidth(WMethodContainer mc) {
		if (mc.parent === null) return 0
		val parentClassName = mc.parent.name ?: ""
		if (parentClassName.equals(WollokConstants.ROOT_CLASS)) return 0
		initialWidthForElement.get(parentClassName) ?: 0
	}
	
	def int shapeWidth(WMethodContainer mc) {
		Math.min(ELEMENT_WIDTH + (mc.allWidths.reduce [ a, b | a.max(b) ] * LETTER_WIDTH), MAX_ELEMENT_WIDTH)
	}
	
	def allWidths(WMethodContainer mc) {
		val result = newArrayList
		if (configuration.showVariables) {
			result.addAll(mc.variables.map [ it.name?.length ])
		}
		result.addAll(mc.methods.map [ it.name?.length ])
		result.add(mc.name.length)
		result
	}

	/**
	 * ******************************************************************************* 
	 *    HEIGHT CALCULATIONS
	 * ******************************************************************************* 
	 */
	def defaultHeight() { 130 }

	def int adjustedHeight() {
		NamedObjectModel.maxHeight()
	}

	def int shapeHeight(WMethodContainer mc) {
		Math.min((mc.variablesSize + mc.methods.size) * FILE_HEIGHT + ELEMENT_HEIGHT, MAX_ELEMENT_HEIGHT)
	}
	
	def int getVariablesSize(WMethodContainer mc) {
		if (configuration.showVariables) mc.variables.size else 0
	}

	/**
	 * ******************************************************************************* 
	 *    SIZE INITIALIZATION
	 * ******************************************************************************* 
	 */
	def void defineSize(WMethodContainer component) {
		size = configuration.getSize(this) ?: new Dimension(component.shapeWidth, component.shapeHeight)
	}

	def String getLabel() {
		this.name
	}

	/**
	 * ******************************************************************************* 
	 *    DOMAIN METHODS
	 * ******************************************************************************* 
	 */
	def getVariablesSize() {
		this.component.variablesSize
	}

	def getName() {
		component.name ?: "<...>"
	}
		
}
