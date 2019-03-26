package org.uqbar.project.wollok.typeSystem.ui.builder

import com.google.inject.Inject
import com.google.inject.Singleton
import org.apache.log4j.Logger
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.builder.IXtextBuilderParticipant
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.ui.WollokActivator

import static extension org.uqbar.project.wollok.model.ResourceUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

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
@Singleton
class WollokTypeSystemBuilderParticipant implements IXtextBuilderParticipant {
	val Logger log = Logger.getLogger(this.class)

	@Inject ResourceDescriptionsProvider resourceDescriptionsProvider

	var listenersInitialized = false

	override build(IBuildContext context, IProgressMonitor monitor) throws CoreException {
		val project = context.builtProject
		val wollokActivator = WollokActivator.getInstance

		// Setting default severity from preferences
		WollokTypeSystemActivator.^default.setDefaultValuesFor(project)

		if (!listenersInitialized) {
			wollokActivator.initializePartListeners
			listenersInitialized = true
		}

		context.loadAllResources
		val wollokFiles = context.resourceSet.resources.filter[isWollokUserFile].toList

		WollokTypeSystemActivator.^default.ifEnabledFor(project) [
			// First add all Wollok files to the type system for constraint generation
			log.debug("Infering types for files: " + wollokFiles.map[it.URI.lastSegment])

			val ts = it as ConstraintBasedTypeSystem
			val contents = wollokFiles.map[contents].flatten

			try {
				// Initialization process is general
				ts.initialize(contents.head)
				// Analyzing each file
				contents.forEach[ts.analyse(it)]
				// Now that we have added all files, we can resolve constraints (aka infer types).
				ts.inferTypes
			} catch (Exception e) {
				// TODO: Reportar un error del type system que sea más piola que Error in EValidator
				log.fatal("Type inference failed", e)
			}


		]

		// Refreshing views: markers (problems tab), then outline and finally active editor
		wollokFiles.forEach [
			wollokActivator.generateIssues(it)
			wollokActivator.refreshMarkers(project, it, monitor)
		]
		wollokActivator.refreshOutline
		wollokActivator.refreshErrorsInEditor

	}

	def isWollokUserFile(Resource it) { IFile !== null && IFile.isWollokExtension && !isCoreLib }

	def loadAllResources(IBuildContext context) {
		val IResourceDescriptions index = resourceDescriptionsProvider.createResourceDescriptions
		index.allResourceDescriptions.forEach [ rd |
			log.debug(rd.URI)
			context.resourceSet.getResource(rd.URI, true)
		]
	}
}
