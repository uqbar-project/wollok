package org.uqbar.project.wollok.ui.diagrams.classes.palette

import org.eclipse.gef.palette.MarqueeToolEntry
import org.eclipse.gef.palette.PaletteRoot
import org.eclipse.gef.palette.PaletteToolbar
import org.eclipse.gef.palette.PanningSelectionToolEntry

/**
 * @author jfernandes
 */
class ClassDiagramPaletterFactory {
	
	def static create() {
		new PaletteRoot => [
			val tool = new PanningSelectionToolEntry
			add(new PaletteToolbar("Tools") => [
				add(tool)
				add(new MarqueeToolEntry)
			])
			defaultEntry = tool
		]
	}
	
}