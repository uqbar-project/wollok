package org.uqbar.project.wollok.parser

import com.google.inject.Inject
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.ITokenDefProvider
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider

import static org.eclipse.xtext.diagnostics.Diagnostic.*
import org.antlr.runtime.RecognitionException
import org.antlr.runtime.MismatchedTokenException
import org.uqbar.project.wollok.WollokConstants

class WollokSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {
	@Inject
	private ITokenDefProvider tokenDefProvider;
	
	override getSyntaxErrorMessage(IParserErrorContext context) {
		this.getSyntaxErrorMessage(context, context.recognitionException)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, RecognitionException exception) {
		super.getSyntaxErrorMessage(context)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, MismatchedTokenException exception) {
		if (exception.mismatchedKeywordIs(WollokConstants.VAR)) {
			new SyntaxErrorMessage("You should declare variables before constructors and methods.", SYNTAX_DIAGNOSTIC);
		}
		else {
			super.getSyntaxErrorMessage(context)
		} 
	}
	
	def mismatchedKeywordIs(MismatchedTokenException exception, String expectedToken) {
		tokenDefProvider.tokenDefMap.get(exception.c) == "'" + expectedToken + "'"
	}
}
