package org.uqbar.project.wollok.parser

import com.google.inject.Inject
import org.antlr.runtime.MismatchedTokenException
import org.antlr.runtime.RecognitionException
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.ITokenDefProvider
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.WollokConstants

import static org.eclipse.xtext.diagnostics.Diagnostic.*

class WollokSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {
	@Inject
	private ITokenDefProvider tokenDefProvider;
	
	override getSyntaxErrorMessage(IParserErrorContext context) {
		if (context.recognitionException != null) {
			this.getSyntaxErrorMessage(context, context.recognitionException)
		}
		super.getSyntaxErrorMessage(context)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, RecognitionException exception) {
		super.getSyntaxErrorMessage(context)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, MismatchedTokenException exception) {
		if (exception.mismatchedKeywordIs(WollokConstants.VAR) || exception.mismatchedKeywordIs(WollokConstants.CONST)) {
			new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS, SYNTAX_DIAGNOSTIC);
		}
		else {
			if (exception.mismatchedKeywordIs(WollokConstants.CONSTRUCTOR)) {
				new SyntaxErrorMessage(Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_BEFORE_METHODS, SYNTAX_DIAGNOSTIC);
			} else {
				super.getSyntaxErrorMessage(context)
			}
		} 
	}
	
	def mismatchedKeywordIs(MismatchedTokenException exception, String expectedToken) {
		tokenDefProvider.tokenDefMap.get(exception.c) == "'" + expectedToken + "'"
	}
}
