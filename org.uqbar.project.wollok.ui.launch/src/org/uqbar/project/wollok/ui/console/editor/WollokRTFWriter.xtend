package org.uqbar.project.wollok.ui.console.editor

import java.util.List
import java.util.Map
import org.uqbar.project.wollok.ui.console.highlight.WollokAnsiColorLineStyleListener

class WollokRTFWriter {

	val String buffer
	val Map<Integer, String> activate = newHashMap
	val Map<Integer, String> deactivate = newHashMap
	val List<Integer> tagsAppended = newArrayList

	public static val String ESCAPE_INIT = "["

	new(String text) {
		buffer = text
		initMaps
	}

	def initMaps() {
		activate.put(1, "\\b") // only bold supported
		
		activate.put(30, "\\cf2")
		activate.put(31, "\\cf3")
		activate.put(32, "\\cf4")
		activate.put(33, "\\cf5")
		activate.put(34, "\\cf6")
		activate.put(35, "\\cf7")
		activate.put(36, "\\cf8")
		activate.put(37, "\\cf9")
		
		deactivate.put(1, "\\b0")
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
			processLine(line, result)
			result.append("\\line")
			result.append(System.getProperty("line.separator"))
			result
		]).toString
	}

	def void processLine(String line, StringBuffer result) {
		var lastIndex = 0
		var escapeCharactersIndex = line.indexOf(ESCAPE_INIT)
		while (escapeCharactersIndex != -1) {
			result.append(line.substring(lastIndex, escapeCharactersIndex))
			val upTo = line.indexOf(WollokAnsiColorLineStyleListener.ESCAPE_SGR, escapeCharactersIndex)
			val escapedValues = line.substring(escapeCharactersIndex + 2, upTo)
			escapedValues.split(";").forEach [ escapedValue | 
				escapeToRTF(escapedValue, result)
			]
			escapeCharactersIndex = upTo
			lastIndex = escapeCharactersIndex + 1
			escapeCharactersIndex = line.indexOf(ESCAPE_INIT, escapeCharactersIndex)
		}
		result.append(line.substring(lastIndex, line.length))
	}

	// http://ascii-table.com/ansi-escape-sequences.php
	// http://www.ecma-international.org/publications/standards/Ecma-048.htm
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

}