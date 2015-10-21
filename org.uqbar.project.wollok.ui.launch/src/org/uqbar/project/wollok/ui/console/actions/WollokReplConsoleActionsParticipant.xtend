package org.uqbar.project.wollok.ui.console.actions

import org.eclipse.jface.action.Action
import org.eclipse.jface.action.Separator
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.ui.IActionBars
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsoleConstants
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.uqbar.project.wollok.ui.console.WollokReplConsole

/**
 * Contributes with buttons to wollok repl console
 * 
 * @author jfernandes
 */
class WollokReplConsoleActionsParticipant implements IConsolePageParticipant {
	IPageBookViewPage page
    Action export
    Action stop
    IActionBars bars
    WollokReplConsole console
	
	override init(IPageBookViewPage page, IConsole console) {
		this.console = console as WollokReplConsole
        this.page = page;
        val site = page.site
        this.bars = site.actionBars

        createTerminateAllButton
        createRemoveButton

		bars => [
			menuManager.add(new Separator)
	        menuManager.add(export)
	
	        toolBarManager => [
	        	appendToGroup(IConsoleConstants.LAUNCH_GROUP, stop)
	        	appendToGroup(IConsoleConstants.LAUNCH_GROUP, export)	
	        ]
	
	        updateActionBars			
		]
	}
	
	def createTerminateAllButton() {
        val imageDescriptor = ImageDescriptor.createFromFile(getClass, "/icons/stop_active.gif")
        this.stop = new Action("Stop", imageDescriptor) {
            override run() {
            	console.shutdown
            }
        };

    }

    def createRemoveButton() {
        val imageDescriptor = ImageDescriptor.createFromFile(getClass(), "/icons/export.png");
        this.export= new Action("Export History", imageDescriptor) {
            override run() {
          		console.exportSession      
            }
        };
    }
	
	override activated() {
		if (page == null)
            return;
        stop.enabled = true
//        export.enabled = true
        bars.updateActionBars
	}
	
	override deactivated() {
		stop.enabled = false
//        export.enabled = true
	}
	
	override dispose() {
//		export = null
        stop = null
        bars = null
        page = null
	}
	
	override getAdapter(Class adapter) {
	}
	
}