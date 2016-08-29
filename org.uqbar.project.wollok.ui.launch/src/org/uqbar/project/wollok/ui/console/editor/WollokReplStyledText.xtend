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
import org.uqbar.project.wollok.ui.console.editor.rtf.WollokRTFWriter

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

/**
 * Styled Text Wrapper for Wollok
 * 
 */
class WollokReplStyledText extends StyledText {

	WollokStyle style = new WollokStyle(this)

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

		// Fix: when you select a line from start, it doesn't catch special characters
		val TextTransfer plainTextTransfer = TextTransfer.getInstance()
		val originalText = content.getTextRange(start, length)
		val plainText = originalText.deleteAnsiCharacters
		var Object[] data
		var Transfer[] types
		if (clipboardType == DND.SELECTION_CLIPBOARD) {
			data = #[plainText]
			types = #[plainTextTransfer]
		} else {
			try {
				style.adjustBoundaryOffsets(start, length)
				val rtfWriter = new WollokRTFWriter(style)
				val rtfText = rtfWriter.RTFText
				println("RTF Text: " + rtfText)
				val RTFTransfer rtfTransfer = RTFTransfer.getInstance()
				data = #[rtfText, plainText]
				types = #[rtfTransfer, plainTextTransfer]
			} catch (Exception e) {
				data = #[plainText]
				types = #[plainTextTransfer]
			}
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
	
	def void addStyle(int offset, List<StyleRange> styles) {
		val line = content.getLineAtOffset(offset)
		style.applyStyle(line, styles)
	}
	
}
