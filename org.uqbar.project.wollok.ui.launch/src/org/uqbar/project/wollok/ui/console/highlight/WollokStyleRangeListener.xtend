package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.custom.StyledText
import org.uqbar.project.wollok.ui.console.editor.WollokReplStyledText

class WollokStyleRangeListener implements LineStyleListener {
	
	WollokReplStyledText styledText
	
	new(StyledText viewer) {
		styledText = viewer as WollokReplStyledText
	}
	
	override lineGetStyle(LineStyleEvent event) {
		var List<StyleRange> styles = event.styles?.toList
		if (styles == null) {
			 styles = #[]
		}
		styledText.addStyle(event.lineOffset, styles)
	}
	
}