package org.uqbar.project.wollok.typesystem.ui.builder

import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.AssertionFailedException
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator

class WollokTypeSystemBuilderParticipant implements IXtextBuilderParticipant {

	override build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		val project = context.builtProject
		if(!project.shouldBeBuilt) return;

		val ts = WollokTypeSystemActivator.^default.getTypeSystem(project)
		
		context.resourceSet.resources.map[contents].flatten.forEach[ts.analyse(it)]
		ts.inferTypes
	}
	
	def shouldBeBuilt(IProject project) {
		try {
			WollokTypeSystemActivator.^default.isTypeSystemEnabled(project)
		} catch (IllegalStateException e) {
			// headless launcher doesn't open workspace, so this fails.
			// but it's ok since the type system won't run in runtime. 
			false
		} catch (AssertionFailedException e) {
			false
		}
	}
}
