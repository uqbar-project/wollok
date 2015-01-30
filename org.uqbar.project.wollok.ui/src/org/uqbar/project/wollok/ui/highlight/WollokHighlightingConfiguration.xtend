package org.uqbar.project.wollok.ui.highlight

import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor

/**
 * Defines styles that are then used by WollokHighlightingCalculator.
 * Xtext actually generates a preferences page for this styles
 * so the user is able to customize the values.
 * 
 * @author jfernandes
 */
class WollokHighlightingConfiguration extends DefaultHighlightingConfiguration {
	public static val INSTANCE_VAR_STYLE_ID = "INSTANCE_VAR_STYLE_ID"
	public static val LOCAL_VAR_STYLE_ID = "LOCAL_VAR_STYLE_ID"
	public static val PARAMETER_STYLE_ID = "PARAMETER_STYLE_ID"
	
	override configure(IHighlightingConfigurationAcceptor it) {
		super.configure(it)
		
		acceptDefaultHighlighting(INSTANCE_VAR_STYLE_ID, "Instance Variable", instanceVarTextStyle)
		acceptDefaultHighlighting(LOCAL_VAR_STYLE_ID, "Local Variable", localVarTextStyle)
		acceptDefaultHighlighting(PARAMETER_STYLE_ID, "Parameter", parameterTextStyle)
	}
	
	def instanceVarTextStyle() {
		defaultTextStyle().copy() => [
			color = new RGB(0, 0, 192)
		]
	}
	
	def localVarTextStyle() {
		defaultTextStyle().copy() => [
			color = new RGB(125, 125, 185)
		]
	}
	
	def parameterTextStyle() {
		defaultTextStyle().copy() => [
			color = new RGB(185, 125, 125)
		]
	}
	
}