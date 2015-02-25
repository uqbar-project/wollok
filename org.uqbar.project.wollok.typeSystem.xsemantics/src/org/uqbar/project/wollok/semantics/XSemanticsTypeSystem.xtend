package org.uqbar.project.wollok.semantics

import com.google.inject.Inject
import it.xsemantics.runtime.RuleFailedException
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.wollokDsl.WProgram
import it.xsemantics.runtime.RuleEnvironment

/**
 * Type system implementation based on xsemantics
 * 
 * @author jfernandes
 */
class XSemanticsTypeSystem implements TypeSystem {
	@Inject
  	protected WollokDslTypeSystem xsemanticsSystem
	RuleEnvironment env
  	
	
	override analyse(EObject p) {
		env = xsemanticsSystem.emptyEnvironment;
		// infer types for whole program.
		p.eContents.forEach[e|
			xsemanticsSystem.inferTypes(env, e)
		]
	}
	
	def resolvedType(EObject o) {
		try 
			xsemanticsSystem.env(env, o, WollokType)
		catch (RuleFailedException e) {
			val node = NodeModelUtils.getNode(o)
			println("FAILED TO INFER TYPE FOR: " + o.eResource.URI + "[" + node.textRegionWithLineInformation.lineNumber + "]: " + node.text)
			println(">> " + e.message)
			WollokType.WAny
		}
	}
	
	override type(EObject obj) { resolvedType(obj) }
	
	// ******************************
	
	override inferTypes() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override issues(EObject obj) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}