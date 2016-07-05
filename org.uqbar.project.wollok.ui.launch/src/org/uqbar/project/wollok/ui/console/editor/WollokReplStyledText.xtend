package org.uqbar.project.wollok.ui.console.editor

import java.lang.reflect.Field
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.custom.StyledTextContent
import org.eclipse.swt.widgets.Composite

/**
 * Styled Text Wrapper for Wollok
 * 
 */
class WollokReplStyledText extends StyledText {

	StyledTextContent originalContent
	 
	new(Composite parent, int style) {
		super(parent, style)
	}

	override setContent(StyledTextContent newContent) {
		super.setContent(newContent)
		this.originalContent = newContent
	}

	override copy() {
		wrapContentAction([ | super.copy() ])
	}
	
	override cut() {
		wrapContentAction([ | super.copy() ])
	}
	
	override copy(int clipboardType) {
		wrapContentAction([ | super.copy(clipboardType) ])
	}

	/**
	 * Sorry, but it was nearly impossible to solve it without this hack
	 * sending content setter to StyledText initializes x, y variables and overrides user selection
	 * subclassing of StyledText is not allowed (lot of privates variables)
	 */	
	private def wrapContentAction(() => void contentAction) {
		val Field fieldContent = typeof(StyledText).getDeclaredField("content")
		fieldContent => [
			accessible = true
			set(this, new WollokReplStyleContent(originalContent))
			contentAction.apply()
			set(this, originalContent)
		]
	}	
}
