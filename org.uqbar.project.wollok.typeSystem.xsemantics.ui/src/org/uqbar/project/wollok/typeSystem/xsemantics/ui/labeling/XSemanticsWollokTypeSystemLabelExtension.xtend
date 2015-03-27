package org.uqbar.project.wollok.typeSystem.xsemantics.ui.labeling

import com.google.inject.Inject
import it.xsemantics.runtime.Result
import it.xsemantics.runtime.RuleEnvironment
import it.xsemantics.runtime.RuleFailedException
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem
import org.uqbar.project.wollok.semantics.WollokType
import org.uqbar.project.wollok.ui.labeling.WollokTypeSystemLabelExtension
import org.uqbar.project.wollok.wollokDsl.WFile

class XSemanticsWollokTypeSystemLabelExtension implements WollokTypeSystemLabelExtension {
	@Inject
	protected WollokDslTypeSystem xsemanticsSystem

	// y cuando se limpia esto ?
	Map<Resource, RuleEnvironment> resolvedTypes = newHashMap()

	def typeToString(Result r) {
		if (r.failed) {
			r.ruleFailedException.printStackTrace
			"???"
		} else
			r.first
	}

	def getEnv(EObject obj) {
		val env = xsemanticsSystem.emptyEnvironment
		resolvedTypes.put(obj.eResource, env)

		// infer types for whole program.
		val content = (obj.eResource.contents.filter(WFile).head)
		val r = xsemanticsSystem.inferTypes(env, content)
		if (r.failed) {
			println("FAILED TYPE CHECKING THROUGH LABEL PROVIDER: " + r.ruleFailedException.message)
			r.ruleFailedException.printStackTrace()
		}
		resolvedTypes.get(obj.eResource)
	}

	override resolvedType(EObject o){
		val x = this.doResolvedType(o)
		if(x == null) 
			null
		else
			x.toString
	}

	def doResolvedType(EObject o) {
		try
			xsemanticsSystem.env(o.getEnv, o, WollokType)
		catch (RuleFailedException e) {
			val node = NodeModelUtils.getNode(o)
			println(
				"FAILED TO INFER TYPE FOR: " + o.eResource.URI + "[" + node.textRegionWithLineInformation.lineNumber +
					"]: " + node.text)
			WollokType.WAny
		}
	}

}
