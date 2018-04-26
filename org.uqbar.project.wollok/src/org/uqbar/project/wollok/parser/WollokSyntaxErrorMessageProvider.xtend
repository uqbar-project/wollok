package org.uqbar.project.wollok.parser

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.Set
import org.antlr.runtime.EarlyExitException
import org.antlr.runtime.MismatchedTokenException
import org.antlr.runtime.MissingTokenException
import org.antlr.runtime.NoViableAltException
import org.antlr.runtime.RecognitionException
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IParserErrorContext
import org.eclipse.xtext.parser.antlr.ITokenDefProvider
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static org.eclipse.xtext.diagnostics.Diagnostic.*
import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

@Singleton
class WollokSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {
	
	public static String MISSING_EOF = "<missing EOF>"
	
	@Inject
	private ITokenDefProvider tokenDefProvider
	@Inject
	private WollokDslGrammarAccess grammarAccess

	private Set<SpecialMessage> syntaxDiagnosis = #{
		new SpecialMessage(VAR, Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS),
		new SpecialMessage(CONST, Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS),
		new SpecialMessage(CONSTRUCTOR, Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_BEFORE_METHODS),
		new SpecialMessage(FIXTURE, Messages.SYNTAX_DIAGNOSIS_FIXTURE_BEFORE_TESTS),
		new SpecialMessage(ASIGNATION,
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

	def dispatch getSyntaxErrorMessage(IParserErrorContext context, Exception exception) {
		super.getSyntaxErrorMessage(context)
	}

	def dispatch getSyntaxErrorMessage(IParserErrorContext context, NoViableAltException exception) {
		val declaringContext = context.currentContext
		val operation = declaringContext.feature
		if (operation === null) return super.getSyntaxErrorMessage(context)
		val token = exception.token.text
		val completeMessage = operation + token
		new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_BAD_MESSAGE, completeMessage), SYNTAX_DIAGNOSTIC)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, RecognitionException exception) {
		enhanceSyntaxErrorMessage(context, exception)
	}

	def enhanceSyntaxErrorMessage(IParserErrorContext context, Exception exception) {
		// First, manual rules
		val declaringContext = context.currentContext.declaringContext
		var construction = context.currentNode?.text?.split(" ")?.head
		val token = exception.token

		if (#[CONST, VAR].contains(token)) {
			if (declaringContext === null) {
				return new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_REFERENCES_NOT_ALLOWED_HERE_GENERIC, SYNTAX_DIAGNOSTIC)
			}
		}		
		
		if (token?.equalsIgnoreCase(CONSTRUCTOR) && !declaringContext?.canDefineConstructors) {
			if (declaringContext !== null)
				return new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_NOT_ALLOWED_HERE, declaringContext?.constructionName), SYNTAX_DIAGNOSTIC)
			else 	
				return new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_NOT_ALLOWED_HERE_GENERIC, SYNTAX_DIAGNOSTIC)
		}		

		if (token?.equalsIgnoreCase(FIXTURE) && !declaringContext?.canDefineFixture) {
			if (declaringContext !== null)
				return new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_FIXTURE_NOT_ALLOWED_HERE, declaringContext?.constructionName), SYNTAX_DIAGNOSTIC)
			else 	
				return new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_FIXTURE_NOT_ALLOWED_HERE_GENERIC, SYNTAX_DIAGNOSTIC)
		}		

		if (token?.equalsIgnoreCase(TEST) && !declaringContext?.canDefineTests) {
			if (declaringContext !== null)
				return new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_TESTS_NOT_ALLOWED_HERE, declaringContext?.constructionName), SYNTAX_DIAGNOSTIC)
			else 	
				return new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_TESTS_NOT_ALLOWED_HERE_GENERIC, SYNTAX_DIAGNOSTIC)
		}		

		if (exception.parserMessage.contains(MISSING_EOF) && orderedConstructions.contains(construction)) {
			return new SyntaxErrorMessage(NLS.bind(Messages.SYNTAX_DIAGNOSIS_ORDER_PROBLEM, token, construction), SYNTAX_DIAGNOSTIC)
		}
		
		// Now automatic rules
		var specificMessage = syntaxDiagnosis.findFirst[ msg|
			exception !== null && exception.isApplicable(msg, context)
		]
		if (specificMessage === null && context.currentContext !== null) {
			specificMessage = changeParserMessage(context.currentContext, exception)
		}
		if (specificMessage === null && context.currentContext !== null && context.grammarRule !== null) {
			specificMessage = changeParserMessage(context.currentContext, context.grammarRule, exception)
		}
		if (specificMessage === null) {
			return super.getSyntaxErrorMessage(context)
		}

		new SyntaxErrorMessage(specificMessage.message, SYNTAX_DIAGNOSTIC)
	}
	
	def orderedConstructions() {
		#[WKO, CLASS, TEST, SUITE, PROGRAM]
	}
	
	def grammarRule(IParserErrorContext context) {
		if (context === null || context.currentNode === null || context.currentNode.grammarElement === null)
			return null
		if (!(context.currentNode.grammarElement instanceof RuleCall))
			return null

		val ruleCall = context.currentNode.grammarElement as RuleCall
		ruleCall.rule
	}

	def dispatch isApplicable(Exception exception, SpecialMessage msg, IParserErrorContext context) {
		false
	}
	
	def dispatch isApplicable(EarlyExitException exception, SpecialMessage msg, IParserErrorContext context) {
		exception.token !== null && exception.token.text !== null && exception.token.text.equalsIgnoreCase(msg.token) && msg.condition !== null && msg.condition.apply(context, exception)
	}
	
	def dispatch isApplicable(MismatchedTokenException exception, SpecialMessage msg, IParserErrorContext context) {
		(tokenDefProvider.tokenDefMap.get(exception.c) == "'" + msg.token + "'") &&
			msg.condition.apply(context, exception)
	}

	def dispatch parserMessage(Exception e) { "" }
	def dispatch parserMessage(MissingTokenException e) { e.inserted.toString }
		
	def dispatch token(Exception exception) { "" }
	def dispatch token(RecognitionException exception) { exception.token.text }
	
	def dispatch SpecialMessage changeParserMessage(EObject o, Exception e) { null }
	def dispatch SpecialMessage changeParserMessage(WMethodDeclaration m, MismatchedTokenException e) {
		new SpecialMessage(e.token.text, NLS.bind(Messages.SYNTAX_DIAGNOSIS_BAD_CHARACTER_IN_METHOD, e.token.text))				
	}
	def dispatch SpecialMessage changeParserMessage(EObject o, AbstractRule r, Exception e) { null }
	def dispatch SpecialMessage changeParserMessage(WArgumentList l, ParserRule r, MismatchedTokenException e) {
		if (r.name.equalsIgnoreCase("WVariable")) {
			new SpecialMessage(e.token.text, Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_WITH_BOTH_INITIALIZERS_AND_VALUES)
		} else null
	}
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
