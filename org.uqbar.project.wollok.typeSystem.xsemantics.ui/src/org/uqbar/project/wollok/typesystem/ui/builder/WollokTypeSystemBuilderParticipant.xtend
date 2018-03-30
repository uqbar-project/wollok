package org.uqbar.project.wollok.typesystem.ui.builder

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator

/**
 * A builder participant that runs the type system. 
 * 
 * Builder participants are executed each time a resource is saved in any project with XText Nature. 
 * The builder is able to get all resources (i.e. Wollok files) from the project and run the type system
 * taking all of them into account.
 * 
 * No error is reported here. When the @link{TypeSystemWollokValidatorExtension) runs, it will report
 * the errors detected by this type system run.
 * 
 * @author npasserini
 */
class WollokTypeSystemBuilderParticipant implements IXtextBuilderParticipant {

	override build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		val project = context.builtProject

		WollokTypeSystemActivator.^default.ifEnabledFor(project) [ ts |
			// First add all Wollok files to the type system for constraint generation
			context.resourceSet.resources.map[contents].flatten.forEach[ts.analyse(it)]
			
			// Now that we have added all files, we can resolve constraints (aka infer types).
			ts.inferTypes
		]
	}
}
