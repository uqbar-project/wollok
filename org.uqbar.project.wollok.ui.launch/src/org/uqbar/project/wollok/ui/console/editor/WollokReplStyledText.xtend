package org.uqbar.project.wollok.ui.console.editor

import java.lang.reflect.Field
import org.eclipse.swt.SWTError
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.dnd.Clipboard
import org.eclipse.swt.dnd.DND
import org.eclipse.swt.dnd.TextTransfer
import org.eclipse.swt.dnd.Transfer
import org.eclipse.swt.widgets.Composite

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

/**
 * Styled Text Wrapper for Wollok
 * 
 */
class WollokReplStyledText extends StyledText {

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
					val Object[] data = #{ text }
					val Transfer[] types = #{ plainTextTransfer	}
					val clipboard = getFieldValue("clipboard") as Clipboard
					clipboard.setContents(data, types, type)
					return true
				}
			} else {
				val int	length = selection.y - selection.x
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
		if (clipboardType == DND.SELECTION_CLIPBOARD && !isGtk) return
		val TextTransfer plainTextTransfer = TextTransfer.getInstance()
		//val plainTextWriter = createWriter("StyledText$TextWriter", start, escapedBlockText.length)
		//val String plainText = getEscapedDelimitedText(plainTextWriter)
		val plainText = content.getTextRange(start, length).deleteAnsiCharacters
		var Object[] data
		var Transfer[] types
		if (clipboardType == DND.SELECTION_CLIPBOARD) {
			data = #[ plainText ]
			types = #[ plainTextTransfer ]
		} else {
			// val RTFTransfer	rtfTransfer = RTFTransfer.getInstance()
			// rtf = buscar una libreria que convierta de ASCII a RTF
			//data = #[ rtfText,, plainText  ]
			//types = #[ rtfTransfer, plainTextTransfer ]
			data = #[  plainText  ]
			types = #[ plainTextTransfer ]
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
		val method = typeof(StyledText).getDeclaredMethod(methodName, args.map [ it.class ])
		method.accessible = true
		method.invoke(this, args)
	}
	
}
