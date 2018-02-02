package org.uqbar.project.wollok.typesystem.bindings

import com.google.inject.Inject
import java.util.List
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import static org.uqbar.project.wollok.typesystem.TypeSystemUtils.*
import static org.uqbar.project.wollok.typesystem.WollokType.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * An attempt to avoid directly manipulating xsemantics environment
 * map.
 *
 * @author jfernandes
 */
class BoundsBasedTypeSystem implements TypeSystem {
	Map<EObject, TypedNode> nodes = newHashMap()
	List<TypeBound> bounds = newArrayList
	@Inject WollokClassFinder finder

	val Logger log = Logger.getLogger(this.class)

	override def name() { "Bounds Based" }
	
	override initialize(EObject program) {
		// No initialization required
	}

	override validate(WFile file, ConfigurableDslValidator validator) {
		log.debug("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes
		this.reportErrors(validator)
	}

	override def reportErrors(ConfigurableDslValidator validator) {
		// TODO: report errors !
	}


	// node factory methods

	def fixedNode(WollokType fixedType, EObject obj) {
		new ValueTypedNode(obj, fixedType, this) => [ nodes.put(obj, it) ]
	}

	def fixedNode(WollokType fixedType, EObject obj, (ExpectationBuilder)=>void expectationsBuilder) {
		fixedNode(fixedType, obj).setupExpectations(expectationsBuilder)
	}

	def inferredNode(EObject obj) {
		new TypeInferedNode(obj, this) => [ nodes.put(obj, it) ]
	}

	def inferredNode(EObject obj, (ExpectationBuilder)=>void expectationsBuilder) {
		inferredNode(obj).setupExpectations(expectationsBuilder)
	}

	def setupExpectations(TypedNode n, (ExpectationBuilder)=>void expectationsBuilder) {
		expectationsBuilder.apply(new ExpectationBuilder(this, n))
		n
	}

	def getNode(EObject obj) {
		if (!nodes.containsKey(obj))
			obj.bind
		nodes.get(obj)
	}

	/**
	 * # 2
	 * Second step. Goes through all the bindings and tries to infer types.
	 */
	override inferTypes() {
		bounds.forEach[inferTypes]
	}

	/**
	 * # 3
	 * Third step. Asks each node individually for errors (type expectation violations).
	 */
	override issues(EObject obj) {
		obj.node.issues
	}

	/**
	 * Returns the resolved type for the given object.
	 * This must be called after "inferTypes" step.
	 */
	override type(EObject obj) {
		obj.node.type
	}

	override analyse(EObject o) {
		bind(o)
	}

	// **********************************************************************
	// ** bind (first steps: builds up a graph with all types relations)
	// **********************************************************************

	def dispatch void bind(WFile p) {
		p.inferredNode
			p.elements.forEach[bind]
	}
	
	def dispatch void bind(WSelf p) {
		p.inferredNode
			p <=> p.declaringContext
	}

	def dispatch void bind(WProgram p) {
		p.inferredNode
		p.elements.forEach[bind]
		p <=> p.elements.last
	}

	def dispatch void bind(WClass c) {
		new ClassBasedWollokType(c, this).fixedNode(c)
		c.variableDeclarations.forEach[bind]
		c.methods.forEach[bind]
	}

	def dispatch void bind(WBlockExpression e) {
		e.inferredNode
		e.expressions.forEach[bind]
		e <=> e.expressions.last
	}

	def dispatch void bind(WVariableDeclaration v) {
		v.inferredNode [extension b|
			if (v.right !== null)
				v >= v.right
		]
	}
	
	def dispatch void bind(WVariable v) {
		v.inferredNode
	}

	def dispatch void bind(WVariableReference v) {
		v.inferredNode
			v <=> v.ref
	}
	
	def dispatch void bind(WReturnExpression v) {
		v.inferredNode
			v <=> v.expression
	}

	def dispatch void bind(WAssignment a) {
		WVoid.fixedNode(a) [extension b |
			a.feature >= a.value
		]
	}

	def dispatch void bind(WBinaryOperation op) {
		val opType = typeOfOperation(op.feature)
		op.classType(opType.value).fixedNode(op) [extension b |
			op.leftOperand <<< op.classType(opType.key.get(0))
			op.rightOperand <<< op.classType(opType.key.get(1))

			op.leftOperand <=> op.rightOperand
		]
	}

	def dispatch void bind(WIfExpression ef) {
		ef.inferredNode [extension b|
			ef.condition <<< ef.classType(BOOLEAN)
			ef <=> ef.then
			ef <=> ef.^else
		]
	}

	def dispatch void bind(WMethodDeclaration m) {
		m.inferredNode[extension b|
			if (m.overrides) {
				m.overridenMethod >= m;
			}
			m <=> m.expression
		]
	}

	def dispatch void bind(WParameter p) { p.inferredNode }

	// literals
	def dispatch void bind(WNullLiteral p) { p.inferredNode }
	def dispatch void bind(WNumberLiteral it) {
		val type = classType(NUMBER) 
		type.fixedNode(it)
	}
	def dispatch void bind(WStringLiteral it) { classType(STRING).fixedNode(it) }
	def dispatch void bind(WBooleanLiteral it) { classType(BOOLEAN).fixedNode(it) }

	def dispatch void bind(WMemberFeatureCall call) {
		call.inferredNode
		// solo se vincula con un método de this
		if (call.memberCallTarget instanceof WSelf) {
			val referencedMethod = call.method.declaringContext.lookupMethod(call.feature, call.memberCallArguments, true)
			call <=> referencedMethod
		}
	}

	// **********************************
	// ** bindings
	// **********************************

	def bindExactlyTo(TypedNode from, TypedNode to) {
		bounds.add(new ExactTypeBound(from, to))
	}

	def bindAsSuperTypeOf(TypedNode bindSource, TypedNode from, TypedNode to) {
		bounds.add(new SuperTypeBound(bindSource, from, to))
	}

	def bindAsSuperTypeOf(TypedNode from, TypedNode to) {
		bounds.add(new SuperTypeBound(from, to))
	}

	// DSL

	def operator_spaceship(EObject from, EObject to) {
		from.node.bindExactlyTo(to.node)
	}

	def operator_tripleLessThan(EObject obj, WollokType expected) {
		obj.node.expectType(expected)
	}

	def getBounds(TypedNode node) {
		bounds.filter[b| b.isFor(node)]
	}

	// others

	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	protected def ClassBasedWollokType classType(EObject model, String className) {
		val clazz = finder.getCachedClass(model, className)
		// REVIEWME: should we have a cache ?
		new ClassBasedWollokType(clazz, this)
	}
}