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
				add(new HideClassToolEntry)
			])
			defaultEntry = tool
		]
	}

// https://es.slideshare.net/XiaoranWang/gef-tutorial-2005
// https://www.google.com.ar/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&sqi=2&ved=0ahUKEwiM_77-94PUAhVCEpAKHcAqCuIQFggqMAE&url=https%3A%2F%2Fwww.eclipse.org%2Fgef%2Freference%2FGEF%2520Tutorial%25202005.ppt&usg=AFQjCNEnG7SJTS_p4BFRyd6juW3De6jj5A&sig2=40_0UwdSLd_ptjYPBeFtvA
// https://wiki.eclipse.org/Graphical_Modeling_Framework/Tutorial/Part_1
}

/** http://www.vainolo.com/2011/07/06/creating-a-gef-editor-part-6-model-refactoring-and-editing-diagram-entities/ */
class CreateAssociationToolEntry extends ConnectionCreationToolEntry {
	new() {
		super(Messages.StaticDiagram_CreateAssociation_Title, Messages.StaticDiagram_CreateAssociation_Description, new SimpleFactory(null), icon, icon)
	}

	def static getIcon() {
		try {
			ImageDescriptor.createFromFile(typeof(StaticDiagramPaletterFactory), "/icons/association.png")
		} catch (MalformedURLException e) {
			throw new RuntimeException(e)
		}
	}

}

class HideClassToolEntry extends ToolEntry {

	new() {
		super(Messages.StaticDiagram_HideClassFromDiagram_Title, Messages.StaticDiagram_HideClassFromDiagram_Description, icon, icon)
	}

	def static getIcon() {
		try {
			ImageDescriptor.createFromFile(typeof(StaticDiagramPaletterFactory), "/icons/hideClass.png")
		} catch (MalformedURLException e) {
			throw new RuntimeException(e)
		}
	}
	
}