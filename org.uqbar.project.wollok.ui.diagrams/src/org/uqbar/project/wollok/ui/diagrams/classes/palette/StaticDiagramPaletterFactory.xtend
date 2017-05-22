package org.uqbar.project.wollok.ui.diagrams.classes.palette

import java.net.URL
import org.eclipse.gef.palette.ConnectionCreationToolEntry
import org.eclipse.gef.palette.MarqueeToolEntry
import org.eclipse.gef.palette.PaletteRoot
import org.eclipse.gef.palette.PaletteToolbar
import org.eclipse.gef.palette.PanningSelectionToolEntry
import org.eclipse.gef.requests.CreationFactory
import org.eclipse.jface.resource.ImageDescriptor

/**
 * @author jfernandes
 */
class StaticDiagramPaletterFactory {

	def static create() {
		new PaletteRoot => [
			val tool = new PanningSelectionToolEntry
			add(new PaletteToolbar("Tools") => [
				add(tool)
				add(new MarqueeToolEntry)
				add(new ConnectionCreationToolEntry(
					"Asociar",
					"Conocer",
					null,
					null, //ImageDescriptor.createFromURL(new URL("icons/connection.gif")),
					null  //ImageDescriptor.createFromURL(new URL("icons/connection.gif")))
					)
				)
			])
			defaultEntry = tool
		]
	}

// https://es.slideshare.net/XiaoranWang/gef-tutorial-2005
// https://www.google.com.ar/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&sqi=2&ved=0ahUKEwiM_77-94PUAhVCEpAKHcAqCuIQFggqMAE&url=https%3A%2F%2Fwww.eclipse.org%2Fgef%2Freference%2FGEF%2520Tutorial%25202005.ppt&usg=AFQjCNEnG7SJTS_p4BFRyd6juW3De6jj5A&sig2=40_0UwdSLd_ptjYPBeFtvA
// https://wiki.eclipse.org/Graphical_Modeling_Framework/Tutorial/Part_1
}
