package org.uqbar.project.wollok.ui.autoedit

import com.google.inject.Singleton
import org.eclipse.jface.text.IDocument
import org.eclipse.xtext.ui.editor.model.TerminalsTokenTypeToPartitionMapper
import org.uqbar.project.wollok.ui.editor.model.WollokDocumentTokenSource

/**
 * 
 * @author jfernandes
 */
@Singleton
class TokenTypeToPartitionMapper extends TerminalsTokenTypeToPartitionMapper {
	
	public final static String JAVA_DOC_PARTITION = "__java_javadoc";
	public static final String[] SUPPORTED_TOKEN_TYPES = #[ 
		COMMENT_PARTITION,
		JAVA_DOC_PARTITION,
		SL_COMMENT_PARTITION, 
		STRING_LITERAL_PARTITION, 
		IDocument.DEFAULT_CONTENT_TYPE 
	]
	
	override calculateId(String tokenName, int tokenType) {
		if ("RULE_ML_COMMENT".equals(tokenName)) {
			return COMMENT_PARTITION;
		}
		return super.calculateId(tokenName, tokenType);
	}
	
	override getMappedValue(int tokenType) {
		if(tokenType == WollokDocumentTokenSource.JAVA_DOC_TOKEN_TYPE) {
			return JAVA_DOC_PARTITION;
		}
		return super.getMappedValue(tokenType);
	}
	
	override getSupportedPartitionTypes() {
		return SUPPORTED_TOKEN_TYPES;
	}
	
	override isMultiLineComment(String partitionType) {
		return super.isMultiLineComment(partitionType) || JAVA_DOC_PARTITION.equals(partitionType);
	}
	
}