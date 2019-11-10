package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class ChangeVarToConstQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def testChangeVarToConstInObject() {
		val initial = #['''
			object anObject {
				var shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']

		val result = #['''
			object anObject {
				const shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeMethodLocalVarToConstInObject() {
		val initial = #['''
			object anObject {
				method getShouldBeConst(valor) {
					var shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']

		val result = #['''
			object anObject {
				method getShouldBeConst(valor) {
					const shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeVarToConstInClass() {
		val initial = #['''
			class MyClass {
				var shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']

		val result = #['''
			class MyClass {
				const shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeMethodLocalVarToConstInClass() {
		val initial = #['''
			class MyClass {
				method getShouldBeConst(valor) {
					var shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']

		val result = #['''
			class MyClass {
				method getShouldBeConst(valor) {
					const shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeVarToConstInMixin() {
		val initial = #['''
			mixin MyMixin {
				var shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']

		val result = #['''
			mixin MyMixin {
				const shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeMethodLocalVarToConstInMixin() {
		val initial = #['''
			mixin MyMixin {
				method getShouldBeConst(valor) {
					var shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']

		val result = #['''
			mixin MyMixin {
				method getShouldBeConst(valor) {
					const shouldBeConst = 10
					if (valor == 10) {
						return shouldBeConst + 10
					} else {
						return shouldBeConst - 10
					}
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeVarToConstInDescribe() {
		val initial = #['''
			describe "Variable should be const" {
				var variable = 123
				test "trivial" {
				assert.notEquals(variable, 123)
				}
			}
		''']

		val result = #['''
			describe "Variable should be const" {
				const variable = 123
				test "trivial" {
				assert.notEquals(variable, 123)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}

	@Test
	def testChangeVarToConstInTest() {
		val initial = #['''
			describe "Variable should be const" {
				test "trivial" {
				var variable = 123
				assert.notEquals(variable, 123)
				}
			}
		''']

		val result = #['''
			describe "Variable should be const" {
				test "trivial" {
				const variable = 123
				assert.notEquals(variable, 123)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}
}
