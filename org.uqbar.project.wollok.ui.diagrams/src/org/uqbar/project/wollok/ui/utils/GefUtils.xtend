package org.uqbar.project.wollok.ui.utils

import org.eclipse.core.resources.IFile
import org.eclipse.draw2d.MarginBorder
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.ui.IActionBars
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.FileEditorInput
import org.uqbar.project.wollok.ui.diagrams.classes.WollokDiagramsPlugin

/**
 * Gef utility methods like extension methods.
 * 
 * @author jfernandes
 */
class GefUtils {
	
	def static asEditorInput(IFile file) {
		new FileEditorInput(file)
	}
	
	def static setGlobalActionHandler(IActionBars bars, ActionFactory factory, ActionRegistry registry) {
		var id = factory.id
		bars.setGlobalActionHandler(id, registry.getAction(id))
	}
	
	def static icon(String fileName) {
		ImageDescriptor.createFromFile(WollokDiagramsPlugin, fileName)
	}
	
	def static margin(Integer... margins) {
		if (margins.length == 1)
			new MarginBorder(margins.get(0), margins.get(0), margins.get(0), margins.get(0))
		else
			new MarginBorder(margins.get(0), margins.get(1), margins.get(2), margins.get(3))
	}
	
}