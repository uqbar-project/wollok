package org.uqbar.project.wollok.ui.launch

import org.eclipse.debug.ui.AbstractLaunchConfigurationTabGroup
import org.eclipse.debug.ui.CommonTab
import org.eclipse.debug.ui.ILaunchConfigurationDialog
import org.eclipse.debug.ui.sourcelookup.SourceLookupTab

/**
 * Tab group for our wollok launch configurations (run configurations...)
 * 
 * @author jfernandes
 */
class WollokTabGroup extends AbstractLaunchConfigurationTabGroup {
	
	override createTabs(ILaunchConfigurationDialog dialog, String mode) {
		setTabs(#[
				new WollokMainTab,
				new SourceLookupTab,
				new CommonTab
		])
	}
	
}