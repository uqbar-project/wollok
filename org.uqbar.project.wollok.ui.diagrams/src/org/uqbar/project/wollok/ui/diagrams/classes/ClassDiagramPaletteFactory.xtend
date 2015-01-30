package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.palette.MarqueeToolEntry
import org.eclipse.gef.palette.PaletteRoot
import org.eclipse.gef.palette.PaletteToolbar
import org.eclipse.gef.palette.PanningSelectionToolEntry

/**
 * 
 * @author jfernandes
 */
class ClassDiagramPaletteFactory {

	def static createPalette() {
		new PaletteRoot => [
			add(createToolsGroup)
		]
	}

	def static createToolsGroup(PaletteRoot palette) {
		new PaletteToolbar("Tools") => [
			add(new PanningSelectionToolEntry => [
				palette.defaultEntry = it
			])
			add(new MarqueeToolEntry)
		]
	}

}