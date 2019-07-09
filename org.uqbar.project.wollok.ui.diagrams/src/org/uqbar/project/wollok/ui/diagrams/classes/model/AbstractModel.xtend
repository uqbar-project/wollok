package org.uqbar.project.wollok.ui.diagrams.classes.model

import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.StringUtils.*

/**
 * Common class for modeling
 * - classes
 * - named objects (wko)
 * - mixins
 * as models of a static diagram
 * 
 * Main responsibilities includes: size & location of shapes and naming convention
 */
abstract class AbstractModel extends Shape {

	@Accessors protected static List<WMethodContainer> allComponents = newArrayList
	protected static List<NamedObjectModel> objects
	protected static List<MixinModel> mixins
	
	protected static Map<Integer, Integer> levelHeight
	protected static Map<Integer, Integer> levelWidth
	protected static Map<String, Integer> initialWidthForElement
	
	protected val static LETTER_WIDTH = 8
	protected val static FILE_HEIGHT = 18
	protected val static HEIGHT_SEPARATION_BETWEEN_ELEMENTS = 20
	
	protected val static TOP_POSITION = 10
	protected val static DEFAULT_WIDTH = 120
	protected val static ELEMENT_WIDTH = 50
	protected val static MAX_ELEMENT_WIDTH = 230
	protected val static MAX_ELEMENT_HEIGHT = 300
	protected val static ELEMENT_HEIGHT = 55
	protected val static WIDTH_SEPARATION_BETWEEN_ELEMENTS = 20
	protected val static INITIAL_MARGIN = 5

	@Accessors protected WMethodContainer component
	List<WVariableDeclaration> variables
	List<WMethodDeclaration> methods

	new(WMethodContainer mc) {
		component = mc
		val selectedConfiguration = configuration as StaticDiagramConfiguration
		variables = selectedConfiguration.getVariablesFor(mc)
		methods = selectedConfiguration.getMethodsFor(mc)
		this.defineSize
	}
	
	static def void init(List<WMethodContainer> _classes) {
		levelHeight = newHashMap
		levelWidth = newHashMap
		initialWidthForElement = newHashMap
		allComponents = _classes
		mixins = newArrayList
		objects = newArrayList
	}
	
	def static List<WMethodContainer> allElements() {
		val List<WMethodContainer> allElements = allComponents
		allElements.addAll(mixins.map [ component ])
		allElements.addAll(objects.map [ component ])
		allElements
	}
	
	/**
	 * ******************************************************************************* 
	 *    WIDTH CALCULATIONS
	 * ******************************************************************************* 
	 */
	def defaultWidth() { DEFAULT_WIDTH }
	
	def int getInitialWidth() {
		if (component.parent === null) return 0
		val parentClass = component.parent.identifier ?: ""
		if (parentClass.equals(WollokConstants.ROOT_CLASS)) return 0
		initialWidthForElement.get(parentClass) ?: 0
	}
	
	def int shapeWidth() {
		Math.min(ELEMENT_WIDTH + (allWidths.reduce [ a, b | Math.max(a, b) ] * LETTER_WIDTH), MAX_ELEMENT_WIDTH)
	}
	
	def allWidths() {
		val result = newArrayList
		result.addAll(variables.map [ name.safeLength ])
		result.addAll(methods.map [ name.safeLength ])
		result.add(component.name.safeLength)
		result
	}

	/**
	 * ******************************************************************************* 
	 *    HEIGHT CALCULATIONS
	 * ******************************************************************************* 
	 */
	def defaultHeight() { 130 }

	def int shapeHeight() {
		Math.min((variablesSize + methodsSize) * FILE_HEIGHT + ELEMENT_HEIGHT, MAX_ELEMENT_HEIGHT)
	}
	
	/**
	 * ******************************************************************************* 
	 *    SIZE INITIALIZATION
	 * ******************************************************************************* 
	 */
	def void defineSize() {
		size = configuration.getSize(this) ?: new Dimension(shapeWidth, shapeHeight)
	}

	/**
	 * ******************************************************************************* 
	 *    DOMAIN METHODS
	 * ******************************************************************************* 
	 */
	def getMembers() {
		(variables + methods).toList
	}

	def getVariables() {
		variables
	}
	
	def getMethods() {
		methods	
	}
	
	def getVariablesSize() {
		variables.size
	}

	def getMethodsSize() {
		methods.size
	}

	def getName() {
		component.name ?: "<...>"
	}
		
	def String getLabel() {
		component.identifier
	}
	
	/**
	 * ******************************************************************************* 
	 *    EXTENSION METHODS - HEIGHT
	 * ******************************************************************************* 
	 */
	def static int maxHeight() {
		elements.fold(0, [ max, object | Math.max(max, object.size.height + TOP_POSITION) ])
	}

	def static getElements() {
		objects + mixins
	}
	
}
