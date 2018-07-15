package org.uqbar.project.wollok.typesystem.ui.builder

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.validation.AnnotationIssueProcessor
import org.eclipse.xtext.ui.editor.validation.MarkerIssueProcessor
import org.eclipse.xtext.validation.CheckMode
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.ui.WollokActivator

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.*

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

		val wollokActivator = WollokActivator.getInstance

		WollokTypeSystemActivator.^default.ifEnabledFor(project) [

			val ts = it as ConstraintBasedTypeSystem
			
			// First add all Wollok files to the type system for constraint generation
			val wollokFiles = context.resourceSet.resources.filter[ IFile !== null && IFile.isWollokExtension && !isCoreLib ]

			println("Wollok files " + wollokFiles)
			
			wollokFiles.map [ contents ].flatten.forEach[ts.analyse(it)]
 
			// Now that we have added all files, we can resolve constraints (aka infer types).
			ts.inferTypes

			wollokFiles.forEach [
				
				val issues = wollokActivator.validator.validate(it, CheckMode.ALL, null)
				new MarkerIssueProcessor(IFile, wollokActivator.markerCreator, wollokActivator.markerTypeProvider)
					.processIssues(issues, monitor)

				wollokActivator.runInXtextEditorFor(it.URI, [ XtextEditor editor |
					new AnnotationIssueProcessor(editor.document, editor.internalSourceViewer.getAnnotationModel(), wollokActivator.issueResolutionProvider)
						.processIssues(issues, monitor)
				])
			]

		]
	}

}