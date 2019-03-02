package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import org.eclipse.debug.core.model.IVariable

class DynamicDiagramUtils {
	public static int WIDTH_SIZE = 140
	public static int WIDTH_MARGIN = 100
	public static int MIN_WIDTH = 25
	public static int LETTER_WIDTH = 12
	public static int MAX_ELEMENT_WIDTH = 200
	public static int PADDING = 13
	public static int DEFAULT_HEIGHT = 50
	
	static def int nextLocationForSibling(IVariable variable, Integer y, Integer height) {
		val allChildrenSize = variable.childrenSizeForHeight
		val calculatedHeightBasedOnChild = Math.max(1, allChildrenSize) * (DEFAULT_HEIGHT + PADDING)
		val int halfPadding = PADDING / 2
		calculatedHeightBasedOnChild + y + halfPadding
	}

	static def int childrenSizeForHeight(IVariable variable) {
		if (variable.value === null) return 1
		val allVariables = variable.value.variables
		if (allVariables.isEmpty) return 1
		allVariables.fold(0, [ acum, ref | acum + ref.childrenSizeForHeight ])
	}
}
