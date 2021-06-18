package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.visitors.AbstractWollokVisitor
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAncestor
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WNamedArgumentsList
import org.uqbar.project.wollok.wollokDsl.WPositionalArgumentsList
import org.uqbar.project.wollok.wollokDsl.WProgram

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject

class GuessMinTypeFromMaxType extends SimpleTypeInferenceStrategy {
	extension GuessMinTypeVisitor = new GuessMinTypeVisitor(this)
	val Logger log = Logger.getLogger(this.class)

	override walkThrougProgram() {
		changed = false
		allFiles.forEach[visit]
		globalChanged = changed
	}

	def dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		if(minTypes.isEmpty && maximalConcreteTypes !== null) {
			maximalConcreteTypes.forEach [ type |
				val state = handlingOffensesDo(tvar, tvar)[tvar.addMinType(type)]
				log.debug('''  Added min type «type» to «tvar» => «state»''')
				if(state != Ready) changed = true
			]
		}
	}
}

class GuessMinTypeVisitor extends AbstractWollokVisitor {
	extension GuessMinTypeFromMaxType strategy

	new(GuessMinTypeFromMaxType strategy) {
		this.strategy = strategy
	}

	/** We will stop visits after a change is found */
	override dispatch shouldVisit(EObject e) { !changed && e.eResource !== null && !e.isCoreObject }

	/** Execute actions after visiting child nodes */
	override dispatch afterVisit(EObject it) {
		if (shouldVisit) analiseVariable(tvar)
	}

	// Avoid visiting objects that do not have associated type variables 
	def dispatch afterVisit(WFile it) {}
	def dispatch afterVisit(WProgram it) {}
	def dispatch afterVisit(WClass it) {}
	def dispatch afterVisit(WInitializer it) {}
	def dispatch afterVisit(WCatch it) {}
	def dispatch afterVisit(Import it) {}
	def dispatch afterVisit(WPositionalArgumentsList it) {}
	def dispatch afterVisit(WNamedArgumentsList it) {}
	def dispatch afterVisit(WAncestor it) {}

	override dispatch void visitChildren(WAssignment it) {
		// We are not generating type variables for the reference in an assignment.
		// feature.visit
		value.visit
	}

	override dispatch void visitChildren(WInitializer it) {
		// We are not generating type variables for the variable reference in an initializer
		// initializer.visit
		initialValue.visit
	}
	
}
