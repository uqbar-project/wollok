package org.uqbar.project.wollok.formatting

import com.google.inject.Inject
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WBlockExpressionElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WFileElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WMethodDeclarationElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WConstructorElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WMemberFeatureCallElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WListLiteralElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WIfExpressionElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WPackageElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WProgramElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WNamedObjectElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WObjectLiteralElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WClassElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WConstructorCallElements

/**
 * This class contains custom formatting description.
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting on how and when to use it 
 * 
 * @author jfernandes
 */
class WollokDslFormatter extends AbstractDeclarativeFormatter {
	@Inject extension WollokDslGrammarAccess
	
	override protected void configureFormatting(FormattingConfig it) {
		fileFormatting(WFileAccess)
		
		commentFormatting
		
		classFormatting(WClassAccess)
		objectFormatting(WObjectLiteralAccess)
		namedObjectFormatting(WNamedObjectAccess)
		
		packageFormatting(WPackageAccess)
		programFormatting(WProgramAccess)
		
		blockFormatting(WBlockExpressionAccess)
		methodFormatting(WMethodDeclarationAccess)
		constructorDefFormatting(WConstructorAccess)
		
		memberFeatureCallFormatting(WMemberFeatureCallAccess)
		constructorCallFormatting(WConstructorCallAccess)
		
		listFormatting(WListLiteralAccess)
		ifFormatting(WIfExpressionAccess)
	}
	
	def fileFormatting(FormattingConfig it, extension WFileElements f) {
		setLinewrap(1, 1, 1).after(importsImportParserRuleCall_0_0)
		setLinewrap(1, 2, 2).after(importsAssignment_0)
	}
	
	def commentFormatting(FormattingConfig it) {
		setLinewrap(0, 1, 2).before(SL_COMMENTRule)
		setLinewrap(0, 1, 2).before(ML_COMMENTRule)
		setLinewrap(0, 1, 1).after(ML_COMMENTRule)
	}
	
	def methodFormatting(FormattingConfig it, extension WMethodDeclarationElements e) {
		setLinewrap(1, 1, 2).before(methodKeyword_1)
		setLinewrap(1, 1, 1).after(expressionAssignment_7)
		
		setNoSpace.after(nameAssignment_2)
		
		// params
		setNoSpace.after(leftParenthesisKeyword_3)
		setNoSpace.around(parametersAssignment_4_0)
		setNoSpace.before(rightParenthesisKeyword_5)
		
		// param's comma
		setNoSpace.before(commaKeyword_4_1_0)
		setSpace(' ').after(commaKeyword_4_1_0)
		
		// space after ')' params and before either native / method body
		setSpace(' ').after(rightParenthesisKeyword_5)
	}
	
	def constructorDefFormatting(FormattingConfig it, extension WConstructorElements e) {
		setLinewrap(1, 1, 2).before(newKeyword_1)
		setLinewrap(1, 1, 1).after(expressionAssignment_6)
		
		setNoSpace.after(newKeyword_1)
		
		//TODO: delegating constructor format
		
		// params
		setNoSpace.after(leftParenthesisKeyword_2)
		setNoSpace.around(parametersAssignment_3_0)
		setNoSpace.before(rightParenthesisKeyword_4)
		
		// param's comma
		setNoSpace.before(commaKeyword_3_1_0)
		setSpace(' ').after(commaKeyword_3_1_0)
		
		// space after ')' params and before either native / method body
		setSpace(' ').after(rightParenthesisKeyword_4)
	}
	
	def memberFeatureCallFormatting(FormattingConfig it, extension WMemberFeatureCallElements e) {
		setNoSpace.around(WMemberFeatureCallMemberCallTargetAction_1_0_0_0)
		setNoSpace.around(featureAssignment_1_1)
		setNoSpace.around(memberCallArgumentsAssignment_1_2_0_1_0)
		
		// no space around '.' or '?.'
		setNoSpace.around(getAlternatives_1_0_0_1)
		
		setNoSpace.before(commaKeyword_1_2_0_1_1_0)
		setSpace(' ').after(commaKeyword_1_2_0_1_1_0)
		
		// parenthesis
		setNoSpace.around(leftParenthesisKeyword_1_2_0_0)
		setNoSpace.before(rightParenthesisKeyword_1_2_0_2)
	}
	
	def constructorCallFormatting(FormattingConfig it, extension WConstructorCallElements e) {
		setSpace(' ').after(newKeyword_0)
		setNoSpace.after(classRefAssignment_1)
		
		setNoSpace.before(commaKeyword_3_1_0)
		setSpace(' ').after(commaKeyword_3_1_0)
		
		// parenthesis
		setNoSpace.around(leftParenthesisKeyword_2)
		setNoSpace.before(rightParenthesisKeyword_4)
	}
	
	def blockFormatting(FormattingConfig it, extension WBlockExpressionElements b) {
		setLinewrap(0, 1, 1).after(leftCurlyBracketKeyword_1)
		setLinewrap(0, 1, 1).before(rightCurlyBracketKeyword_3)
		
		setIndentation(leftCurlyBracketKeyword_1, rightCurlyBracketKeyword_3)
		
		setLinewrap(1, 1, 2).after(expressionsAssignment_2_0)
		
//		setLinewrap(1, 1, 2).before(expressionsAssignment_2_0)
//		setLinewrap(1, 1, 2).before(b.expressionsWExpressionOrVarDeclarationParserRuleCall_2_0_0)
//		setLinewrap(1, 1, 2).after(b.expressionsWExpressionOrVarDeclarationParserRuleCall_2_0_0)
	}
	
	def packageFormatting(FormattingConfig it, extension WPackageElements e) {
		setLinewrap(1, 2, 2).after(leftCurlyBracketKeyword_2)
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(rightCurlyBracketKeyword_4)
	}
	
	def programFormatting(FormattingConfig it, extension WProgramElements p) {
		setLinewrap(1, 2, 2).before(programKeyword_0)
		setLinewrap(1, 2, 2).after(leftCurlyBracketKeyword_2)
		
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(rightCurlyBracketKeyword_4)
		
		setLinewrap(0, 1, 2).after(elementsAssignment_3_0)
		
		setLinewrap(1, 1, 2).after(group_3)
	}
	
	def classFormatting(FormattingConfig it, extension WClassElements e) {
		// wrap line just before 'class'
		setLinewrap(1, 2, 2).before(classKeyword_0)
		
		setLinewrap.after(leftCurlyBracketKeyword_3)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_7)
		
		// indentation
		setIndentation(leftCurlyBracketKeyword_3, rightCurlyBracketKeyword_7)
		
		// after all variables
		setLinewrap(1, 2, 2).after(group_4)
		
		// constructor
		setLinewrap(2, 2, 2).around(constructorsAssignment_5)
		
		// members (after var, after method)
		setLinewrap(1, 1, 2).after(membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_6_0_0)
	}
	
	def objectFormatting(FormattingConfig it, extension WObjectLiteralElements e) {
		// wrap line just before 'object'
		setLinewrap(1, 2, 2).before(objectKeyword_1)
		
		setLinewrap.after(leftCurlyBracketKeyword_2)
		
		setLinewrap(1, 2, 2).after(group_4)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_5)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_5)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_4_0_0)
		
		// increase indentation of content
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_5)
	}
	
	def namedObjectFormatting(FormattingConfig it, extension WNamedObjectElements o) {
		// wrap before
		setLinewrap(1, 2, 2).before(objectKeyword_0)
		
		setLinewrap.after(leftCurlyBracketKeyword_2)
		setLinewrap.after(rightCurlyBracketKeyword_5)
		setLinewrap(1, 2, 2).after(group_4)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(getMembersWVariableDeclarationParserRuleCall_3_0_0)
		setLinewrap(1, 1, 2).after(membersAssignment_4_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_4_0_0)
		
		// after all variables
		setLinewrap(1, 2, 2).after(group_3)
		
		// after all methods
		setLinewrap(1, 2, 2).after(group_4)
		
		// increase indentation of content
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_5)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_5)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_5)
	}
	
	def listFormatting(FormattingConfig it, extension WListLiteralElements l) {
		// #[  together
		setNoSpace.after(numberSignKeyword_1)
		
		// nospace ',' then space 
		setNoSpace.before(commaKeyword_3_1_0)
		setSpace(' ').after(commaKeyword_3_1_0)
	}
	
	def ifFormatting(FormattingConfig it, extension WIfExpressionElements i) {
		setNoSpace.after(leftParenthesisKeyword_1)
		setNoSpace.before(rightParenthesisKeyword_3)
		
		setLinewrap(0, 1, 1).before(elseKeyword_5_0)
	}

}
