package org.uqbar.project.wollok.ui.console.editor

import java.util.List
import java.util.Map
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Font
import org.uqbar.project.wollok.ui.console.highlight.WollokAnsiColorLineStyleListener

class WollokRTFWriter {

	val String buffer
	val Map<Integer, String> activate = newHashMap
	val Map<Integer, String> deactivate = newHashMap
	val List<Integer> tagsAppended = newArrayList
	val List<Integer> commandTagsAppended = newArrayList
	val List<StyleRange> styles
	val List<Integer> offsets
	// Relative position for styling
	val int start

	public static val String ESCAPE_INIT = "["
	
	new(String text, List<StyleRange> _styles, List<Integer> _offsets, int _start) {
		buffer = text
		styles = _styles
		offsets = _offsets
		start = _start
		initMaps
	}

	def initMaps() {
		activate.put(1, "\\b") 
		activate.put(2, "\\i")
		activate.put(3, "\\ul")
		activate.put(4, "\\strike")
		activate.put(30, "\\cf2")
		activate.put(31, "\\cf3")
		activate.put(32, "\\cf4")
		activate.put(33, "\\cf5")
		activate.put(34, "\\cf6")
		activate.put(35, "\\cf7")
		activate.put(36, "\\cf8")
		activate.put(37, "\\cf9")
		
		deactivate.put(1, "\\b0")
		deactivate.put(2, "\\i0")
		deactivate.put(3, "\\ul0")
		deactivate.put(4, "\\strike0")
		deactivate.put(31, "\\cf1")
		deactivate.put(32, "\\cf1")
		deactivate.put(33, "\\cf1")
		deactivate.put(34, "\\cf1")
		deactivate.put(35, "\\cf1")
		deactivate.put(36, "\\cf1")
		deactivate.put(37, "\\cf1")
	}

	def getText() {
		buffer
	}

	def String getRTFText() {
		'''
		{\rtf1\ansi\deff0
		{\colortbl;\red32\green32\blue32;\red0\green0\blue0;\red255\green0\blue0;\red0\green153\blue0;\red255\green255\blue0;\red0\green0\blue204;\red255\green0\blue127;\red0\green204\blue204;\red255\green255\blue255;}
		{\fonttbl {\f0 \fmodern Courier;}}
		\f0
		\b
		\cf1
		''' + linesText
		+ 
		'''
		\b0
		}
		'''
	}
	
	def getLines() {
		text.split(System.getProperty("line.separator"))
	}

	def String getLinesText() {
		lines.fold(new StringBuffer, [ result, line |
			// Falta: saber que lineas son
			processRTFLine(line, result)
			result.append("\\line")
			result.append(System.getProperty("line.separator"))
			result
		]).toString
	}
	
	def processRTFLine(String line, StringBuffer result, int i) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	@Deprecated
	def void processLine(String line, StringBuffer result) {
		var lastIndex = 0
		var escapeCharactersIndex = line.indexOf(ESCAPE_INIT)
		while (escapeCharactersIndex != -1) {
			appendCommand(line.substring(lastIndex, escapeCharactersIndex), result, lastIndex)
			val upTo = line.indexOf(WollokAnsiColorLineStyleListener.ESCAPE_SGR, escapeCharactersIndex)
			val escapedValues = line.substring(escapeCharactersIndex + 2, upTo)
			escapedValues.split(";").forEach [ escapedValue | 
				escapeToRTF(escapedValue, result)
			]
			escapeCharactersIndex = upTo
			lastIndex = escapeCharactersIndex + 1
			escapeCharactersIndex = line.indexOf(ESCAPE_INIT, escapeCharactersIndex)
		}
		appendCommand(line.substring(lastIndex, line.length), result, lastIndex)
	}

	// http://ascii-table.com/ansi-escape-sequences.php
	// http://www.ecma-international.org/publications/standards/Ecma-048.htm
	@Deprecated
	def escapeToRTF(String _escapedValue, StringBuffer result) {
		var escapedValue = 0
		try {
			escapedValue = new Integer(_escapedValue)
		} catch (NumberFormatException e) {
		}
		if (escapedValue == 0) {
			tagsAppended.forEach [ tag | 
				result.append(deactivate.get(tag) ?: "") 
				result.append(System.getProperty("line.separator"))
			]
		} else {
			result.append((activate.get(escapedValue) ?: ""))
			result.append(System.getProperty("line.separator"))
			tagsAppended.add(escapedValue)
		}
	}

	/**
	 * Appends a command 
	 * Simplified version for Wollok REPL Console
	 * @param command The Wollok Command to execute
	 * @param result  Buffer with RTF
	 * @param beginIndex relative position where this command is located in selected text
	 */
	def void appendCommand(String command, StringBuffer result, int beginIndex) {
		if (styles == null || styles.isEmpty) {
			result.append(command)
			return
		}
		if (command == null || command.trim.equals("")) {
			return
		}
        
        println("Command " + command)
        println("Start " + start)
        println("Begin index " + beginIndex)
		val stylesRange = stylesBetween(start + beginIndex, command.length)
		println("Styles range " + stylesRange)
		(stylesRange).forEach [ style |
			result.append("{\\cf")
			var int fontStyle = style.fontStyle
			val Font font = style.font
			if (font != null) {
				val fontData = font.fontData.head
				fontStyle = fontData.getStyle()
			}
			if (fontStyle.bitwiseAnd(SWT.BOLD) != 0) {
				result.append("\\b")
				commandTagsAppended.add(1)
			}
			if (fontStyle.bitwiseAnd(SWT.ITALIC) != 0) {
				result.append("\\i")
				commandTagsAppended.add(2)
			}
			if (style.underline) {
				result.append("\\ul")
				commandTagsAppended.add(3)
			}
			if (style.strikeout) {
				result.append("\\strike")
				commandTagsAppended.add(4)
			}
			result.append(" ")
			val newStart = style.start - start - beginIndex
			result.append(command.substring(newStart, style.length))
			// Deactivate tags appended to a range style
			commandTagsAppended.forEach [ tag | result.append(deactivate.get(tag)) ]
			result.append("}")
			// write unstyled text at the end of the line
//			if (lineIndex < lineEndOffset) {
//				result.append(line.substring(lineIndex, lineEndOffset))
//			}
		]
	}

	/**
	 * Looks styles between starting position and a length
	 */	
	def stylesBetween(int start, int length) {
		val end = start + length
		styles.filter [ StyleRange style | 
			val styleEnd = style.start + style.length
			return (style.start..styleEnd).toList.exists [ Integer i | i >= start && i <= end ]
		]
	}
	
}
