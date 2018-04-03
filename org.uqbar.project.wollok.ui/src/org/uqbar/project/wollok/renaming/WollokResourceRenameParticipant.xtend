package org.uqbar.project.wollok.renaming

import org.eclipse.xtext.common.types.ui.refactoring.participant.JdtRenameParticipant
import org.uqbar.project.wollok.scoping.WollokResourceCache

class WollokResourceRenameParticipant extends JdtRenameParticipant {
	
	override protected initialize(Object originalTargetElement) {
		WollokResourceCache.clearResourceCache
		super.initialize(originalTargetElement)
	}
	
}