package org.uqbar.project.wollok.ui.console.editor

import java.lang.reflect.Field
import java.util.List
import org.eclipse.swt.SWTError
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.dnd.Clipboard
import org.eclipse.swt.dnd.DND
import org.eclipse.swt.dnd.RTFTransfer
import org.eclipse.swt.dnd.TextTransfer
import org.eclipse.swt.dnd.Transfer
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.console.highlight.WollokAnsiColorLineStyleListener

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

/**
 * Styled Text Wrapper for Wollok
 * 
 */
class WollokReplStyledText extends StyledText {

	// Styles for rendering RTF
	@Accessors List<StyleRange> styles
	List<Integer> ranges

	new(Composite parent, int style) {
		super(parent, style)
	}

	override copy(int clipboardType) {
		checkWidget()
		doCopySelection(clipboardType)
	}

	override copy() {
		checkWidget()
		this.doCopySelection(DND.CLIPBOARD)
	}

	def doCopySelection(int type) {
		if(type != DND.CLIPBOARD && type != DND.SELECTION_CLIPBOARD) return false
		try {
			val blockXLocation = getFieldValue("blockXLocation") as Integer
			if (blockSelection && blockXLocation != -1) {
				val text = getEscapedBlockText()
				if (text.length() > 0) {
					// TODO RTF support
					val plainTextTransfer = TextTransfer.getInstance()
					val Object[] data = #{text}
					val Transfer[] types = #{plainTextTransfer}
					val clipboard = getFieldValue("clipboard") as Clipboard
					clipboard.setContents(data, types, type)
					return true
				}
			} else {
				val int length = selection.y - selection.x
				if (length > 0) {
					setClipboardContent(selection.x, length, type)
					return true
				}
			}
		} catch (SWTError error) {
			if (error.code != DND.ERROR_CANNOT_SET_CLIPBOARD) {
				throw error
			}
		}
		return false
	}

	def void setClipboardContent(int start, int length, int clipboardType) throws SWTError {
		val boolean isGtk = getFieldValue("IS_GTK") as Boolean
		if(clipboardType == DND.SELECTION_CLIPBOARD && !isGtk) return;

		(0..content.lineCount - 1).forEach [ int i |
			println("offset linea " + i + ": " + content.getOffsetAtLine(i))
		]
		// TODO: Falta poner en styles los de cada linea, la ultima linea esta borrando lo otro...
		val offsets = (0..content.lineCount - 1).map [ int i | content.getOffsetAtLine(i) ]
		
		// Fix: when you select a line from start, it doesn't catch special characters
		val lineNumber = content.getLineAtOffset(start)
		var newLength = length
		val offsetAtLine = content.getOffsetAtLine(lineNumber)
		var newStart = start
		if (offsetAtLine < start) {
			val chars = content.getTextRange(offsetAtLine, start - offsetAtLine)
			if (chars.startsWith(WollokRTFWriter.ESCAPE_INIT) &&
				chars.charAt(chars.length - 1) == WollokAnsiColorLineStyleListener.ESCAPE_SGR) {
				// TODO: chars.length - 2 should be a number or last character of ESCAPE_INIT , another class
				// should be included
				newStart = offsetAtLine
				newLength += start - newStart
			}
		}
		// end fix
		val TextTransfer plainTextTransfer = TextTransfer.getInstance()
		val originalText = content.getTextRange(newStart, newLength)
		val plainText = originalText.deleteAnsiCharacters
		var Object[] data
		var Transfer[] types
		if (clipboardType == DND.SELECTION_CLIPBOARD) {
			data = #[plainText]
			types = #[plainTextTransfer]
		} else {
			val rtfWriter = new WollokRTFWriter(originalText, styles, offsets, newStart)
			val String rtfText = rtfWriter.RTFText
			val RTFTransfer rtfTransfer = RTFTransfer.getInstance()
			// rtf = buscar una libreria que convierta de ASCII a RTF
			data = #[rtfText, plainText]
			types = #[rtfTransfer, plainTextTransfer]
		}
		val clipboard = getFieldValue("clipboard") as Clipboard
		clipboard.setContents(data, types, clipboardType)
	}

	private def getEscapedBlockText() {
		val text = executeMethod("getBlockSelectionText", #{System.getProperty("line.separator")}) as String
		text.deleteAnsiCharacters
	}

	private def getField(String name) {
		val Field field = typeof(StyledText).getDeclaredField(name) as Field
		field.accessible = true
		field
	}

	private def getFieldValue(String name) {
		getField(name).get(this)
	}

	def executeMethod(String methodName, Object[] args) {
		val method = typeof(StyledText).getDeclaredMethod(methodName, args.map[it.class])
		method.accessible = true
		method.invoke(this, args)
	}
	
}
