package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class LazyInitTestCase extends AbstractWollokInterpreterTestCase {
	
	def commonDefinitions() {
		'''
		class C {
		  const property x
		}
		
		object pepita {
		  var property energia
		
		  override method initialize() {
		    energia = 2
		  }
		}
		'''
	}

	@Test
	def void lazyInheritsWithEffectBefore() {
		'''
		«commonDefinitions»		

		object w inherits C(x = pepita.energia()) { }
		
		test "Lazy inherits with effect before" {
		  pepita.energia(3)
		  assert.equals(3, w.x())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void lazyConstInstanceWithEffectBefore() {
		'''
		«commonDefinitions»		

		const i = new C(x = pepita.energia())
		
		test "Lazy const instance with effect before" {
		  pepita.energia(3)
		  assert.equals(3, i.x())
		}
		'''.interpretPropagatingErrors
	}
	
	
}