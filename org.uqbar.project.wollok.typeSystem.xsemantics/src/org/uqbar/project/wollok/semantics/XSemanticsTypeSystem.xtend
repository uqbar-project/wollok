package org.uqbar.project.wollok.semantics

import com.google.inject.Inject
import it.xsemantics.runtime.RuleEnvironment
import it.xsemantics.runtime.RuleFailedException
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * Type system implementation based on xsemantics
 * 
 * @author jfernandes
 */
class XSemanticsTypeSystem implements TypeSystem {
	public static val NAME = "XSemantics"
	@Inject
	protected ExtendedXSemanticsWollokDsl xsemanticsSystem
	RuleEnvironment env
	val Logger log = Logger.getLogger(this.class)
	

	override def name() { NAME }

	override initialize(EObject program) {
		// Nothing to do
	}

	override validate(WFile file, ConfigurableDslValidator validator) {
		log.debug("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
//		xsemanticsSystem.validate(file, validator)
		this.analyse(file)
		this.reportErrors(validator)
	}

	override def reportErrors(ConfigurableDslValidator validator) {
		// TODO: report errors !
	}

	override analyse(EObject p) {

		env = xsemanticsSystem.emptyEnvironment;
		env.add(TypeSystem, this)
		// infer types for whole program.
		p.eContents.forEach [ e |
			xsemanticsSystem.inferTypes(env, e)
		]
	}

	def resolvedType(EObject o) {
		try
			xsemanticsSystem.env(env, o, WollokType)
		catch (RuleFailedException e) {
			val node = NodeModelUtils.getNode(o)
			log.error(
				"FAILED TO INFER TYPE FOR: " + o.eResource.URI + "[" + node.textRegionWithLineInformation.lineNumber +
					"]: " + node.text + " >> " + e.message)
			WollokType.WAny
		}
	}

	override type(EObject obj) { resolvedType(obj) }

	// ******************************
	override inferTypes() {
		// same
	}

	override issues(EObject obj) {
		// does nothing. xsemantics works in a different way
		#[]
	}

	override queryMessageTypeForMethod(WMethodDeclaration m) {
		xsemanticsSystem.queryMessageTypeForMethod(env, m).first
	}

}
