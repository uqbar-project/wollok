package org.uqbar.project.wollok.typesystem.substitutions

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.typesystem.WollokType

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * A terminal rule. 
 * A rule which is already types/defined from startup.
 * For example a literal.
 * 
 * @author jfernandes
 */
class FactTypeRule extends TypeRule {
	@Property EObject model
	@Property WollokType type
	
	new(EObject source, EObject obj, WollokType type) {
		super(source)
		model = obj
		this.type = type
	}
	
	override resolve(SubstitutionBasedTypeSystem system) { false }
	
	override typeOf(EObject object) { if (object == model) type else null }
	
	// object
	override toString() { '''t(«model.sourceCode.trim.replaceAll(System.lineSeparator, ' ')») = «type»''' + "\t\t\t\t(" + source.lineNumber + ": " + source.sourceCode.trim.replaceAll(System.lineSeparator, ' ') + ")" }
	override equals(Object obj) {
		obj instanceof FactTypeRule && model == (obj as FactTypeRule).model && type == (obj as FactTypeRule).type 
	}
	
	override hashCode() { model.hashCode / type.hashCode }
	
}