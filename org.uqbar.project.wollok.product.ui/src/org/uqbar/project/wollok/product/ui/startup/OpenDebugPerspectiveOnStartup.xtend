package org.uqbar.project.wollok.product.ui.startup

import org.uqbar.project.wollok.ui.WollokUIStartup
import org.eclipse.ui.PlatformUI

class OpenDebugPerspectiveOnStartup implements WollokUIStartup {
	val String DEBUG_PERSPECTIVE_NAME = "org.eclipse.debug.ui.DebugPerspective"
	
	override startup() {
		PlatformUI.workbench.showPerspective(DEBUG_PERSPECTIVE_NAME, PlatformUI.workbench.activeWorkbenchWindow)
	}
}