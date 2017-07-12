package org.uqbar.project.wollok.ui.diagrams.classes.palette

import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.views.palette.PaletteViewerPage
import org.eclipse.swt.widgets.Composite

/**
 * 
 * @author jfernandes
 */
class CustomPalettePage extends PaletteViewerPage {
	extension org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramView view

	new(PaletteViewerProvider provider, org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramView view) {
		super(provider)
		this.view = view
	}
	
	override createControl(Composite parent) {
		super.createControl(parent)
		if (splitter != null)
			splitter.externalViewer = viewer
	}

	override dispose() {
		if (splitter != null)
			splitter.externalViewer = null
		super.dispose
	}

	def getPaletteViewer() {
		viewer
	}
}
