package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests named objecst inheriting from a class
 * 
 * @author jfernandes
 */
class UnnamedObjectInheritanceTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testObjectInheritingFromAClass() {
		'''
		class Auto {
			var property kms
			
			constructor(_kms) {
				kms = _kms
			}
		}
		
		program p {
			var n = 33
			
			const o = object inherits Auto(2000) {
				method getN() {
					return n
				}
			} 
			
			assert.equals(2000, o.kms())
		}'''.interpretPropagatingErrors
	}

	@Test
	def void testObjectInheritingFromAClassNamedParameters() {
		'''
		class Auto {
			var property kms
			var property owner
		}
		
		program p {
			var n = 33
		
			const o = object inherits Auto(owner = 'dodain', kms = 2000) {
				method getN() {
					return n
				}
			}
		
			assert.equals(2000, o.kms())
		}'''.interpretPropagatingErrors
	}
		
}