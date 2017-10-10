package org.uqbar.project.wollok.formatting

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.eclipse.xtext.service.AbstractElementFinder.AbstractParserRuleElementFinder
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WAssignmentElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WBlockExpressionElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WCatchElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WClassElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WConstructorCallElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WConstructorElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WExpressionOrVarDeclarationElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WFileElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WFixtureElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WIfExpressionElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WListLiteralElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WMemberFeatureCallElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WMethodDeclarationElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WNamedObjectElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WObjectLiteralElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WPackageElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WProgramElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WSetLiteralElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WSuiteElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WSuperInvocationElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WTestElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WTryElements
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.WVariableDeclarationElements

import static extension org.uqbar.project.wollok.utils.StringUtils.firstUpper

/**
 * This class contains custom formatting description.
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting on how and when to use it 
 *
 * @deprecated since 1.6.4
 * use {@link WollokDslFormatter in org.uqbar.project.wollok.formatting2}
 * @author jfernandes
 */
@Singleton
@Deprecated
class WollokDslFormatter extends AbstractDeclarativeFormatter {
	@Inject extension WollokDslGrammarAccess access
	
	override protected void configureFormatting(FormattingConfig it) {
		if (1 === 1) return;
		
		commentFormatting
		
		access.grammar.rules
			.map[ "get" + name.firstUpper + "Access"]
			.forEach[methodName|
				val e = reflective(access, methodName)
				if (e !== null)
					formatting(e)
			]
	}
	
	def <T> T reflective(Object target, String methodName) {
		try 
			target.class.getMethod(methodName).invoke(target) as T
		catch (NoSuchMethodException e)
			null
	}

	def commentFormatting(FormattingConfig it) {
		setLinewrap(0, 1, 2).before(SL_COMMENTRule)
		setLinewrap(0, 1, 2).before(ML_COMMENTRule)
		setLinewrap(0, 1, 1).after(ML_COMMENTRule)
	}
	
	def dispatch formatting(FormattingConfig it, extension WFileElements f) {
		setLinewrap(1, 1, 1).after(importsImportParserRuleCall_0_0)
		setLinewrap(1, 2, 2).after(importsAssignment_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WMethodDeclarationElements e) {
		//setLinewrap(1, 1, 2).before(rule)
		setSpace("@@").before(rule)
		setLinewrap(1, 1, 1).after(expressionAssignment_7_0)
		
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
	
	def dispatch formatting(FormattingConfig it, extension WConstructorElements e) {
		setLinewrap(1, 1, 2).before(constructorKeyword_1)
		setLinewrap(1, 1, 1).after(expressionAssignment_6)
		
		setNoSpace.after(constructorKeyword_1)
		
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
	
	def dispatch formatting(FormattingConfig it, extension WMemberFeatureCallElements e) {
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
		setLinewrap(0,1,2).after(rightParenthesisKeyword_1_2_0_2)
	}
	
	def dispatch formatting(FormattingConfig it, extension WConstructorCallElements e) {
		setSpace(' ').after(newKeyword_0)
		setNoSpace.after(classRefAssignment_1)
		
		setNoSpace.before(commaKeyword_3_1_0)
		setSpace(' ').after(commaKeyword_3_1_0)
		
		// parenthesis
		setNoSpace.around(leftParenthesisKeyword_2)
		setNoSpace.before(rightParenthesisKeyword_4)
	}
	
	def dispatch formatting(FormattingConfig it, extension WBlockExpressionElements b) {
		setLinewrap(1, 1, 1).after(leftCurlyBracketKeyword_1)
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_3)
		
		setIndentation(leftCurlyBracketKeyword_1, rightCurlyBracketKeyword_3)
		
		setLinewrap(1, 1, 2).around(expressionsWExpressionOrVarDeclarationParserRuleCall_2_0_0)
		setLinewrap(1, 1, 2).around(expressionsAssignment_2_0)
	}

	def dispatch formatting(FormattingConfig it, extension WExpressionOrVarDeclarationElements e) {
		setLinewrap(1, 1, 1).after(rule)
	}

	def dispatch formatting(FormattingConfig it, extension WPackageElements e) {
		setLinewrap(1, 2, 2).after(leftCurlyBracketKeyword_2)
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(rightCurlyBracketKeyword_4)
	}
	
	def dispatch formatting(FormattingConfig it, extension WProgramElements p) {
		setLinewrap(1, 2, 2).before(programKeyword_0)
		setLinewrap(1, 2, 2).after(leftCurlyBracketKeyword_2)
		
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(rightCurlyBracketKeyword_4)
		
		setLinewrap(0, 1, 2).after(elementsAssignment_3_0)
		
		setLinewrap(1, 1, 2).after(group_3)
	}

	def dispatch formatting(FormattingConfig it, extension WTestElements p) {
		setLinewrap(1, 2, 2).before(testKeyword_0)
		setLinewrap(1, 2, 2).after(leftCurlyBracketKeyword_2)
		
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 2, 2).after(rightCurlyBracketKeyword_4)
		
		setLinewrap(0, 1, 2).after(elementsAssignment_3_0)
		
		setLinewrap(1, 1, 2).after(group_3)
	}
	
	def dispatch formatting(FormattingConfig it, extension WClassElements e) {
		// wrap line just before 'class'
		setLinewrap(1, 2, 2).before(classKeyword_0)
		
		setLinewrap.after(leftCurlyBracketKeyword_4)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_8)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_8)
		
		// indentation
		setIndentation(leftCurlyBracketKeyword_4, rightCurlyBracketKeyword_8)
		
		// after all variables
		setLinewrap(1, 2, 2).after(group_5)
		
		// constructor
		setLinewrap(2, 2, 2).around(constructorsAssignment_6)
		
		// members (after var, after method)
		setLinewrap(1, 1, 2).after(membersAssignment_5_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_7_0_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WObjectLiteralElements e) {
		// wrap line just before 'object'
		setLinewrap(1, 2, 2).before(objectKeyword_1)
		
		setLinewrap.after(leftCurlyBracketKeyword_4)
		
		setLinewrap(1, 2, 2).after(group_5)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_7)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(membersAssignment_5_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_6_0_0)
		
		// increase indentation of content
		setIndentation(leftCurlyBracketKeyword_4, rightCurlyBracketKeyword_7)
	}
	
	def dispatch formatting(FormattingConfig it, extension WFixtureElements e) {
		// wrap line after }
		setLinewrap.after(leftCurlyBracketKeyword_2)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_4)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_4)
		
		// Indent expressions in fixture
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_4)
	}
	
	def dispatch formatting(FormattingConfig it, extension WSuiteElements e) {
		// wrap line just before 'class'
		setLinewrap(1, 2, 2).before(describeKeyword_0)
		
		setNoLinewrap.before(leftCurlyBracketKeyword_2)
		
		// wrap line after }
		setLinewrap.after(leftCurlyBracketKeyword_2)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_7)
		
		// indentation
		setIndentation(leftCurlyBracketKeyword_2, rightCurlyBracketKeyword_7)
		
		// after all variables
		setLinewrap(1, 2, 2).after(group_3)
		
		// fixture
		setLinewrap(2, 2, 2).around(fixtureAssignment_4)
		setLinewrap(2, 2, 2).around(fixtureWFixtureParserRuleCall_4_0)
		
		// members (after var, after method)
		setLinewrap(1, 1, 2).after(membersAssignment_5_0)
		setLinewrap(1, 1, 2).after(membersWMethodDeclarationParserRuleCall_5_0_0)
		setLinewrap(1, 2, 2).after(testsAssignment_6)
		setLinewrap(1, 2, 2).after(testsWTestParserRuleCall_6_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WNamedObjectElements o) {
		// wrap before
		setLinewrap(1, 2, 2).before(objectKeyword_0)
		
		setLinewrap.after(leftCurlyBracketKeyword_4)
		setLinewrap.after(rightCurlyBracketKeyword_7)
		setLinewrap(1, 2, 2).after(group_5)
		
		// wrap after var, and method
		setLinewrap(1, 1, 2).after(membersWVariableDeclarationParserRuleCall_5_0_0)
		setLinewrap(1, 1, 2).after(membersAssignment_5_0)
		setLinewrap(1, 2, 2).after(membersWMethodDeclarationParserRuleCall_6_0_0)
		
		// after all variables
		setLinewrap(1, 2, 2).after(group_5)
		
		// after all methods
		setLinewrap(1, 2, 2).after(group_6)
		
		// increase indentation of content
		setIndentation(leftCurlyBracketKeyword_4, rightCurlyBracketKeyword_7)
		
		// wrap before and after close bracket
		setLinewrap(1, 1, 1).before(rightCurlyBracketKeyword_7)
		setLinewrap(1, 1, 1).after(rightCurlyBracketKeyword_7)
	}
	
	def dispatch formatting(FormattingConfig it, extension WSetLiteralElements l) {
		// nospace ',' then space 
		setNoSpace.before(commaKeyword_2_1_0)
		setSpace(' ').after(commaKeyword_2_1_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WListLiteralElements l) {
		// nospace ',' then space 
		setNoSpace.before(commaKeyword_2_1_0)
		setSpace(' ').after(commaKeyword_2_1_0)
	}
	
	
	def dispatch formatting(FormattingConfig it, extension WIfExpressionElements i) {
		setNoSpace.after(leftParenthesisKeyword_1)
		setNoSpace.before(rightParenthesisKeyword_3)
		
		setLinewrap(0, 1, 1).before(elseKeyword_5_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WTryElements i) {
		setLinewrap(1, 1, 1).after(tryKeyword_0)
		setLinewrap(1, 1, 1).after(catchBlocksAssignment_2)
		setIndentation(tryKeyword_0, catchBlocksAssignment_2)
		setLinewrap(1, 1, 1).before(alwaysExpressionWBlockOrExpressionParserRuleCall_3_1_0)
		//setIndentationIncrement.after(thenAlwaysKeyword_3_0)
		//setIndentationDecrement.after(alwaysExpressionWBlockOrExpressionParserRuleCall_3_1_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WCatchElements i) {
		//setSpace(' ').after(catchKeyword_0)
		setLinewrap(1,1,1).before(catchKeyword_0)
		setLinewrap(1,1,1).around(expressionAssignment_3)
		//setIndentationIncrement.around(expressionWBlockOrExpressionParserRuleCall_3_0)
	}
	
	def dispatch formatting(FormattingConfig it, extension WSuperInvocationElements i) {
		setNoSpace.after(leftParenthesisKeyword_2_0)
		setNoSpace.before(rightParenthesisKeyword_2_2)
		setNoSpace.after(superKeyword_1)
	}
	
	def dispatch formatting(FormattingConfig it, extension WVariableDeclarationElements e) {
		setLinewrap(1, 1, 1).after(rightAssignment_3_1)
		setLinewrap(1, 1, 1).after(rightWExpressionParserRuleCall_3_1_0)
	}

	def dispatch formatting(FormattingConfig it, extension WAssignmentElements e) {
		setLinewrap(1, 1, 1).after(valueWAssignmentParserRuleCall_0_3_0)
		setLinewrap(1, 1, 1).after(valueAssignment_0_3)
		setLinewrap(1, 1, 1).before(WAssignmentAction_0_0)
//		setSpace("==1==").after(rule)
//		setSpace("==2==").after(alternatives)
//		setSpace("==3==").after(group_0)
//		setSpace("==4==").after(WAssignmentAction_0_0)
//		setSpace("==5==").after(featureAssignment_0_1)
//		setSpace("==6==").after(featureWVariableReferenceParserRuleCall_0_1_0)
//		setSpace("==7==").after(opSingleAssignParserRuleCall_0_2)
//		setSpace("==8==").after(valueAssignment_0_3)
//		setSpace("==8==").after(valueWAssignmentParserRuleCall_0_3_0)
//		setSpace("==9==").after(group_1)
//		setSpace("==10==").after(WOrExpressionParserRuleCall_1_0)
//		setSpace("==11==").after(group_1)
//		setSpace("==12==").after(group_1_1)
//		setSpace("==13==").after(group_1_1_0)
//		setSpace("==14==").after(group_1_1_0_0)
//		setSpace("==15==").after(WBinaryOperationLeftOperandAction_1_1_0_0_0)
//		setSpace("==16==").after(featureAssignment_1_1_0_0_1)
//		setSpace("==17==").after(featureOpMultiAssignParserRuleCall_1_1_0_0_1_0)
//		setSpace("==18==").after(rightOperandAssignment_1_1_1)
//		setSpace("==19==").after(rightOperandWAssignmentParserRuleCall_1_1_1_0)
	}

	// default
	def dispatch formatting(FormattingConfig it, extension AbstractParserRuleElementFinder i) {
		// does nothing
	}

}
