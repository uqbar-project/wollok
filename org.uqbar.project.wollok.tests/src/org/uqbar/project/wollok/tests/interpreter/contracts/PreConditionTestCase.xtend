package org.uqbar.project.wollok.tests.interpreter.contracts

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests wollok "contracts" (Design-by-contract)
 * 
 * @author jfernandes
 */
class PreConditionTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void simplePreConditionForSingleParameterInClass() {
		'''
			class Bird {
				var energy = 1000
				
				method fly(kms) {
					energy -= kms
				}
				requires kms > 0
			}
			test "simplePreConditionForSingleParameterInClass" {
				const b = new Bird()
				assert.throwsExceptionWithMessage("Method requirements not met: Not satisfied (kms > 0)", { => b.fly(0) })
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void twoPreConditionsOneForParamOtherForInstanceVariableInClass() {
		'''
			class Bird {
				var energy = 10

				method fly(kms) {
					energy -= kms
				}
				requires kms > 0 and energy >= kms
			}
			test "simplePreConditionForSingleParameterInClass" {
				const b = new Bird()
				assert.throwsException{ => 
					b.fly(20)  // tried to fly more than allowed by current energy
				}
			}
		'''.interpretPropagatingErrors
	}
	
	// ***************************
	// ** ERROR MESSAGES
	// ***************************
		
	@Test
	def void producedErrorMessageWhenFailingJustOne() {
		'''
			class Bird {
				var energy = 1000
				
				method fly(kms) {
					energy -= kms
				}
				requires 
					kms > 0 : 'Cannot fly negative distances'
					energy >= kms : 'Cannot fly more than its energy'
			}
			test "simplePreConditionForSingleParameterInClass" {
				const b = new Bird()
				try 
					b.fly(0)
				catch e {
					assert.equals('Method requirements not met: Cannot fly negative distances (kms > 0)', e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void producedErrorMessageWhenFailingTwoOneSimultaneously() {
		'''
			class Bird {
				var energy = 10
				
				method fly(kms) {
					energy -= kms
				}
				requires 
					kms <= 100 : 'Cannot fly more than 100 meters at a time'
					energy >= kms : 'Cannot fly more than its energy'
			}
			test "simplePreConditionForSingleParameterInClass" {
				const b = new Bird()
				try 
					b.fly(200)
				catch e {
					assert.equals('Method requirements not met: Cannot fly more than 100 meters at a time (kms <= 100), Cannot fly more than its energy (energy >= kms)', e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void producedErrorMessageForRequirementWithoutMessage() {
		'''
			class Bird {
				var energy = 10
				
				method fly(kms) {
					energy -= kms
				}
				requires 
					kms <= 100
			}
			test "simplePreConditionForSingleParameterInClass" {
				const b = new Bird()
				try 
					b.fly(200)
				catch e {
					assert.equals('Method requirements not met: Not satisfied (kms <= 100)', e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void preConditionCallingASelfMethod() {
		'''
			class Bird {
				var energy = 10
				
				method fly(kms) {
					energy -= kms
				}
				requires kms <= self.upperKmsBound()
					
				method upperKmsBound() = 100
			}
			test "preConditionCallingASelfMethod" {
				const b = new Bird()
				try 
					b.fly(200)
				catch e {
					assert.equals('Method requirements not met: Not satisfied (kms <= self.upperKmsBound())', e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void inheritedPreCondition() {
		'''
			class Bird {
				var energy = 10
				
				method fly(kms) {
					energy -= kms
				}
				requires kms <= 100
					
			}
			class Sparrow inherits Bird {
			}
			test "Inherited Pre Condition must also be checked on subclasses" {
				assert.throwsExceptionWithMessage('Method requirements not met: Not satisfied (kms <= 100)', {=> 
					const b = new Sparrow()
					b.fly(200)
				})
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void preConditionFromMixinMethod() {
		'''
		    mixin Walker {
		    	var walkedDistance = 0
		    	method walk(kms) {
					walkedDistance += kms
				}
				requires kms > 0
		    }
			class Bird mixed with Walker {
					
			}

			test "Inherited Pre Condition must also be checked on subclasses" {
				assert.throwsExceptionWithMessage('Method requirements not met: Not satisfied (kms > 0)', { => 
					const b = new Bird()
					b.walk(-1)
				})
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void inheritedPreConditionOverridingMethod() {
		'''
			class Bird {
				var energy = 10
				
				method fly(kms) {
					energy -= kms
				}
				requires kms <= 100
				
				method energy() = energy	
			}
			class Sparrow inherits Bird {
				var flied = 0
				override method fly(kms) {
					// without calling super !
					flied += kms
				}
				method flied() = flied
			}
			test "Inherited Pre Condition must also be checked on subclasses even if the method is overriden" {
				const b = new Sparrow()
				assert.throwsExceptionWithMessage('Method requirements not met: Not satisfied (kms <= 100)', {=> 
					b.fly(200)
				})
			}
		'''.interpretPropagatingErrors
	}
	
}