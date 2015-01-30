package org.uqbar.project.wollok.typesystem.bindings

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.semantics.WollokType

/**
 * An AST node complemented with typing information.
 * There are two different nodes:
 *  those that already come from the AST with type information (FixedTypeNode)
 *  and those that don't and therefore should be inferred.
 * 
 * @author jfernandes
 */
abstract class TypedNode {
	List<TypingListener> listeners = newArrayList
	protected EObject model
	BoundsBasedTypeSystem system
	List<TypeExpectation> expectations = newArrayList
	
	new(EObject object, BoundsBasedTypeSystem typeSystem) {
		model = object
		system = typeSystem
	}
	
	// used by second step
	def void inferTypes() {}
	
	// resolving types
	def void assignType(WollokType type) {}
	
	def WollokType getType()
	def getModel() { model }

	// ********** expectations ************
	
	var List<TypeExpectationFailedException> errors = newArrayList
	
	def issues() {
		expectations.fold(newArrayList) [ issues, expect |
			try
				expect.check(type)
			catch (TypeExpectationFailedException e) {
				e.setModel(this.model)
				issues += e
			}
			issues
		] + errors
	}
	
	def addError(TypeExpectationFailedException e) {
		errors += e
	}
	
	def void addExpectation(TypeExpectation expectation) {
		expectations += expectation
	}
	
	def void expectType(WollokType type) {
		addExpectation(new ExactTypeExpectation(type))
	}
	
	// ********** listeners ************
	
	def void addListener(TypingListener listener) { listeners += listener }
	def void removeListener(TypingListener listener) {	listeners -= listener }
	def fireTypeChanged() { 
		listeners.clone.forEach[notifyTypeSet(type)]
	}
	
}