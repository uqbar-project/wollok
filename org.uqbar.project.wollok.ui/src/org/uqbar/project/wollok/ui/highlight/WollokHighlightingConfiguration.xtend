package org.uqbar.project.wollok.ui.highlight

import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor

import static org.uqbar.project.wollok.utils.WEclipseUtils.*

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
	public static val WOLLOK_DOC_STYLE_ID = "WOLLOK_DOC_STYLE_ID"
	public static val COMPONENT_STYLE_ID = "COMPONENT_STYLE_ID"
//	public static val KEYWORD_STYLE_ID = "KEYWORD_STYLE_ID"

	boolean darkTheme = environmentHasDarkTheme

	override configure(IHighlightingConfigurationAcceptor it) {
		super.configure(it)
		acceptDefaultHighlighting(INSTANCE_VAR_STYLE_ID, "Instance Variable", instanceVarTextStyle)
		acceptDefaultHighlighting(LOCAL_VAR_STYLE_ID, "Local Variable", localVarTextStyle)
		acceptDefaultHighlighting(PARAMETER_STYLE_ID, "Parameter", parameterTextStyle)
		acceptDefaultHighlighting(WOLLOK_DOC_STYLE_ID, "Wollok DOC", wollokDocTextStyle)
		acceptDefaultHighlighting(COMPONENT_STYLE_ID, "Object/Class/Mixin", componentTextStyle)
//		acceptDefaultHighlighting(KEYWORD_STYLE_ID, "Keyword", keywordTextStyle)
	}

	def instanceVarTextStyle() {
		defaultTextStyle().copy() => [
			if (darkTheme) {
				color = new RGB(156, 220, 254)
			} else {
				color = new RGB(0, 0, 192)
			}
		]
	}

	def wollokDocTextStyle() {
		commentTextStyle.copy() => [
			if (darkTheme) {
				color = new RGB(119, 183, 103)
			} else {
				color = new RGB(127, 127, 159)
			}
		]
	}

	def localVarTextStyle() {
		defaultTextStyle().copy() => [
			if (darkTheme) {
				color = new RGB(224, 179, 128)
			} else {
				color = new RGB(125, 125, 185)
			}
		]
	}

	def parameterTextStyle() {
		defaultTextStyle().copy() => [
			if (darkTheme) {
				color = new RGB(220, 220, 170)
			} else {
				color = new RGB(185, 125, 125)
			}
		]
	}

	// has no effect!
	override keywordTextStyle() {
		defaultTextStyle().copy => [
			if (darkTheme) {
				color = new RGB(19, 149, 214)				
			} else {
				color = new RGB(127, 0, 85)
				style = SWT.BOLD
			}
		]
	}

	def componentTextStyle() {
		commentTextStyle.copy() => [
			if (darkTheme) {
				color = new RGB(57, 200, 176)
			} else {
				color = new RGB(0, 0, 0)
			}
		]
	}

}
