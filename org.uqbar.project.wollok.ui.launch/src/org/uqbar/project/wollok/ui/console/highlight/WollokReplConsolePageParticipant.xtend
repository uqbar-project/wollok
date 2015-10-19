package org.uqbar.project.wollok.ui.console.highlight

import org.eclipse.swt.custom.StyledText
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * This should be injected by a extension point.
 * It's currently hardcoded / fixed
 * 
 * @author jfernandes
 */
class WollokReplConsolePageParticipant implements IConsolePageParticipant {

	override init(IPageBookViewPage page, IConsole console) {
		if (page.control instanceof StyledText) {
            val viewer = page.control as StyledText
            viewer.addLineStyleListener(new WollokAnsiColorLineStyleListener)
            Activator.getDefault.addViewer(viewer, this)
        }
	}
	
	override activated() { }
	override deactivated() { }
	override dispose() { }
	override getAdapter(Class adapter) { null }
	
}