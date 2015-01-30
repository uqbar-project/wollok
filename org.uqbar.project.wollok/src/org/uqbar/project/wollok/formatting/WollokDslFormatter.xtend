package org.uqbar.project.wollok.formatting

import com.google.inject.Inject
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.uqbar.project.wollok.services.WollokDslGrammarAccess

/**
 * This class contains custom formatting description.
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting on how and when to use it 
 * 
 * @author jfernandes
 */
class WollokDslFormatter extends AbstractDeclarativeFormatter {
	@Inject extension WollokDslGrammarAccess
	
	override protected void configureFormatting(FormattingConfig it) {
		fileFormatting()
		
		commentFormatting
		classFormatting
		packageFormatting
		programFormatting
		blockFormatting
		methodFormatting
		memberFeatureCallFormatting
	}
	
	def fileFormatting(FormattingConfig it) {
		setLinewrap(1, 1, 1).after(WFileAccess.importsImportParserRuleCall_0_0)
		setLinewrap(1, 2, 2).after(WFileAccess.importsAssignment_0)
	}
	
	def commentFormatting(FormattingConfig it) {
		setLinewrap(0, 1, 2).before(SL_COMMENTRule)
		setLinewrap(0, 1, 2).before(ML_COMMENTRule)
		setLinewrap(0, 1, 1).after(ML_COMMENTRule)
	}
	
	def methodFormatting(FormattingConfig it) {
		setLinewrap(1, 1, 1).after(WMethodDeclarationAccess.expressionAssignment_7)
		
		setNoSpace.after(WMethodDeclarationAccess.nameAssignment_2)
		
		// params
		setNoSpace.after(WMethodDeclarationAccess.leftParenthesisKeyword_3)
		setNoSpace.around(WMethodDeclarationAccess.parametersAssignment_4_0)
		setNoSpace.before(WMethodDeclarationAccess.rightParenthesisKeyword_5)
		
		setNoSpace.before(WMethodDeclarationAccess.commaKeyword_4_1_0)
		setSpace(' ').after(WMethodDeclarationAccess.commaKeyword_4_1_0)
	}
	
	def memberFeatureCallFormatting(FormattingConfig it) {
		setNoSpace.around(WMemberFeatureCallAccess.WMemberFeatureCallMemberCallTargetAction_1_0_0_0)
		setNoSpace.around(WMemberFeatureCallAccess.featureAssignment_1_1)
		setNoSpace.around(WMemberFeatureCallAccess.memberCallArgumentsAssignment_1_2_0_1_0)
		setSpace(' ').after(WMemberFeatureCallAccess.commaKeyword_1_2_0_1_1_0)
	}
	
	def blockFormatting(FormattingConfig it) {
		setLinewrap(0, 1, 1).after(WBlockExpressionAccess.leftCurlyBracketKeyword_1)
		setLinewrap(0, 1, 1).before(WBlockExpressionAccess.rightCurlyBracketKeyword_3)
		setIndentation(WBlockExpressionAccess.leftCurlyBracketKeyword_1, WBlockExpressionAccess.rightCurlyBracketKeyword_3)
	}
	
	def packageFormatting(FormattingConfig it) {
		setLinewrap(1, 2, 2).after(WPackageAccess.leftCurlyBracketKeyword_2)
		setIndentation(WPackageAccess.leftCurlyBracketKeyword_2, WPackageAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(WPackageAccess.rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(WPackageAccess.rightCurlyBracketKeyword_4)
	}
	
	def programFormatting(FormattingConfig it) {
		setLinewrap(1, 2, 2).after(WProgramAccess.leftCurlyBracketKeyword_2)
		setIndentation(WProgramAccess.leftCurlyBracketKeyword_2, WPackageAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(WProgramAccess.rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(WProgramAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(0, 1, 2).after(WProgramAccess.elementsAssignment_3_0)
	}
	
	def classFormatting(FormattingConfig it) {
		setLinewrap.after(WClassAccess.leftCurlyBracketKeyword_3)
		setLinewrap(1, 1, 1).before(WClassAccess.rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(WClassAccess.rightCurlyBracketKeyword_7)
		setIndentation(WClassAccess.leftCurlyBracketKeyword_3, WClassAccess.rightCurlyBracketKeyword_7)
		
		setLinewrap(1, 2, 2).after(WClassAccess.group_4)
		
		// members (after var, after method
		setLinewrap(1, 1, 2).after(WClassAccess.membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(WClassAccess.membersWMethodDeclarationParserRuleCall_6_0_0)
	}
}
