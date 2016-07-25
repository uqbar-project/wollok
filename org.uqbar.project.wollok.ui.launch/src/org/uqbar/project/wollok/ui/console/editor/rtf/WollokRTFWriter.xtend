package org.uqbar.project.wollok.ui.console.editor.rtf

import java.util.List
import org.eclipse.swt.custom.StyleRange
import org.uqbar.project.wollok.ui.console.editor.WollokStyle

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

class WollokRTFWriter {

	public static String ESCAPE_INIT = "m"

	RTFForegroundColorTagCommand foregroundCommand
	val List<RTFTagCommand> tagCommands
	val WollokStyle style
	WollokRTFColorMatcher wollokRTFColorMatcher

	/**
	 * @params text    The complete text to copy
	 * @params style   A Wollok Style object that contains everything to show them
	 */
	new(WollokStyle _style) {
		style = _style
		wollokRTFColorMatcher = new WollokRTFColorMatcher(style)
		foregroundCommand = new RTFForegroundColorTagCommand(wollokRTFColorMatcher)
		tagCommands = #[foregroundCommand, new RTFBoldCommand, new RTFItalicCommand, new RTFUnderlineCommand, new RTFStrikeoutCommand]
	}

	def String getRTFText() {
		'''
		{\rtf1\ansi\deff0
		{\colortbl;
		''' +
		wollokRTFColorMatcher.colorTable +
		'''
		}
		{\fonttbl {\f0 \fmodern Courier;}}
		\f0
		\b
		\cf1
		''' + linesText + '''
		\b0
		}
		'''
	}

	def String getLinesText() {
		val result = new StringBuffer
		for (i : style.lineStart .. style.lineEnd) {
			processRTFLine(style.getLine(i), style.getStylesAtLine(i), result)
			result.append("\\line")
			result.append(System.getProperty("line.separator"))
		}
		result.toString
	}

	def void processRTFLine(String line, List<StyleRange> styles, StringBuffer result) {
		styles.forEach[style |
			style.apply(line + System.getProperty("line.separator"), result)
		]
	}

	def apply(StyleRange _style, String line, StringBuffer result) {
		result.append("{")
		val tagsApplied = tagCommands.filter[tagCommand|tagCommand.appliesTo(_style)].toList
		tagsApplied.forEach[it.formatTag(_style, result)]
		result.append(" ")
		val end = Math.min(line.length, _style.start + _style.length)
		if (end > 0) {
			result.append(line.substring(_style.start, end).deleteAnsiCharacters)
		}
		// Deactivate tags appended to a range style
		tagsApplied.forEach[ tag | tag.deactivateTag(_style, result) ]
		result.append("}")
	}
	
}
