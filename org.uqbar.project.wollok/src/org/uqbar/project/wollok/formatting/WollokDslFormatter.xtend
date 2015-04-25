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
		objectFormatting
		namedObjectFormatting
		
		packageFormatting
		programFormatting
		
		blockFormatting
		methodFormatting
		memberFeatureCallFormatting
		
		listFormatting
		ifFormatting
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
		setLinewrap(1, 1, 2).before(WMethodDeclarationAccess.methodKeyword_1)
		setLinewrap(1, 1, 1).after(WMethodDeclarationAccess.expressionAssignment_7)
		
		setNoSpace.after(WMethodDeclarationAccess.nameAssignment_2)
		
		// params
		setNoSpace.after(WMethodDeclarationAccess.leftParenthesisKeyword_3)
		setNoSpace.around(WMethodDeclarationAccess.parametersAssignment_4_0)
		setNoSpace.before(WMethodDeclarationAccess.rightParenthesisKeyword_5)
		
		setNoSpace.before(WMethodDeclarationAccess.commaKeyword_4_1_0)
		setSpace(' ').after(WMethodDeclarationAccess.commaKeyword_4_1_0)
		
		// space after ')' params and before either native / method body
		setSpace(' ').after(WMethodDeclarationAccess.getRightParenthesisKeyword_5)
	}
	
	def memberFeatureCallFormatting(FormattingConfig it) {
		setNoSpace.around(WMemberFeatureCallAccess.WMemberFeatureCallMemberCallTargetAction_1_0_0_0)
		setNoSpace.around(WMemberFeatureCallAccess.featureAssignment_1_1)
		setNoSpace.around(WMemberFeatureCallAccess.memberCallArgumentsAssignment_1_2_0_1_0)
		
		// no space around '.' or '?.'
		setNoSpace.around(WMemberFeatureCallAccess.getAlternatives_1_0_0_1)
		
		setSpace(' ').after(WMemberFeatureCallAccess.commaKeyword_1_2_0_1_1_0)
		
		// parenthesis
		setNoSpace.around(WMemberFeatureCallAccess.leftParenthesisKeyword_1_2_0_0)
		setNoSpace.before(WMemberFeatureCallAccess.rightParenthesisKeyword_1_2_0_2)
	}
	
	def blockFormatting(FormattingConfig it) {
		setLinewrap(0, 1, 1).after(WBlockExpressionAccess.leftCurlyBracketKeyword_1)
		setLinewrap(0, 1, 1).before(WBlockExpressionAccess.rightCurlyBracketKeyword_3)
		setIndentation(WBlockExpressionAccess.leftCurlyBracketKeyword_1, WBlockExpressionAccess.rightCurlyBracketKeyword_3)
		
		setLinewrap(1, 1, 2).after(WBlockExpressionAccess.getExpressionsAssignment_2_0)
	}
	
	def packageFormatting(FormattingConfig it) {
		setLinewrap(1, 2, 2).after(WPackageAccess.leftCurlyBracketKeyword_2)
		setIndentation(WPackageAccess.leftCurlyBracketKeyword_2, WPackageAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(WPackageAccess.rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(WPackageAccess.rightCurlyBracketKeyword_4)
	}
	
	def programFormatting(FormattingConfig it) {
		setLinewrap(1, 2, 2).before(WProgramAccess.programKeyword_0)
		setLinewrap(1, 2, 2).after(WProgramAccess.leftCurlyBracketKeyword_2)
		setIndentation(WProgramAccess.leftCurlyBracketKeyword_2, WPackageAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(WProgramAccess.rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(WProgramAccess.rightCurlyBracketKeyword_4)
		
		setLinewrap(0, 1, 2).after(WProgramAccess.elementsAssignment_3_0)
	}
	
	def classFormatting(FormattingConfig it) {
		// wrap line just before 'class'
		setLinewrap(1, 2, 2).before(WClassAccess.classKeyword_0)
		
		setLinewrap.after(WClassAccess.leftCurlyBracketKeyword_3)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(WClassAccess.rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(WClassAccess.rightCurlyBracketKeyword_7)
		
		// indentation
		setIndentation(WClassAccess.leftCurlyBracketKeyword_3, WClassAccess.rightCurlyBracketKeyword_7)
		
		// after all variables
		setLinewrap(1, 2, 2).after(WClassAccess.group_4)
		
		// members (after var, after method)
		setLinewrap(1, 1, 2).after(WClassAccess.membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(WClassAccess.membersWMethodDeclarationParserRuleCall_6_0_0)
	}
	
	def objectFormatting(FormattingConfig it) {
		// wrap line just before 'object'
		setLinewrap(1, 2, 2).before(WObjectLiteralAccess.objectKeyword_1)
		
		setLinewrap.after(WObjectLiteralAccess.leftCurlyBracketKeyword_2)
		
		setLinewrap(1, 2, 2).after(WObjectLiteralAccess.group_4)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(WObjectLiteralAccess.rightCurlyBracketKeyword_5)
		setLinewrap(1, 1, 1).after(WObjectLiteralAccess.rightCurlyBracketKeyword_5)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(WObjectLiteralAccess.membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(WObjectLiteralAccess.membersWMethodDeclarationParserRuleCall_4_0_0)
		
		// increase indentation of content
		setIndentation(WObjectLiteralAccess.leftCurlyBracketKeyword_2, WClassAccess.rightCurlyBracketKeyword_7)
	}
	
	def namedObjectFormatting(FormattingConfig it) {
		// wrap before
		setLinewrap(1, 2, 2).before(WNamedObjectAccess.objectKeyword_0)
		
		setLinewrap.after(WNamedObjectAccess.leftCurlyBracketKeyword_2)
		setLinewrap.after(WNamedObjectAccess.rightCurlyBracketKeyword_5)
		setLinewrap(1, 2, 2).after(WNamedObjectAccess.group_4)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(WNamedObjectAccess.getMembersWVariableDeclarationParserRuleCall_3_0_0)
		setLinewrap(1, 1, 2).after(WNamedObjectAccess.membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(WNamedObjectAccess.membersWMethodDeclarationParserRuleCall_4_0_0)
		
		// after all variables
		setLinewrap(1, 2, 2).after(WNamedObjectAccess.group_3)
		
		// after all methods
		setLinewrap(1, 2, 2).after(WNamedObjectAccess.group_4)
		
		// increase indentation of content
		setIndentation(WNamedObjectAccess.leftCurlyBracketKeyword_2, WNamedObjectAccess.rightCurlyBracketKeyword_5)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(WNamedObjectAccess.rightCurlyBracketKeyword_5)
		setLinewrap(1, 1, 1).after(WNamedObjectAccess.rightCurlyBracketKeyword_5)
	}
	
	def listFormatting(FormattingConfig it) {
		// #[  together
		setNoSpace.after(WListLiteralAccess.getNumberSignKeyword_1)
		
		// nospace ',' then space 
		setNoSpace.before(WListLiteralAccess.getCommaKeyword_3_1_0)
		setSpace(' ').after(WListLiteralAccess.getCommaKeyword_3_1_0)
	}
	
	def ifFormatting(FormattingConfig it) {
		setNoSpace.after(WIfExpressionAccess.leftParenthesisKeyword_1)
		setNoSpace.before(WIfExpressionAccess.rightParenthesisKeyword_3)
		
		setLinewrap(0, 1, 1).before(WIfExpressionAccess.elseKeyword_5_0)
	}
}
