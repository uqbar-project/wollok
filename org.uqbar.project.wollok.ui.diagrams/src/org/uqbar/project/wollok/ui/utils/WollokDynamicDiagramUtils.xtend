package org.uqbar.project.wollok.ui.utils

import java.util.List
import org.eclipse.debug.core.model.IVariable
import org.eclipse.gef.EditPart
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.ValueEditPart
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

class WollokDynamicDiagramUtils {
	public static int WIDTH_SIZE = 150
	public static int WIDTH_MARGIN = 120
	public static int WIDTH_PADDING = 10
	public static int MIN_WIDTH = 50
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

	static def dispatch shouldShowRootArrow(WollokVariable variable, List<IVariable> variables) {
		!DynamicDiagramConfiguration.instance.shouldHide(variable) && variable.shouldShowRootConnection(variables)
	}
	
	static def dispatch shouldShowRootArrow(IVariable variable, List<IVariable> variables) {
		false
	}
	
	static def void traverseNonNullVariables(List<IVariable> variables, List<IVariable> allVariables) {
		variables.forEach [ variable |
			if (variable.value !== null) {
				allVariables.add(variable)
				variable.value.variables.traverseNonNullVariables(allVariables)
			}
		]
	}

	static def dispatch boolean isConstant(WollokVariable variable) {
		variable.isConstantReference
	}
	
	static def dispatch boolean isConstant(IVariable variable) { false }

	static def dispatch boolean isConstant(ValueEditPart part) { part.isConstantReference }
	
	static def dispatch boolean isConstant(EditPart part) { false }
}
