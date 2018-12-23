package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.util.Map
import org.eclipse.debug.core.model.IVariable

class DynamicDiagramUtils {
	public static int WIDTH_SIZE = 140
	public static int WIDTH_MARGIN = 100
	public static int MIN_WIDTH = 25
	public static int LETTER_WIDTH = 12
	public static int MAX_ELEMENT_WIDTH = 200
	public static int PADDING = 10
	public static int DEFAULT_HEIGHT = 65		
	
	static def int nextLocationForSibling(IVariable variable, Integer y, Integer height) {
		val allChildrenSize = (variable.childrenSizeForHeight * DEFAULT_HEIGHT) / 2
		println("all children size de " + variable.childrenSizeForHeight)
		println("y " + y)
		println("height " + height)
		allChildrenSize + y + PADDING + height
	}

	static def int childrenSizeForHeight(IVariable variable) {
		val Map<Integer, Integer>allChildren = newHashMap
		variable.getAllChildren(allChildren, 0)
		if (allChildren.isEmpty) return 1
		allChildren.values.fold(0, [ acum, child | acum + child ])
	}
	
	static def void getAllChildren(IVariable variable, Map<Integer, Integer> allChildren, int level) {
		if (variable.value === null) return;
		val allVariables = variable.value.variables
		allChildren.put(level, allVariables.size)
		variable.value.variables.forEach [ 
			getAllChildren(allChildren, level + 1)
		]
	}
}
