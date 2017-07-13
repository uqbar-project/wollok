package org.uqbar.project.wollok.typesystem.constraints

import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.MessageType
import org.uqbar.project.wollok.typesystem.NamedObjectWollokType
import org.uqbar.project.wollok.typesystem.TypeProvider
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.annotations.WollokCoreTypeDeclarations
import org.uqbar.project.wollok.typesystem.constraints.strategies.AbstractInferenceStrategy
import org.uqbar.project.wollok.typesystem.constraints.strategies.GuessMinTypeFromMaxType
import org.uqbar.project.wollok.typesystem.constraints.strategies.MaxTypesFromMessages
import org.uqbar.project.wollok.typesystem.constraints.strategies.OpenMethod
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMaximalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMinimalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.SealVariables
import org.uqbar.project.wollok.typesystem.constraints.strategies.UnifyVariables
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.typesystem.annotations.TypeDeclarations.*

/**
 * @author npasserini
 */
class ConstraintBasedTypeSystem implements TypeSystem, TypeProvider {
	@Accessors
	@Inject WollokClassFinder finder

	val Logger log = Logger.getLogger(this.class)

	@Accessors
	extension TypeVariablesRegistry registry
	ConstraintGenerator constraintGenerator

	override def name() { "Constraints-based" }

	override validate(WFile file, ConfigurableDslValidator validator) {
		log.debug("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes

		reportErrors(validator)
	}

	// ************************************************************************
	// ** Analysis
	// ************************************************************************
	override initialize(EObject program) {
		registry = new TypeVariablesRegistry(this)
		constraintGenerator = new ConstraintGenerator(this)
		
		// This shouldn't be necessary if all global objects had type annotations
		finder.allGlobalObjects(program).forEach[constraintGenerator.newNamedObject(it)]

		annotatedTypes = new AnnotatedTypeRegistry(registry, program)
		annotatedTypes.addTypeDeclarations(this, WollokCoreTypeDeclarations, program)
	}

	override analyse(EObject program) {
		if (registry === null) {
			initialize(program)
		}

		constraintGenerator.generateVariables(program)
	}


	// ************************************************************************
	// ** Inference
	// ************************************************************************
	override inferTypes() {
		// These constraints have to be created after all files have been `analise`d
		constraintGenerator.addInheritanceConstraints

		var currentStage = 0

		log.debug("Starting inference")

		do {
			log.debug("Running stage " + currentStage)

			if (runStage(stages.get(currentStage)))
				// Stage produced new inforamtion, start again from stage 0. 
				currentStage = 0
			else
				// No new information, go to next stage. 
				currentStage++

		} while (currentStage < stages.length)

		registry.fullReport
	}

	/**
	 * Definition of the strategies to run in each stage
	 */
	Iterable<Iterable<Class<? extends AbstractInferenceStrategy>>> stages = #[
		#[PropagateMinimalTypes, PropagateMaximalTypes, MaxTypesFromMessages],
		#[OpenMethod],
		#[UnifyVariables, SealVariables],
		#[GuessMinTypeFromMaxType]
	]

	/**
	 * Runs the strategies in a stage, returns whether any strategy produced some new information.
	 */
	def runStage(Iterable<Class<? extends AbstractInferenceStrategy>> strategies) {
		// Note that current implementation stops the stage 
		// on the first strategy that produces any new information.
		strategies.exists[runStrategy]
	}

	/**
	 * Runs a strategy, returning if it produced new information
	 */
	def boolean runStrategy(Class<? extends AbstractInferenceStrategy> it) {
		(newInstance => [it.registry = this.registry]).run()
	}

	// ************************************************************************
	// ** Error reporting
	// ************************************************************************
	override reportErrors(ConfigurableDslValidator validator) {
		allVariables.forEach[(it as TypeVariable).reportErrors(validator)]
	}

	// ************************************************************************
	// ** Other (TBD)
	// ************************************************************************
	override type(EObject obj) {
		obj.tvar.type
	}

	override issues(EObject obj) {
		#[]
	}

	override queryMessageTypeForMethod(WMethodDeclaration it) {
		new MessageType(it.name, parameters.map[type], type)
	}

	protected def objectType(WNamedObject model) {
		new NamedObjectWollokType(model, this)
	}

	protected def classType(WClass clazz) {
		new ClassBasedWollokType(clazz, this)
	}

	override objectType(EObject context, String objectFQN) {
		finder.getCachedObject(context, objectFQN).objectType
	}

	override classType(EObject context, String classFQN) {
		finder.getCachedClass(context, classFQN).classType
	}

	def findType(EObject context, String typeName) {
		// TODO Este método debería volar cuando terminemos las nuevas type annotations.
		try {
			new ClassBasedWollokType(finder.getCachedClass(context, typeName), this)
		} catch (WollokRuntimeException e) {
			new NamedObjectWollokType(finder.getCachedObject(context, typeName), this)
		}
	}
	
	def allTypes(EObject context) {
		finder.allClasses(context).map[new ClassBasedWollokType(it, this)] 
		+ 
		finder.allGlobalObjects(context).map[new NamedObjectWollokType(it, this)]
	}
}
