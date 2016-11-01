package org.uqbar.project.wollok.typesystem.constraints

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * @author npasserini
 */
class ConstraintBasedTypeSystem implements TypeSystem {
	@Inject WollokClassFinder finder
	
	@Accessors
	val extension TypeVariablesRegistry registry = new TypeVariablesRegistry(this)
	
	override def name() { "Constraints-based" }
	
	override validate(WFile file, WollokDslValidator validator) {
		println("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes
		// TODO: report errors !
	}

	// ************************************************************************
	// ** Analysis
	// ************************************************************************
	
	override analyse(EObject p) {
		new ConstraintGenerator(this).generateVariables(p)
	}
	

	// ************************************************************************
	// ** Inference
	// ************************************************************************
	
	override inferTypes() {
		println("Starting inference")
		SealVariables.runStrategy
		
		var Boolean globalChanged
		do {
			val results = newArrayList 
			#[PropagateMinimalTypes, PropagateMaximalTypes].forEach[results.add(runStrategy)]
			globalChanged = results.exists[it]
		} while (globalChanged)
		
		registry.fullReport
	}
	
	def runStrategy(Class<? extends AbstractInferenceStrategy> it) {
		(newInstance => [it.registry = this.registry]).run()			
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
	
	protected def ClassBasedWollokType classType(EObject model, String className) {
		val clazz = finder.getCachedClass(model, className)
		// REVIEWME: should we have a cache ?
		new ClassBasedWollokType(clazz, this)
	}

}
