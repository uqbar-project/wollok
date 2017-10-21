/*
 * generated by Xtext
 */
package org.uqbar.project.wollok.formatting2

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.services.WollokDslGrammarAccess
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelfDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokDslFormatter extends AbstractFormatter2 {
	
	@Inject extension WollokDslGrammarAccess

	def dispatch void format(WFile file, extension IFormattableDocument document) {
		file => [
			imports.forEach [ ^import, i |
				^import.format
				if (imports.size - 1 == i) {
					^import.append [ setNewLines(2) ]
				} else {
					^import.append [ newLine ]
				}
			]
			elements.forEach [ format ]
			main.format
			tests.formatTests(document)
			suite.format
		]
	}

	def dispatch void format(WProgram p, extension IFormattableDocument document) {
		p.prepend [ noSpace ]
		p.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ newLine ]
		p.elements.forEach [
			surround [ indent ]
			format
			append [ newLine ]
		]
		p.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ newLine ]
	}

	def dispatch void format(WClass c, extension IFormattableDocument document) {
		c.regionFor.keyword(WollokConstants.CLASS).prepend [ noSpace ]
		c.regionFor.keyword(WollokConstants.CLASS).append [ oneSpace ]
		c.regionFor.keyword(WollokConstants.INHERITS).surround [ oneSpace ]
		c.regionFor.feature(WCLASS__PARENT).surround [ oneSpace ]
		c.regionFor.keyword(WollokConstants.MIXED_WITH).surround [ oneSpace ]
		c.regionFor.feature(WCLASS__MIXINS).surround [ oneSpace ]
		c.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ setNewLines(2) ].prepend [ oneSpace ]
		c.interior [ 
			indent
		]
		c.variableDeclarations.formatVariableDeclarations(document)
		
		c.constructors.forEach [
			format
			append [ setNewLines(2) ]
		]

		c.methods.forEach [
			format
			append [ setNewLines(2) ]
		]
		
		c.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ setNewLines(2) ]
	}

	def dispatch void format(WNamedObject o, extension IFormattableDocument document) {
		o.regionFor.keyword(WollokConstants.WKO).prepend [ noSpace ]
		o.regionFor.keyword(WollokConstants.WKO).append [ oneSpace ]
		o.regionFor.keyword(WollokConstants.INHERITS).surround [ oneSpace ]
		o.parentParameters.forEach [ param, i |
			if (i == 0) {
				param.prepend [ noSpace ]
			} else {
				param.prepend [ oneSpace ]
			}
			param.append [ noSpace ]
			param.format
		]
		o.regionFor.feature(WCLASS__PARENT).surround [ oneSpace ]
		o.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ setNewLines(2) ].prepend [ oneSpace ]
		o.interior [ 
			indent
		]
		
		o.variableDeclarations.formatVariableDeclarations(document)

		o.methods.forEach [
			format
			append [ setNewLines(2) ]
		]
		
		o.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ setNewLines(2) ]
	}

	def dispatch void format(WVariableDeclaration v, extension IFormattableDocument document) {
		v.regionFor.keyword(WollokConstants.VAR).append [ oneSpace ]
		v.regionFor.keyword(WollokConstants.CONST).append [ oneSpace ]
		v.variable.append [ oneSpace ]
		v.regionFor.keyword(WollokConstants.ASSIGNMENT).append [ oneSpace ]
		v.right.format
	}
	
	def dispatch void format(WMethodDeclaration m, extension IFormattableDocument document) {
		m.regionFor.feature(WMETHOD_DECLARATION__OVERRIDES).surround [ oneSpace ]
		m.regionFor.feature(WMETHOD_DECLARATION__NATIVE).surround [ oneSpace ]
		m.regionFor.keyword(WollokConstants.METHOD).append [ oneSpace ]
		m.regionFor.feature(WMETHOD_DECLARATION__EXPRESSION_RETURNS).surround([ oneSpace ])
		m.parameters.formatParameters(document)
		m.regionFor.feature(WNAMED__NAME).append [ noSpace ]
		m.expression => [
			prepend [ oneSpace ]
			format
		]
	}
	
	def dispatch void format(WBlockExpression b, extension IFormattableDocument document) {
		b.format(document, true)	
	}
	
	def dispatch void format(WExpression b, extension IFormattableDocument document, boolean addNewLine) {
		b.format(document)
	}
	
	def dispatch void format(WBlockExpression b, extension IFormattableDocument document, boolean addNewLine) {
		b.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION) => [
			append[ newLine ]
		]
		b.expressions.forEach [ expr, i |
			expr.surround [ indent ]
			expr.format(document, false)
			if (addNewLine) 
				expr.append [ newLine ]
		]
	}
	
	def dispatch void format(WMemberFeatureCall c, extension IFormattableDocument document, boolean checkPreviousSpaces) {
		if (checkPreviousSpaces && c.previousHiddenRegion.length > 1) {
			c.prepend [ oneSpace ]
		}
		c.memberCallTarget => [
			append [ noSpace ]
			if (operandShouldBeFormatted) {
				format
			}
		]
		c.regionFor.keyword(".").surround [ noSpace ]
		c.regionFor.feature(WMEMBER_FEATURE_CALL__NULL_SAFE).surround [ noSpace ]
		c.regionFor.feature(WMEMBER_FEATURE_CALL__FEATURE).surround [ noSpace ]
		c.memberCallArguments.forEach [ arg, i |
			if (i == 0) {
				arg.prepend [ noSpace ]
			} else {
				arg.prepend [ oneSpace ]
			}
			arg.append [ noSpace ]
			arg.format
		]
	}
	
	def dispatch void format(WMemberFeatureCall c, extension IFormattableDocument document) {
		c.format(document, true)
	}
	
	def dispatch void format(WAssignment a, extension IFormattableDocument document) {
		a.feature.append [ oneSpace ]
		a.feature.format
		a.value.prepend [ oneSpace ]
		a.value.format
	}
	
	def dispatch void format(WBinaryOperation o, extension IFormattableDocument document) {
		o.leftOperand.append [ oneSpace ]
		if (o.leftOperand.operandShouldBeFormatted) {
			o.leftOperand.format
		}
		if (o.rightOperand.operandShouldBeFormatted) {
			o.rightOperand.format
		}
		o.rightOperand.prepend [ oneSpace ]
	}

	def dispatch void format(WIfExpression i, extension IFormattableDocument document) {
		i.regionFor.keyword("if").append [ oneSpace ]
		i.condition => [
			surround [ noSpace ]
			format
		]
		i.then => [
			surround [ oneSpace	]
			format
		]
		i.^else => [
			surround [ oneSpace	]
			format
		]
	}

	def dispatch void format(WTry t, extension IFormattableDocument document) {
		t.expression.prepend [ oneSpace ]
		if (!(t.expression instanceof WBlockExpression)) {
			t.expression.surround [ newLine ; indent ]
		}
		t.expression.format
		t.catchBlocks.forEach [ format ]
		t.alwaysExpression?.surround [ oneSpace ]
		if (!(t.alwaysExpression instanceof WBlockExpression)) {
			t.alwaysExpression?.surround [ newLine ; indent ]
		}
		t.alwaysExpression?.format
		t.append [ newLine ]
	}
	
	def dispatch void format(WCatch c, extension IFormattableDocument document) {
		c.surround [ oneSpace ]
		c.exceptionVarName.surround [ oneSpace ]
		c.regionFor.keyword(":").surround [ oneSpace ]
		c.exceptionType.append [ oneSpace ]
		c.expression.prepend [ oneSpace ]
		if (!(c.expression instanceof WBlockExpression)) {
			c.expression.surround [ newLine ; indent ]
		}
		
		c.expression.format
	}
	
	def dispatch void format(WSetLiteral s, extension IFormattableDocument document) {
		s.elements.forEach [ element, i |
			element.prepend [ oneSpace ]
			if (i == s.elements.length - 1) {
				element.append [ oneSpace ]
			} else {
				element.append [ noSpace ]		
			}
		]
		s.regionFor.keyword(WollokConstants.END_SET_LITERAL).append [ noSpace ]
	}

	def dispatch void format(WListLiteral l, extension IFormattableDocument document) {
		l.elements.forEach [ element, i |
			element.prepend [ oneSpace ]
			if (i == l.elements.length - 1) {
				element.append [ oneSpace ]
			} else {
				element.append [ noSpace ]		
			}
		]
	}
	
	def dispatch void format(WClosure c, extension IFormattableDocument document) {
		val parametersCount = c.parameters.length
		c.parameters.forEach [ parameter, i |
			parameter.surround [ oneSpace ]
		]
		val oneExpression = c.expression.hasOneExpressionForFormatting
		c.regionFor.keyword("=>") => [
			if (oneExpression) {
				append [ oneSpace ]
			} else {
				append [ newLine ]
			}
			if (parametersCount == 0)
				surround [ indent ]
		]
		
		c.expression => [ expression |
			expression.prepend [ oneSpace ]
			expression.format(document, !oneExpression)
		]
		val end = c.regionFor.keyword(WollokConstants.END_EXPRESSION)
		if (oneExpression) {
			end.prepend [ oneSpace ]
		} else {
			end.prepend [ newLine ]
		}
	}

	def dispatch void format(WConstructor c, extension IFormattableDocument document) {
		c.regionFor.keyword(WollokConstants.CONSTRUCTOR).append [ noSpace ]
		c.parameters.formatParameters(document)
		c.regionFor.feature(WNAMED__NAME).append [ noSpace ]
		c.regionFor.keyword(WollokConstants.ASSIGNMENT).surround [ oneSpace ]
		c.delegatingConstructorCall?.format
		c.expression => [
			surround [ oneSpace ]
			format
		]
	}

	def dispatch void format(WConstructorCall c, extension IFormattableDocument document) {
		c.prepend [ indent ]
		c.regionFor.keyword(WollokConstants.INSTANTIATION).append [ oneSpace ]
		c.regionFor.keyword(WollokConstants.BEGIN_PARAMETER_LIST).prepend [ noSpace ]
		c.regionFor.keyword(WollokConstants.END_PARAMETER_LIST).append [ noSpace ]
		c.arguments.forEach [ arg, i |
			if (i == 0) {
				arg.prepend [ noSpace ]
			} else {
				arg.prepend [ oneSpace ]
			}
			arg.append [ noSpace ]
			arg.format
		]
	}

	def dispatch void format(WTest t, extension IFormattableDocument document) {
		t.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).prepend [ oneSpace ].append[ newLine ]
		t.elements.forEach [
			surround [ indent ]
			append [ newLine ]
			format
		]
		t.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ noSpace ]
	}

	def dispatch void format(WReturnExpression r, extension IFormattableDocument document) {
		r.prepend [ oneSpace ]
		r.expression.format
		r.expression.prepend [ oneSpace ]		
	}

	def dispatch void format(WSuite s, extension IFormattableDocument document) {
		s.regionFor.keyword(WollokConstants.SUITE).append [ oneSpace ]
		s.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ setNewLines(2) ].prepend [ oneSpace ]
		s.interior [ indent ]
		s.variableDeclarations.formatVariableDeclarations(document)
		s.fixture.format
		s.fixture.append [ setNewLines(2) ]
		s.methods.forEach [ format ]
		s.tests.forEach [ 
			format
			append [ setNewLines(2) ]
		]
		s.regionFor.keyword(WollokConstants.END_EXPRESSION).surround[ setNewLines(2) ]
	}

	def dispatch void format(WFixture f, extension IFormattableDocument document) {
		f.regionFor.keyword(WollokConstants.FIXTURE).append [ oneSpace ]
		f.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ newLine ].prepend [ oneSpace ]
		f.interior [ indent ]
		f.elements.forEach [ e | 
			e.surround [ newLine ]
			e.format(document, false) 
		]
		f.regionFor.keyword(WollokConstants.END_EXPRESSION).prepend[ newLine ]
	}

	def dispatch void format(WPostfixOperation o, extension IFormattableDocument document) {
		o.operand.append [ noSpace ]
	}

	def dispatch void format(WObjectLiteral o, extension IFormattableDocument document) {
		o.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ newLine ].prepend [ oneSpace ]
		o.members.forEach [
			surround [ indent ]
			format
			append [ newLine ]
		]
	}

	def dispatch void format(WUnaryOperation o, extension IFormattableDocument document) {
		o.interior [ noSpace ]
		o.operand.surround [ noSpace ]
	}

	def dispatch void format(WThrow t, extension IFormattableDocument document) {
		t.prepend [ oneSpace ]
		t.exception.prepend [ oneSpace ]
	}

	def dispatch void format(WMixin m, extension IFormattableDocument document) {
		m.regionFor.keyword(WollokConstants.MIXIN).prepend [ noSpace ]
		m.regionFor.keyword(WollokConstants.MIXIN).append [ oneSpace ]
		m.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ setNewLines(2) ].prepend [ oneSpace ]
		m.interior [ 
			indent
		]
		
		m.variableDeclarations.formatVariableDeclarations(document)

		m.methods.forEach [
			format
			append [ setNewLines(2) ]
		]
		
		m.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ setNewLines(2) ]
	}

	def dispatch void format(WPackage p, extension IFormattableDocument document) {
		p.regionFor.keyword(WollokConstants.PACKAGE).prepend [ noSpace ]
		p.regionFor.keyword(WollokConstants.PACKAGE).append [ oneSpace ]
		p.regionFor.keyword(WollokConstants.BEGIN_EXPRESSION).append[ setNewLines(2) ].prepend [ oneSpace ]
		p.interior [ 
			indent
		]
		p.elements.forEach [ format ]
		p.regionFor.keyword(WollokConstants.END_EXPRESSION).append[ setNewLines(2) ]
	}

	def dispatch void format(Import i, extension IFormattableDocument document) {
		i.regionFor.keyword(WollokConstants.IMPORT).prepend [ noSpace ]
		i.regionFor.keyword(WollokConstants.IMPORT).append [ oneSpace ]
	}
	
	def dispatch void format(WSuperInvocation s, extension IFormattableDocument document) {
		if (s.previousHiddenRegion.length > 1) {
			s.prepend [ oneSpace ]
		}
		s.regionFor.keyword(WollokConstants.SUPER).append [ noSpace ]
		s.memberCallArguments.forEach [ arg, i |
			if (i == 0) {
				arg.prepend [ noSpace ]
			} else {
				arg.prepend [ oneSpace ]
			}
			arg.append [ noSpace ]
			arg.format
		]
	}

	def dispatch void format(WSelfDelegatingConstructorCall s, extension IFormattableDocument document) {
		if (s.previousHiddenRegion.length > 1) {
			s.prepend [ oneSpace ]
		}
		s.regionFor.keyword(WollokConstants.SELF).append [ noSpace ]
		s.arguments.forEach [ arg, i |
			if (i == 0) {
				arg.prepend [ noSpace ]
			} else {
				arg.prepend [ oneSpace ]
			}
			arg.append [ noSpace ]
			arg.format
		]
	}

	def dispatch void format(WSuperDelegatingConstructorCall s, extension IFormattableDocument document) {
		if (s.previousHiddenRegion.length > 1) {
			s.prepend [ oneSpace ]
		}
		s.regionFor.keyword(WollokConstants.SUPER).append [ noSpace ]
		s.arguments.forEach [ arg, i |
			if (i == 0) {
				arg.prepend [ noSpace ]
			} else {
				arg.prepend [ oneSpace ]
			}
			arg.append [ noSpace ]
			arg.format
		]
	}
	
	/** 
	 * *******************************************************
	 * 
	 * INTERNAL DEFINITIONS
	 * 
	 * *********************************************************
	 */
	def dispatch operandShouldBeFormatted(EObject o) { false }
	def dispatch operandShouldBeFormatted(WMemberFeatureCall c) { true }
	def dispatch operandShouldBeFormatted(WUnaryOperation o) { true }
	def dispatch operandShouldBeFormatted(WBinaryOperation o) { true }
	def dispatch operandShouldBeFormatted(WListLiteral l) { true }
	def dispatch operandShouldBeFormatted(WSetLiteral l) { true }

	def void formatVariableDeclarations(Iterable<WVariableDeclaration> variableDeclarations, extension IFormattableDocument document) {
		variableDeclarations.forEach [ variableDecl, i |
			if (i > 0) {
				variableDecl.prepend [ newLine ] 
			}
			variableDecl.format
			if (variableDeclarations.size - 1 == i) {
				variableDecl.append [ setNewLines(2) ]
			} else {
				variableDecl.append [ newLine ]
			}
		]	
	}

	def void formatTests(Iterable<WTest> tests, extension IFormattableDocument document) {
		tests.forEach [ test, i |
			test.format
			if (tests.size - 1 == i) {
				test.append [ newLine ]
			} else {
				test.append [ setNewLines(2) ]
			}
		]	
	}

	def formatParameters(Iterable<WParameter> parameters, extension IFormattableDocument document) {
		parameters.forEach [ parameter, i |
			parameter.append [ noSpace ]
			if (i == 0) {
				parameter.prepend [ noSpace ]
			} else {
				parameter.prepend [ oneSpace ]		
			} 
		]
	}	
}