package org.uqbar.project.wollok.renaming

import com.google.inject.Inject
import org.eclipse.xtext.common.types.ui.refactoring.participant.JdtRenameParticipant
import org.uqbar.project.wollok.scoping.WollokResourceCache
import org.uqbar.project.wollok.scoping.cache.WollokGlobalScopeCache

class WollokResourceRenameParticipant extends JdtRenameParticipant {
	
	override protected initialize(Object originalTargetElement) {
		WollokResourceCache.clearResourceCache
		super.initialize(originalTargetElement)
	}
	
}