package org.uqbar.project.wollok.preferences

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.validation.CheckSeverity

/**
 * @author dodain
 * Caches Type System preferences - useful for global access
 */
class WollokCachedTypeSystemPreferences {
	
	private static WollokCachedTypeSystemPreferences instance

	@Accessors CheckSeverity typeSystemSeverity
	@Accessors boolean typeSystemEnabled
		
	private new() {
		typeSystemEnabled = true
		typeSystemSeverity = CheckSeverity.WARN
	}
	
	static def getInstance() { 
		if (instance === null) instance = new WollokCachedTypeSystemPreferences
		instance
	}
	
}
