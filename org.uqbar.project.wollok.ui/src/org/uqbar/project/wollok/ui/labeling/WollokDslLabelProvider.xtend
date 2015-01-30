package org.uqbar.project.wollok.ui.labeling

import com.google.inject.Inject
import it.xsemantics.runtime.Result
import it.xsemantics.runtime.RuleEnvironment
import it.xsemantics.runtime.RuleFailedException
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem
import org.uqbar.project.wollok.semantics.WollokType
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Provides labels for EObjects.
 * 
 * @author jfernandes
 */
class WollokDslLabelProvider extends DefaultEObjectLabelProvider {
	@Inject
  	protected WollokDslTypeSystem xsemanticsSystem
  	// y cuando se limpia esto ?
	Map<Resource, RuleEnvironment> resolvedTypes = newHashMap()

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate)
	}
	
	def typeToString(Result r) {
		if (r.failed) {
			r.ruleFailedException.printStackTrace
			"???"
		}
		else 
			r.first
	}
	
	def getEnv(EObject obj) {
//		if (!resolvedTypes.containsKey(obj.eResource)) {
			val env = xsemanticsSystem.emptyEnvironment
			resolvedTypes.put(obj.eResource, env)
			// infer types for whole program.
			val content = (obj.eResource.contents.filter(WFile).head)
			val r = xsemanticsSystem.inferTypes(env, content)
			if (r.failed) {
				println("FAILED TYPE CHECKING THROUGH LABEL PROVIDER: " + r.ruleFailedException.message)
				r.ruleFailedException.printStackTrace()
			}				
//		}
		resolvedTypes.get(obj.eResource)
	}
	
	def resolvedType(EObject o) {
		try 
			xsemanticsSystem.env(o.getEnv, o, WollokType)
		catch (RuleFailedException e) {
			val node = NodeModelUtils.getNode(o)
			println("FAILED TO INFER TYPE FOR: " + o.eResource.URI + "[" + node.textRegionWithLineInformation.lineNumber + "]: " + node.text)
			WollokType.WAny
		}
	}
	
	def image(WPackage ele) { 'package.png' }
	def image(WProgram ele) { 'wollok-icon-program_16.png' }
	def image(WClass ele) {	'wollok-icon-class_16.png' }
	
	def text(WObjectLiteral ele) { 'object' }
	def image(WObjectLiteral ele) {	'wollok-icon-object_16.png' }
	
	def text(WVariableDeclaration it) { 
		(if(writeable) "var " else "val ") + variable.name + ": " + variable.resolvedType
	}
	def image(WVariableDeclaration ele) { 'wollok-icon-variable_16.png' }

	def text(WVariable ele) { ele.name + ": " + ele.resolvedType }
	def image(WVariable ele) 	{ 'variable.gif' }
	
	def text(WParameter p) { textForParam(p) }
	def image(WParameter ele) { 'variable.gif' }
	
	def textForParam(WReferenciable p) { // solo para wparam y wclosureparam
		p.name + ": " + p.resolvedType
	}
	
	def text(WMethodDeclaration m) { 
		m.name + '(' + m.parameters.map[name + " " + resolvedType ].join(',') + ') : ' + m.resolvedType 
	}
	def text(WConstructor m) {
		'new(' + m.parameters.map[name + " " + resolvedType].join(',') + ')'
	}
	
	def image(WMethodDeclaration ele) { 'wollok-icon-method_16.png' }
	
	def text(WMemberFeatureCall ele) { ele.feature + '(' + ele.memberCallArguments.map[doGetText(it)].join(',') + ')' }
	def image(WMemberFeatureCall ele) { 'wollok-icon-message_16.png' }
	
	def image(WVariableReference ele) { 'pointer.jpg' }
	def image(WAssignment a) { 'assignment.jpg' }
	
	def image(WNumberLiteral l) { 'number.png' }
	def image(WStringLiteral l) { 'string.png' }
	
}
