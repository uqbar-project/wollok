package org.uqbar.project.wollok.typesystem.constraints

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.NamedObjectWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.constraints.strategies.AbstractInferenceStrategy
import org.uqbar.project.wollok.typesystem.constraints.strategies.GuessMinTypeFromMaxType
import org.uqbar.project.wollok.typesystem.constraints.strategies.OpenMethod
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMaximalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMinimalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.SealVariables
import org.uqbar.project.wollok.typesystem.constraints.strategies.UnifyVariables
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * @author npasserini
 */
class ConstraintBasedTypeSystem implements TypeSystem {
	@Inject WollokClassFinder finder

	@Accessors
	val extension TypeVariablesRegistry registry = new TypeVariablesRegistry(this)

	val constraintGenerator = new ConstraintGenerator(this)

	override def name() { "Constraints-based" }

	override validate(WFile file, ConfigurableDslValidator validator) {
		println("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes

		reportErrors(validator)
	}

	// ************************************************************************
	// ** Analysis
	// ************************************************************************
	override analyse(EObject p) {
		constraintGenerator.generateVariables(p)
	}

	// ************************************************************************
	// ** Inference
	// ************************************************************************
	override inferTypes() {
		// These constraints have to be created after all files have been `analise`d
		constraintGenerator.addInheritanceConstraints
		
		var currentStage = 0

		println("Starting inference")

		do {
			println("Running stage " + currentStage)
			
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
		#[PropagateMinimalTypes, PropagateMaximalTypes],
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
		allVariables.forEach[it.reportErrors(validator)]
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

	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	protected def objectType(WNamedObject model) {
		new NamedObjectWollokType(model, this)
	}

	def classType(EObject model, String className) {
		val clazz = finder.getCachedClass(model, className)
		// REVIEWME: should we have a cache ?
		classType(clazz)
	}

	protected def ClassBasedWollokType classType(WClass clazz) {
		new ClassBasedWollokType(clazz, this)
	}

}
