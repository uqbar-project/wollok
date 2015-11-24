package org.uqbar.project.wollok.ui.editor.templates

import com.google.inject.Inject
import java.util.Properties
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
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.ui.Messages.*
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * Provides code templates for the editor.
 * 
 * @author jfernandes
 */
class WollokTemplateProposalProvider extends DefaultTemplateProposalProvider {
	static Properties properties
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
    
    val extension builder = new TemplateBuilder(grammar, "org.uqbar.project.wollok", "WollokTemplateProposalProvider", getProperties,  [rule, name, description, id, content | 
    	addTemplate(rule, templateContext, acceptor, name, description, id, context, content)
    ]);
    
    builder
    
<< WProgram >> 
'''program ${programName} {
	
}'''

<< WClass >>
'''class ${ClassName} {
	
}'''

<< WNamedObject >>
'''object ${objectName} {
	
}'''

<< WObjectLiteral >>
'''object {
	
}'''

<< WMethodDeclaration >>
'''method ${name}(${param}) {
	
}'''

<< WVariableDeclaration >>
'''var ${name} = ${value}'''

	addTemplate(WLibraryElementRule, templateContext, acceptor, WollokTemplateProposalProvider_WPackage_name, WollokTemplateProposalProvider_WPackage_description, "org.uqbar.project.wollok.createpackage", context,
'''package ${packageName} {
	
}''')

	}
	
	def getGetProperties() {
		if (properties == null)
			properties = loadProperties 
		properties
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