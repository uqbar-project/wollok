package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

abstract class CrossReferenceConstraintsGenerator<T extends EObject> {
	protected extension TypeVariablesRegistry registry
	protected List<T> eObjects = newArrayList

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def add(T eObject) {
		eObjects.add(eObject)
	}

	def run() {
		eObjects.forEach[generate]
	}

	def abstract void generate(T it)

	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	def beAllSupertypeOf(Iterable<ITypeVariable> supertypes, Iterable<ITypeVariable> subtypes) {
		supertypes.biForEach(subtypes) [ supertype, subtype |
			supertype.beSupertypeOf(subtype)
		]
	}
	
	def beAllSubtypeOf(Iterable<ITypeVariable> subtypes, Iterable<ITypeVariable> supertypes) {
		supertypes.beAllSupertypeOf(subtypes)
	}
	
	def beAllSupertypeOf(EList<? extends EObject> supertypes, EList<? extends EObject> subtypes) {
		supertypes.map[tvarOrParam].beAllSupertypeOf(subtypes.map[tvarOrParam])
	}
	
	def beAllSubtypeOf(EList<? extends EObject> subtypes, EList<? extends EObject> supertypes) {
		supertypes.beAllSupertypeOf(subtypes)
	}
}
