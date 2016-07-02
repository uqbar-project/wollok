package org.uqbar.project.wollok.ui.console.editor

import org.eclipse.swt.custom.StyledTextContent
import org.eclipse.swt.custom.TextChangeListener
import org.uqbar.project.wollok.ui.console.highlight.AnsiUtils

class WollokReplStyleContent implements StyledTextContent {
	StyledTextContent textContent
	
	new(StyledTextContent _textContent) {
		textContent = _textContent
	}
	
	override addTextChangeListener(TextChangeListener listener) {
		textContent.addTextChangeListener(listener)
	}
	
	override getCharCount() {
		textContent.getCharCount
	}
	
	override getLine(int lineIndex) {
		AnsiUtils.escapeAnsi(textContent.getLine(lineIndex), '').trim
	}
	
	override getLineAtOffset(int offset) {
		textContent.getLineAtOffset(offset)
	}
	
	override getLineCount() {
		textContent.lineCount
	}
	
	override getLineDelimiter() {
		textContent.lineDelimiter
	}
	
	override getOffsetAtLine(int lineIndex) {
		textContent.getOffsetAtLine(lineIndex)
	}
	
	override getTextRange(int start, int length) {
		textContent.getTextRange(start, length)
	}
	
	override removeTextChangeListener(TextChangeListener listener) {
		textContent.removeTextChangeListener(listener)
	}
	
	override replaceTextRange(int start, int replaceLength, String text) {
		textContent.replaceTextRange(start, replaceLength, text)
	}
	
	override setText(String text) {
		textContent.text = text
	}

}
