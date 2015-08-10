package org.uqbar.project.wollok.ui.tests.launch

import org.eclipse.debug.ui.AbstractLaunchConfigurationTabGroup
import org.eclipse.debug.ui.CommonTab
import org.eclipse.debug.ui.ILaunchConfigurationDialog
import org.eclipse.debug.ui.sourcelookup.SourceLookupTab

/**
 * Tab group for our wollok launch tests configurations (run configurations...)
 * 
 * @author tesonep
 */
class WollokTestsTabGroup extends AbstractLaunchConfigurationTabGroup {
	
	override createTabs(ILaunchConfigurationDialog dialog, String mode) {
		setTabs(#[
				new WollokTestMainTab,
				new SourceLookupTab,
				new CommonTab
		])
	}
	
}