package org.uqbar.project.wollok.model

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.WLibrary

/**
 * Extension methods for WMethodContainers.
 * 
 * @author jfernandes
 */
class WMethodContainerExtensions {
	
	def static namedObjects(WPackage p){p.elements.filter(WNamedObject)}
	def static namedObjects(WLibrary p){p.elements.filter(WNamedObject)}
	
	def static methods(WMethodContainer c) { c.members.filter(WMethodDeclaration) }
	def static variableDeclarations(WMethodContainer c) { c.members.filter(WVariableDeclaration) }

	def static variables(WMethodContainer c) { c.variableDeclarations.variables }
	def static variables(WProgram p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(Iterable<WVariableDeclaration> declarations) { declarations.map[variable] }
	
	def static dispatch allMethods(WNamedObject o) { o.methods }
	def static dispatch allMethods(WObjectLiteral o) { o.methods }
	def static dispatch allMethods(WClass c) {
		val methods = newArrayList
		c.superClassesIncludingYourselfTopDownDo[cl |
			// remove overriden
			cl.overrideMethods.forEach[methods.remove(it.overridenMethod)]
			// add all
			methods.addAll(cl.methods)
		]
		methods
	}
	
	def static dispatch WClass parent(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch WClass parent(WClass c) { c.parent }
	def static dispatch WClass parent(WObjectLiteral c) { null } // For now, object literals do not allow superclasses
	def static dispatch WClass parent(WNamedObject c) { null } // For now, object literals do not allow superclasses

	def static dispatch members(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch members(WClass c) { c.members }
	def static dispatch members(WObjectLiteral c) { c.members }
	def static dispatch members(WNamedObject c) { c.members }
	
	def static dispatch contextName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch contextName(WClass c) { c.fqn }
	def static dispatch contextName(WObjectLiteral c) { "<anonymousObject>" }
	def static dispatch contextName(WNamedObject c) { c.fqn }
	
	def static dispatch boolean inheritsMethod(WMethodContainer c, String name) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch boolean inheritsMethod(WClass c, String name) { c.parent != null && c.parent.hasOrInheritMethod(name) }
	def static dispatch boolean inheritsMethod(WObjectLiteral c, String name) { false }
	def static dispatch boolean inheritsMethod(WNamedObject c, String name) { false }
	
	def static boolean hasOrInheritMethod(WClass c, String mname) { 
		c != null && (c.methods.exists[name == mname] || c.parent.hasOrInheritMethod(mname))
	}

	def static WMethodDeclaration lookupMethod(WMethodContainer behavior, String message) { 
		val method = behavior.methods.findFirst[name == message]
		
		if (method != null) 
			return method
		else if (behavior.parent != null)
			behavior.parent.lookupMethod(message)
		else 
			null
	}

	// ************************************************************************
	// ** Basic methods
	// ************************************************************************

	def static void superClassesIncludingYourselfTopDownDo(WClass cl, (WClass)=>void action) {
		if (cl.parent != null) cl.parent.superClassesIncludingYourselfTopDownDo(action)
		action.apply(cl)
	}
	
	def static <R> R foldUp(WClass cl, R initialValue, (R, WClass)=>R action) {
		val nextValue = action.apply(initialValue, cl)
		if (cl.parent != null) 
			cl.parent.foldUp(nextValue, action)
		else 
			nextValue 
	}
	
	// ** native **
	
	def static Object createNativeObject(WClass it, WollokObject obj, WollokInterpreter interpreter) {
		val javaClass = Class.forName(fqn)
		try
			javaClass.getConstructor(WollokObject, WollokInterpreter).newInstance(obj, interpreter)
		catch (NoSuchMethodException e)
			javaClass.newInstance
	}
	
	// ************************************************************************
	// ** isKindOf(c1, c2): Tells whether c1 is a type or subtype of c2
	// ** TODO: think if this can be a
	// ************************************************************************	

	def static dispatch isKindOf(WMethodContainer c1, WMethodContainer c2) { c1 == c2 }
	def static dispatch isKindOf(WClass c1, WClass c2) { WollokModelExtensions.isSuperTypeOf(c2, c1) }

}