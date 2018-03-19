package org.uqbar.project.wollok.typesystem.ui.builder

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator

class WollokTypeSystemBuilderParticipant implements IXtextBuilderParticipant {

	override build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		val project = context.builtProject

		WollokTypeSystemActivator.^default.ifEnabledFor(project) [ ts |
			context.resourceSet.resources.map[contents].flatten.forEach[ts.analyse(it)]
			ts.inferTypes
	
			context.resourceSet.resources.forEach[modified = true]
		]
	}
}
