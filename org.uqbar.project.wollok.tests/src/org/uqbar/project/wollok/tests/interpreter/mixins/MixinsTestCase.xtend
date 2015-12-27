package org.uqbar.project.wollok.tests.interpreter.mixins

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author jfernandes
 */
class MixinsTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testSimpleMixinWithMethod() {
		'''
		mixin Flies {
			method fly() {
				console.println("I'm flying")
			}
		}
		class Bird mixed with Flies {
			
		}
		program t {
			val b = new Bird()
			b.fly()
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classWithMixinThatModifiesTheMixinStateFromTheMixin() {
		'''
		mixin Walks {
			var walkedDistance = 0
			method walk(distance) {
				walkedDistance += distance
			}
			method walkedDistance() = walkedDistance
		}
		
		class WalkingBird mixed with Walks {}
		program t {
				val b = new WalkingBird()
				b.walk(10)
				assert.equals(10, b.walkedDistance())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classModifiesAVariableInheritedFromTheMixin() {
		'''
		mixin Energy {
			var energy = 100
		}
		
		class Bird mixed with Energy {
			method fly(meters) {
				energy -= meters
			}
			method energy() = energy
		}
		program t {
				val b = new Bird()
				b.fly(10)
				assert.equals(90, b.energy())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void simpleMultipleMixins() {
		'''
		mixin M1 {}
		mixin M2 {}
		
		class C mixed with M1 and M2 {
		}
		program t {
				val b = new C()
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classWithTwoIsolatedMixins() {
		'''
		mixin Energy {
			var energy = 100
			method energy() = energy
		}
		
		mixin Mojo {
			var mojo = 0
			method mojo() = mojo
		}
		
		class Bird mixed with Energy, Mojo {
			method fly(meters) {
				energy -= meters
				mojo += 1
			}
			
		}
		program t {
				val b = new Bird()
				b.fly(10)
				assert.equals(90, b.energy())
				assert.equals(1, b.mojo())
				
				b.fly(10)
				assert.equals(80, b.energy())
				assert.equals(2, b.mojo())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classWithAMixinThatCallsAnother() {
		'''
		mixin Energy {
			var energy = 100
			method energy() = energy
		}
		
		mixin Flying {
			var fliedMeters = 0
			method fly(meters) {
				energy -= meters
				fliedMeters += meters
			}
			method fliedMeters() = fliedMeters
		}
		
		class Bird mixed with Energy, Flying {
		}
		
		program t {
				val b = new Bird()
				b.fly(10)
				assert.equals(90, b.energy())
				assert.equals(10, b.fliedMeters())
		}
		'''.interpretPropagatingErrors
	}
	
}