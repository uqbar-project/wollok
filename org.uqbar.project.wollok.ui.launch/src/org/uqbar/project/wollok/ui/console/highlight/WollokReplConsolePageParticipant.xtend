package org.uqbar.project.wollok.ui.console.highlight

import org.eclipse.swt.custom.StyledText
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * 
 * @author jfernandes
 */
class WollokReplConsolePageParticipant implements IConsolePageParticipant {

	override init(IPageBookViewPage page, IConsole console) {
		if (page.control instanceof StyledText) {
            val viewer = page.control as StyledText
            val myListener = new WollokReplLineStyleListener
            viewer.addLineStyleListener(myListener)
            Activator.getDefault.addViewer(viewer, this)
        }
	}
	
	override activated() { }
	
	override deactivated() { }
	
	override dispose() { }
	
	override getAdapter(Class adapter) { null }
	
}