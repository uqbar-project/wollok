package org.uqbar.project.wollok.ui.editor.model

import com.google.inject.Inject
import com.google.inject.name.Named
import org.antlr.runtime.TokenSource
import org.eclipse.xtext.parser.antlr.ITokenDefProvider
import org.eclipse.xtext.ui.LexerUIBindings
import org.eclipse.xtext.ui.editor.model.DocumentTokenSource

/**
 * 
 * @author jfernandes
 */
class WollokDocumentTokenSource extends DocumentTokenSource {
	public static final int JAVA_DOC_TOKEN_TYPE = -10000;
	protected int multilineTokenType = -1;
	
	@Inject
	def void setTokenDefProvider(@Named(LexerUIBindings.HIGHLIGHTING) ITokenDefProvider tokenDefProvider) {
		val tokenDefMap = tokenDefProvider.tokenDefMap
		val entrySet = tokenDefMap.entrySet
		multilineTokenType = entrySet.findFirst[ entry | entry.value == "RULE_ML_COMMENT" ]?.key
		
		if (multilineTokenType == -1)
			throw new RuntimeException("No Token for RULE_ML_COMMENT found in tokenTypeDefs: " + entrySet.map[value].join(","));
	}

	override createTokenSource(String string) {
		val delegate = super.createTokenSource(string)
		return new TokenSource() {

			override nextToken() {
				val token = delegate.nextToken
				if (token.type == multilineTokenType) {
					val text = token.text
					if (text.startsWith("/**") && !text.startsWith("/***")){
						token.setType(JAVA_DOC_TOKEN_TYPE);
					}
				}
				return token;
			}

			override getSourceName() {
				return delegate.sourceName
			}
		};
	}
	
}