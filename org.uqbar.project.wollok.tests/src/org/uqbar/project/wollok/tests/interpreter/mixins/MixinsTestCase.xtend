package org.uqbar.project.wollok.tests.interpreter.mixins

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author jfernandes
 */
class MixinsTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void simpleMixinWithMethod() {
		'''
		mixin Flies {
			method fly() {
				console.println("I'm flying")
			}
		}
		class Bird mixed with Flies {}
		program t {
			const b = new Bird()
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
				const b = new WalkingBird()
				b.walk(10)
				assert.equals(10, b.walkedDistance())
		}
		'''.interpretPropagatingErrors
	}
	
	// is it ok to have 'protected' variables ?
	// this is inconsistent with the way wollok handles variables in classes in a hierarchy
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
				const b = new Bird()
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
				const b = new C()
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
				const b = new Bird()
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
			method reduceEnergy(amount) {
				energy -= amount
			}
		}
		
		mixin Flying {
			var fliedMeters = 0
			method fly(meters) {
				self.reduceEnergy(meters)
				fliedMeters += meters
			}
			method fliedMeters() = fliedMeters
			
			method reduceEnergy(meters)
		}
		
		class BirdWithEnergyThatFlies mixed with Energy, Flying {}
		
		// order doesn't matter
		
		class BirdWithThatFliesWithEnergy mixed with Flying, Energy {}
		
		program t {
				const b = new BirdWithEnergyThatFlies()
				b.fly(10)
				assert.equals(90, b.energy())
				assert.equals(10, b.fliedMeters())
				
				const b2 = new BirdWithThatFliesWithEnergy()
				b2.fly(10)
				assert.equals(90, b2.energy())
				assert.equals(10, b2.fliedMeters())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixinMethodCallsAMethodOnTheClass() {
		'''
		mixin FlyingShortcuts {
			method fly100Meters() {
				self.fly(100)
			}
			method fly(meters)
		}
		
		class BirdWithFlyingShortCuts mixed with FlyingShortcuts {
			var energy = 200
			override method fly(meters) { energy -= meters }
			method energy() = energy
		}
		
		program t {
			const b = new BirdWithFlyingShortCuts()
			b.fly100Meters()
			assert.equals(100, b.energy())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixinMethodCallsAMethodOnTheClassThatIsInherited() {
		'''
		class Bird {
			var energy = 200
			method fly(meters) { energy -= meters }
			method energy() = energy
		}
		
		mixin FlyingShortcuts {
			method fly100Meters() {
				self.fly(100)
			}
			method fly(meters)
		}
		
		class MockingBird inherits Bird mixed with FlyingShortcuts {
		}
		
		program t {
			const b = new MockingBird()
			b.fly100Meters()
			assert.equals(100, b.energy())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classOverridesMethodFromMixin() {
		'''
		mixin Energy {
			var energy = 100
			method reduceEnergy(amount) { energy -= amount }
			method energy() = energy
		}
		
		class Bird mixed with Energy {
			override method reduceEnergy(amount) { 
				// does nothing
			}
		}
		
		program t {
			const b = new Bird()
			b.reduceEnergy(100)
			assert.equals(100, b.energy())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void classOverridesMethodFromMixinAndCallSuper() {
		'''
		mixin Energy {
			var energy = 100
			method reduceEnergy(amount) { energy -= amount }
			method energy() = energy
		}
		
		class Bird mixed with Energy {
			override method reduceEnergy(amount) { 
				super(1)
			}
		}
		
		program t {
			const b = new Bird()
			b.reduceEnergy(100)
			assert.equals(99, b.energy())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void stackableMixinsPattern() {
		'''
		mixin M1 {
			method doFoo(chain) { super(chain + " > M1") }
		}
		
		mixin M2 {
			method doFoo(chain) { super(chain + "> M2") }
		}
		
		class C1 {
			var foo = ""
			method doFoo(chain) { foo = chain + " > C1" }
			method foo() = foo
		}
		
		class C2 inherits C1 mixed with M1, M2 {
		}
		
		program t {
			const c = new C2()
			c.doFoo("Test ")
			assert.equals("Test > M2 > M1 > C1", c.foo())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixinOnAWKO() {
		'''
		mixin Flies {
			var times = 0
			method fly() {
				times = 1
			}
			method times() = times
		}
		
		object pepita mixed with Flies {}
		
		program t {
			pepita.fly()
			assert.equals(1, pepita.times())
		} 
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixinVariablesAreInScopeOnAWKO() {
		'''
		mixin Flies {
			var times = 0
			method fly() {
				times = 1
			}
			method times() = times
		}
		
		object pepita mixed with Flies {
			method rest() {
				times = 0
			}
		}
		
		program t {
			pepita.fly()
			assert.equals(1, pepita.times())
			pepita.rest()
			assert.equals(0, pepita.times())
		} 
		'''.interpretPropagatingErrors
	}
	@Test
	def void mixinOnAWKOOverridingAMethod() {
		'''
		mixin Flies {
			var times = 0
			method fly() {
				times = 1
			}
			method times() = times
		}
		
		object pepita mixed with Flies {
			override method fly() {}
		}
		
		program t {
			pepita.fly()
			assert.equals(0, pepita.times())
		} 
		'''.interpretPropagatingErrors
	}
	
	// OBJECT LITERALS
	
	@Test
	def void mixinOnObjectLiterals() {
		'''
		mixin Flies {
			var times = 0
			method fly() {
				times = 1
			}
			method times() = times
		}
		
		program t {
			const pepita = object mixed with Flies {}
			pepita.fly()
			assert.equals(1, pepita.times())
		} 
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixinOnObjectLiteralOverridingAMethod() {
		'''
		mixin Flies {
			var times = 0
			method fly() {
				times = 1
			}
			method times() = times
		}
		
		program t {
			const pepita = object mixed with Flies {
				override method fly() {}
			}
			pepita.fly()
			assert.equals(0, pepita.times())
		} 
		'''.interpretPropagatingErrors
	}
	
}