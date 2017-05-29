package org.uqbar.project.wollok.ui.diagrams.classes.palette

import java.net.MalformedURLException
import org.eclipse.gef.palette.ConnectionCreationToolEntry
import org.eclipse.gef.palette.MarqueeToolEntry
import org.eclipse.gef.palette.PaletteGroup
import org.eclipse.gef.palette.PaletteRoot
import org.eclipse.gef.palette.PanningSelectionToolEntry
import org.eclipse.gef.palette.ToolEntry
import org.eclipse.gef.requests.SimpleFactory
import org.eclipse.jface.resource.ImageDescriptor
import org.uqbar.project.wollok.ui.diagrams.Messages

/**
 * @author jfernandes
 */
class StaticDiagramPaletterFactory {

	def static create() {
		new PaletteRoot => [
			
			val tool = new PanningSelectionToolEntry
			add(new PaletteGroup("Tools") => [
				add(tool)
				add(new MarqueeToolEntry)
				add(new CreateAssociationToolEntry)
				// TODO: CreateDependencyToolEntry
			])
			defaultEntry = tool
		]
	}

}

/** http://www.vainolo.com/2011/07/06/creating-a-gef-editor-part-6-model-refactoring-and-editing-diagram-entities/ */
class CreateAssociationToolEntry extends ConnectionCreationToolEntry {
	new() {
		super(Messages.StaticDiagram_CreateAssociation_Title, Messages.StaticDiagram_CreateAssociation_Description, new SimpleFactory(null), icon, icon)
	}

	def static getIcon() {
		try {
			ImageDescriptor.createFromFile(typeof(StaticDiagramPaletterFactory), "/icons/dependency_create.png")
		} catch (MalformedURLException e) {
			throw new RuntimeException(e)
		}
	}

}

class CreateDependencyToolEntry extends ConnectionCreationToolEntry {
	new() {
		super(Messages.StaticDiagram_CreateDependency_Title, Messages.StaticDiagram_CreateDependency_Description, new SimpleFactory(null), icon, icon)
	}

	def static getIcon() {
		try {
			ImageDescriptor.createFromFile(typeof(StaticDiagramPaletterFactory), "/icons/association.png")
		} catch (MalformedURLException e) {
			throw new RuntimeException(e)
		}
	}

}
