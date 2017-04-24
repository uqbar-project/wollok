package org.uqbar.project.wollok.ui.editor.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper
import org.uqbar.project.wollok.ui.editor.model.WollokDocumentTokenSource
import org.uqbar.project.wollok.ui.highlight.WollokHighlightingConfiguration

class WollokAntlrTokenToAttributeIdMapper extends DefaultAntlrTokenToAttributeIdMapper {
	
	override protected getMappedValue(int tokenType) {
		if(tokenType == WollokDocumentTokenSource.JAVA_DOC_TOKEN_TYPE)
			WollokHighlightingConfiguration.WOLLOK_DOC_STYLE_ID	
		else
			super.getMappedValue(tokenType)
	}
	
}