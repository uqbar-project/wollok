package org.uqbar.project.wollok.parser

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.Set
import org.antlr.runtime.EarlyExitException
import org.antlr.runtime.MismatchedTokenException
import org.antlr.runtime.RecognitionException
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IParserErrorContext
import org.eclipse.xtext.parser.antlr.ITokenDefProvider
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.services.WollokDslGrammarAccess

import static org.eclipse.xtext.diagnostics.Diagnostic.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

@Singleton
class WollokSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {
	@Inject
	private ITokenDefProvider tokenDefProvider
	@Inject
	private WollokDslGrammarAccess grammarAccess

	private Set<SpecialMessage> syntaxDiagnosis = #{
		new SpecialMessage(WollokConstants.VAR, Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS),
		new SpecialMessage(WollokConstants.CONST, Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS),
		new SpecialMessage(WollokConstants.CONSTRUCTOR, Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_BEFORE_METHODS),
		new SpecialMessage(WollokConstants.FIXTURE, Messages.SYNTAX_DIAGNOSIS_FIXTURE_BEFORE_TESTS),
		new SpecialMessage(WollokConstants.ASIGNATION,
			Messages.SYNTAX_MISSING_BRACKETS_IN_METHOD, [ context, exception |
				context.grammarRule == grammarAccess.WMethodDeclarationRule
			])
	}

	override getSyntaxErrorMessage(IParserErrorContext context) {
		if (context.recognitionException !== null) {
			return this.getSyntaxErrorMessage(context, context.recognitionException)
		}
		super.getSyntaxErrorMessage(context)
	}

	def dispatch getSyntaxErrorMessage(IParserErrorContext context, RecognitionException exception) {
		super.getSyntaxErrorMessage(context)
	}

	def dispatch getSyntaxErrorMessage(IParserErrorContext context, MismatchedTokenException exception) {
		enhanceSyntaxErrorMessage(context, exception)
	}

	def dispatch getSyntaxErrorMessage(IParserErrorContext context, EarlyExitException exception) {
		enhanceSyntaxErrorMessage(context, exception)
	}
	
	def enhanceSyntaxErrorMessage(IParserErrorContext context, Exception exception) {
		// First, manual rules
		if (exception.token?.equalsIgnoreCase(WollokConstants.CONSTRUCTOR)) {
			val declaringContext = context.currentContext.declaringContext
			if (!declaringContext?.canDefineConstructors) {
				if (declaringContext !== null) 
					return new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_NOT_ALLOWED_HERE, declaringContext?.constructionName), SYNTAX_DIAGNOSTIC)
				else 	
					return new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_NOT_ALLOWED_HERE_GENERIC, SYNTAX_DIAGNOSTIC)
			}
		}		

		// Now automatic rules
		val specificMessage = syntaxDiagnosis.findFirst[msg|exception.isApplicable(msg, context)]
		if (specificMessage === null) {
			return super.getSyntaxErrorMessage(context)
		}
		
		new SyntaxErrorMessage(specificMessage.message, SYNTAX_DIAGNOSTIC)
	}
	
	def grammarRule(IParserErrorContext context) {
		if (context === null || context.currentNode === null || context.currentNode.grammarElement === null)
			return null
		if (!(context.currentNode.grammarElement instanceof RuleCall))
			return null

		val ruleCall = context.currentNode.grammarElement as RuleCall
		ruleCall.rule
	}

	def isApplicable(Exception exception, SpecialMessage msg, IParserErrorContext context) {
		false
	}
	
	def isApplicable(EarlyExitException exception, SpecialMessage msg, IParserErrorContext context) {
		exception.token.text.equalsIgnoreCase(msg.token) && msg.condition.apply(context, exception)
	}
	
	def isApplicable(MismatchedTokenException exception, SpecialMessage msg, IParserErrorContext context) {
		(tokenDefProvider.tokenDefMap.get(exception.c) == "'" + msg.token + "'") &&
			msg.condition.apply(context, exception)
	}
	
	def dispatch token(Exception exception) { "" }
	def dispatch token(RecognitionException exception) { exception.token.text }	
}

@Accessors
class SpecialMessage {
	val String message
	val String token
	(IParserErrorContext, RecognitionException)=>Boolean condition

	new(String token, String message) {
		this.token = token
		this.message = message
		condition = [true]
	}

	new(String token, String message, (IParserErrorContext, RecognitionException)=>Boolean condition) {
		this.token = token
		this.message = message
		this.condition = condition
	}
}
