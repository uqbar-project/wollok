package org.uqbar.project.wollok.ui.console.editor

import java.lang.reflect.Field
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.custom.StyledTextContent
import org.eclipse.swt.widgets.Composite

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
		val Field fieldContent = typeof(StyledText).getDeclaredField("content")
		fieldContent => [
			accessible = true
			set(this, new WollokReplStyleContent(originalContent))
			super.copy()
			set(this, originalContent)
		]
	}	
}
