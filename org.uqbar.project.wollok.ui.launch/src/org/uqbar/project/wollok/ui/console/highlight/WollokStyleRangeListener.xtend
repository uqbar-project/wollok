package org.uqbar.project.wollok.ui.console.highlight

import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyledText
import org.uqbar.project.wollok.ui.console.editor.WollokReplStyledText

class WollokStyleRangeListener implements LineStyleListener {
	
	WollokReplStyledText styledText
	
	new(StyledText viewer) {
		styledText = viewer as WollokReplStyledText
	}
	
	override lineGetStyle(LineStyleEvent event) {
		// TODO, meter un mapa por linea
		styledText.styles = event.styles?.toList
	}
		
}