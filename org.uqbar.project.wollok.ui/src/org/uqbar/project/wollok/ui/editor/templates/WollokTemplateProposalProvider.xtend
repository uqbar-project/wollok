package org.uqbar.project.wollok.ui.editor.templates

import com.google.inject.Inject
import org.eclipse.jface.text.templates.ContextTypeRegistry
import org.eclipse.jface.text.templates.Template
import org.eclipse.jface.text.templates.TemplateContext
import org.eclipse.jface.text.templates.persistence.TemplateStore
import org.eclipse.xtext.AbstractElement
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ITemplateAcceptor
import org.eclipse.xtext.ui.editor.templates.ContextTypeIdHelper
import org.eclipse.xtext.ui.editor.templates.DefaultTemplateProposalProvider
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import org.uqbar.project.wollok.ui.Messages

/**
 * Provides code templates for the editor.
 * 
 * @author jfernandes
 */
class WollokTemplateProposalProvider extends DefaultTemplateProposalProvider {
	ContextTypeIdHelper helper
	@Inject
	extension WollokDslGrammarAccess ga;
	
	@Inject
	new(TemplateStore templateStore, ContextTypeRegistry registry, ContextTypeIdHelper helper) {
		super(templateStore, registry, helper)
		this.helper = helper
	}
	
  override createTemplates(TemplateContext templateContext, ContentAssistContext context, ITemplateAcceptor acceptor) {
    //"regular templates"
    super.createTemplates(templateContext, context, acceptor)
    

	addTemplate(WProgramRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createProgram_name, Messages.WollokTemplateProposalProvider_createProgram_description, "org.uqbar.project.wollok.createprogram", context,
'''program ${programName} {
	
}''')

    
	addTemplate(WLibraryElementRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createPackage_name, Messages.WollokTemplateProposalProvider_createPackage_description, "org.uqbar.project.wollok.createpackage", context,
'''package ${packageName} {
	
}''')

	//todo: class icon
	addTemplate(WClassRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createClass_name, Messages.WollokTemplateProposalProvider_createClass_description, "org.uqbar.project.wollok.createclass", context,
'''class ${ClassName} {
	
}''')

	//todo: object icon
	addTemplate(WObjectLiteralRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createObject_name, Messages.WollokTemplateProposalProvider_createObject_description, "org.uqbar.project.wollok.createobject", context,
'''object {
	
}''')

	//TODO: poder seleccionar entre "var/val"
	addTemplate(WVariableDeclarationRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createReference_name, Messages.WollokTemplateProposalProvider_createReference_description, "org.uqbar.project.wollok.objectaddReference", context,
'''var ${name} = ${value}''')

	addTemplate(WMethodDeclarationRule, templateContext, acceptor, Messages.WollokTemplateProposalProvider_createMethod_name, Messages.WollokTemplateProposalProvider_createMethod_description, "org.uqbar.project.wollok.objectaddMethod", context,
'''method ${name}(${param}) {
	
}''')

  }
		
	def addTemplate(AbstractRule rule, TemplateContext templateContext, ITemplateAcceptor acceptor, String name, String description, String tid, ContentAssistContext context, String c) {
		val id = helper.getId(rule);
		template(templateContext, id, name, description, tid, c, acceptor, context)
	}
	
	def addTemplate(AbstractElement rule, TemplateContext templateContext, ITemplateAcceptor acceptor, String name, String description, String tid, ContentAssistContext context, String c) {
		val id = helper.getId(rule);
		template(templateContext, id, name, description, tid, c, acceptor, context)
	}
	
	def template(TemplateContext templateContext, String id, String name, String description, String tid, String c, ITemplateAcceptor acceptor, ContentAssistContext context) {
		if (templateContext.contextType.id.equals(id)) {
			val template = new Template(name, description, tid, c, false)
			acceptor.accept(createProposal(template, templateContext, context, getImage(template), getRelevance(template)))
		}
	}
	
}