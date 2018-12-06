package org.uqbar.project.wollok.typesystem.constraints

import com.google.inject.Inject
import java.util.List
import java.util.Map
import java.util.Set
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.typesystem.ClassInstanceType
import org.uqbar.project.wollok.typesystem.ClosureType
import org.uqbar.project.wollok.typesystem.Constants
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.MessageType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.NamedObjectType
import org.uqbar.project.wollok.typesystem.TypeFactory
import org.uqbar.project.wollok.typesystem.TypeProvider
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.annotations.CollectionTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.DateTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.ExceptionTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.NumberTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.StringTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.WollokCoreTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.WollokGameTypeDeclarations
import org.uqbar.project.wollok.typesystem.annotations.WollokLibTypeDeclarations
import org.uqbar.project.wollok.typesystem.constraints.strategies.AbstractInferenceStrategy
import org.uqbar.project.wollok.typesystem.constraints.strategies.GuessMinTypeFromMaxType
import org.uqbar.project.wollok.typesystem.constraints.strategies.MaxTypesFromMessages
import org.uqbar.project.wollok.typesystem.constraints.strategies.OpenMethod
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMaximalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.PropagateMinimalTypes
import org.uqbar.project.wollok.typesystem.constraints.strategies.SealVariables
import org.uqbar.project.wollok.typesystem.constraints.strategies.UnifyVariables
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.scoping.WollokResourceCache.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.fqn
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

	@Accessors
	List<EObject> programs = newArrayList

	ConstraintGenerator constraintGenerator

	/**
	 * The collection of concrete types that are known to be generic, indexed by its FQN.
	 */
	Map<String, GenericType> genericTypes = newHashMap

	/** 
	 * TypeFactories include both actual concrete types such as class types and object types, 
	 * but also parametric types that need to be instantiated to create a type, such as Collection<T>
	 */
	Set<TypeFactory> allTypes

	override def name() { Constants.TS_CONSTRAINTS_BASED }

	override validate(WFile file, ConfigurableDslValidator validator) {
		// Dodain - only Builder now is responsible for analyzing and inferring types
		//this.analyse(file)
		//this.inferTypes
		log.info('''Reporting type errors of «file.eResource.URI.lastSegment» using «class.simpleName»''')
		file.reportErrors(validator)
	}

	// ************************************************************************
	// ** Analysis
	// ************************************************************************
	override initialize(EObject program) {
		registry = new TypeVariablesRegistry(this)
		programs = newArrayList
		constraintGenerator = new ConstraintGenerator(this)
		genericTypes = newHashMap
		allTypes = null

		// This shouldn't be necessary if all global objects had type annotations
		allCoreWKOs.forEach[newTypeVariable.beSealed(objectType)]

		annotatedTypes = new AnnotatedTypeRegistry(registry) => [
			addTypeDeclarations(this, program,
				NumberTypeDeclarations,
				StringTypeDeclarations,
				DateTypeDeclarations,
				CollectionTypeDeclarations,
				ExceptionTypeDeclarations,
				WollokLibTypeDeclarations,
				WollokGameTypeDeclarations,
				WollokCoreTypeDeclarations // Must be the last one
			)
		]
	}

	override analyse(EObject program) {
		if (registry === null) {
			initialize(program)
		}

		programs.add(program)
	}

	// ************************************************************************
	// ** Inference
	// ************************************************************************
	override inferTypes() {
		programs.forEach[constraintGenerator.addGlobals(it)]
		programs.forEach[constraintGenerator.generateVariables(it)]

		// These constraints have to be created after all files have been `analise`d
		constraintGenerator.addCrossReferenceConstraints

		var currentStage = 0

		log.debug("Starting inference")

		do {
			log.debug("Running stage " + currentStage)

			if (runStage(stages.get(currentStage)))
				// Stage produced new information, start again from stage 0. 
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
		#[PropagateMinimalTypes],
		#[OpenMethod],
		#[UnifyVariables],
		#[PropagateMaximalTypes, MaxTypesFromMessages],
		#[SealVariables],
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
	override reportErrors(WFile file, ConfigurableDslValidator validator) {
		typeVariablesFrom(file.eResource.URI).forEach [ reportErrors(validator) ]
	}

	// ************************************************************************
	// ** Other (TBD)
	// ************************************************************************
	override type(EObject obj) {
		registry?.type(obj)
	}

	override issues(EObject obj) {
		#[]
	}

	override queryMessageTypeForMethod(WMethodDeclaration it) {
		new MessageType(it, parameters.map[type], type)
	}

	def objectType(WNamedObject model) {
		new NamedObjectType(model, this)
	}

	def classType(WClass clazz) {
		if (genericTypes.containsKey(clazz.fqn)) {
			throw new IllegalArgumentException(NLS.bind(Messages.RuntimeTypeSystemException_GENERIC_TYPE_MUST_BE_INSTANTIATED, clazz.fqn))	
		}

		new ClassInstanceType(clazz, this)
	}

	def genericType(WClass clazz, String... typeParameterNames) {
		genericTypes.get(clazz.fqn) ?: (
			new GenericType(clazz, this, typeParameterNames) => [
				genericTypes.put(clazz.fqn, it)
			]
		)
	}

	override objectType(EObject context, String objectFQN) {
		finder.getCachedObject(context, objectFQN).objectType
	}

	/**
	 * Before constructing a class type, check if the provided FQN is known to be a generic type.
	 * If so, this is an error.
	 * Otherwise create a simple class type. 
	 */
	override classType(EObject context, String classFQN) {
		if (classFQN == WollokDSK.CLOSURE) 
			throw new IllegalArgumentException(Messages.RuntimeTypeSystemException_WRONG_WAY_CLOSURE_TYPE)

		if (genericTypes.containsKey(classFQN)) {
			throw new IllegalArgumentException(NLS.bind(Messages.RuntimeTypeSystemException_GENERIC_TYPE_MUST_BE_INSTANTIATED, classFQN))	
		}  
		
		finder.getCachedClass(context, classFQN).classType
	}

	/**
	 * Build a generic type and save it, so that we know which concrete types are known to be generic.
	 */
	override genericType(EObject context, String classFQN, String... typeParameterNames) {
		if (classFQN == WollokDSK.CLOSURE) 
			throw new IllegalArgumentException(Messages.RuntimeTypeSystemException_WRONG_WAY_CLOSURE_TYPE)

		finder.getCachedClass(context, classFQN).genericType(typeParameterNames) => [
			genericTypes.put(classFQN, it)
		]
	}

	override closureType(EObject context, int parameterCount) {
		val typeParameterNames = #[GenericTypeInfo.RETURN] + GenericTypeInfo.PARAMS(parameterCount)
		new ClosureType(finder.getClosureClass(context), this, typeParameterNames)
	}

	/**
	 * Not all classes are actual types, as some have type parameters and therefore are generic types (aka type factories).
	 */
	def TypeFactory typeOrFactory(WClass clazz) {
		genericTypes.get(clazz.fqn) ?: new ClassInstanceType(clazz, this)
	}

	/**
	 * All types knows all objects and classes in the system. As some classes can be generic, they do not define
	 * actual types, but "type factories" such as List<E>, which is not an actual type, but a function that
	 * applied to an actual type will give a type. E.g. applied to Number you get a List<Number> which is a real type for an object.
	 * 
	 * User must instantiate type factories before usage.
	 */
	override getAllTypes() {
		if (allTypes === null) {
			// Initialize with core classes and wkos, then type system will add own classes incrementally.
			allTypes = newHashSet
			allTypes.addAll(allCoreClasses.reject[fqn == WollokDSK.CLOSURE].map[typeOrFactory])
			allTypes.addAll(allCoreWKOs.map[objectType])
		}
		
		allTypes
	}
}
