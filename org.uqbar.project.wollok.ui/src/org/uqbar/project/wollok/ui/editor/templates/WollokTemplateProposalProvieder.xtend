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

/**
 * Provides code templates for the editor.
 * 
 * @author jfernandes
 */
class WollokTemplateProposalProvieder extends DefaultTemplateProposalProvider {
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

	addTemplate(WProgramRule, templateContext, acceptor, "Create Program", "Create wollok program", "org.uqbar.project.wollok.createprogram", context,
'''program ${programName} {
	
}''')

    
	addTemplate(WLibraryElementRule, templateContext, acceptor, "Create Package", "Create new package element", "org.uqbar.project.wollok.createpackage", context,
'''package ${packageName} {
	
}''')

	//todo: class icon
	addTemplate(getWClassRule, templateContext, acceptor, "Create Class", "Create new class element", "org.uqbar.project.wollok.createclass", context,
'''class ${ClassName} {
	
}''')

	//todo: object icon
	addTemplate(getWObjectLiteralRule, templateContext, acceptor, "Create Object", "Create new object", "org.uqbar.project.wollok.createobject", context,
'''object {
	
}''')

	//TODO: poder seleccionar entre "var/val"
	addTemplate(getWVariableDeclarationRule, templateContext, acceptor, "Add reference", "Add new reference", "org.uqbar.project.wollok.objectaddReference", context,
'''var ${name} = ${value}''')

	addTemplate(getWMethodDeclarationRule, templateContext, acceptor, "Add method", "Add new method", "org.uqbar.project.wollok.objectaddMethod", context,
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