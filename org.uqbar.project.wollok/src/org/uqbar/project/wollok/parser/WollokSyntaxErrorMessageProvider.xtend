package org.uqbar.project.wollok.parser

import com.google.inject.Inject
import java.util.Map
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
	private ITokenDefProvider tokenDefProvider
	
	private Map<String, String> syntaxDiagnosis = #{
		WollokConstants.VAR -> Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS,
		WollokConstants.CONST -> Messages.SYNTAX_DIAGNOSIS_REFERENCES_BEFORE_CONSTRUCTOR_AND_METHODS,
		WollokConstants.CONSTRUCTOR -> Messages.SYNTAX_DIAGNOSIS_CONSTRUCTOR_BEFORE_METHODS,
		WollokConstants.FIXTURE -> Messages.SYNTAX_DIAGNOSIS_FIXTURE_BEFORE_TESTS 
	}
	
	override getSyntaxErrorMessage(IParserErrorContext context) {
		if (context.recognitionException != null) {
			return this.getSyntaxErrorMessage(context, context.recognitionException)
		}
		super.getSyntaxErrorMessage(context)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, RecognitionException exception) {
		super.getSyntaxErrorMessage(context)
	}
	
	def dispatch getSyntaxErrorMessage(IParserErrorContext context, MismatchedTokenException exception) {
		val specificMessageToken = syntaxDiagnosis
			.keySet
			.findFirst[ token |
				exception.mismatchedKeywordIs(token)
			]
			
		if (specificMessageToken == null) {
			return super.getSyntaxErrorMessage(context)
		} 
		
		new SyntaxErrorMessage(syntaxDiagnosis.get(specificMessageToken), SYNTAX_DIAGNOSTIC) 
	}
	
	def mismatchedKeywordIs(MismatchedTokenException exception, String expectedToken) {
		tokenDefProvider.tokenDefMap.get(exception.c) == "'" + expectedToken + "'"
	}
}
