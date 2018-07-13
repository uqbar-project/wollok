package org.uqbar.project.wollok.ui.console.editor.rtf

import java.util.List
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font
import org.uqbar.project.wollok.ui.console.editor.WollokStyle

abstract class RTFTagCommand {

	def boolean appliesTo(StyleRange style)

	def void formatTag(StyleRange style, StringBuffer result)
	
	def void deactivateTag(StyleRange style, StringBuffer result)

}

abstract class RTFFontTagCommand extends RTFTagCommand {

	override appliesTo(StyleRange style) {
		var int fontStyle = style.fontStyle
		val Font font = style.font
		if (font !== null) {
			val fontData = font.fontData.head
			fontStyle = fontData.getStyle()
		}
		doAppliesTo(fontStyle, style)
	}
	
	def boolean doAppliesTo(int fontStyle, StyleRange range)
	
	override deactivateTag(StyleRange style, StringBuffer result) {
		formatTag(style, result)
		result.append("0")
	}

}

class RTFBoldCommand extends RTFFontTagCommand {

	override formatTag(StyleRange style, StringBuffer result) {
		result.append("\\b")
	}

	override doAppliesTo(int fontStyle, StyleRange range) {
		fontStyle.bitwiseAnd(SWT.BOLD) != 0
	}

}

class RTFItalicCommand extends RTFFontTagCommand {

	override doAppliesTo(int fontStyle, StyleRange range) {
		fontStyle.bitwiseAnd(SWT.ITALIC) != 0
	}
	
	override formatTag(StyleRange style, StringBuffer result) {
		result.append("\\i")
	}

}

class RTFUnderlineCommand extends RTFFontTagCommand {

	override doAppliesTo(int fontStyle, StyleRange style) {
		style.underline
	}
	
	override formatTag(StyleRange style, StringBuffer result) {
		result.append("\\ul")
	}

}


class RTFStrikeoutCommand extends RTFFontTagCommand {

	override doAppliesTo(int fontStyle, StyleRange style) {
		style.strikeout
	}
	
	override formatTag(StyleRange style, StringBuffer result) {
		result.append("\\strike")
	}

}

class RTFForegroundColorTagCommand extends RTFFontTagCommand {

	static int DEFAULT_FOREGROUND = 0
	WollokRTFColorMatcher colorMatcher
		
	new(WollokRTFColorMatcher _colorMatcher) {
		colorMatcher = _colorMatcher
	}
	
	override doAppliesTo(int fontStyle, StyleRange style) {
		true
	}
	
	override deactivateTag(StyleRange style, StringBuffer result) {
	}
	
	override formatTag(StyleRange style, StringBuffer result) {
		result.append("\\cf" + colorMatcher.getColorIndex(style.foreground, DEFAULT_FOREGROUND))
	}

}

class WollokRTFColorMatcher {
	
	List<Color> colors
	WollokStyle style
	
	new(WollokStyle _style) {
		style = _style
		colors = style.allColors
	}
	
	def int getColorIndex(Color color, int defaultIndex) {
		if (color === null) return defaultIndex
		return colors.indexOf(color) + 1
	}
 
	def String getColorTable() {
		val result = new StringBuffer
		colors.forEach [ Color color |
			result.append("\\red")
			result.append(color.red) 
			result.append("\\green")
			result.append(color.green) 
			result.append("\\blue")
			result.append(color.blue)
			result.append(";")
		]
		result.toString
	}
 
}