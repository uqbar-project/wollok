package org.uqbar.project.wollok.tests.interpreter.contracts

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests wollok "contracts" (Design-by-contract)
 * 
 * @author jfernandes
 */
class ContractsTestCase extends AbstractWollokInterpreterTestCase {
	
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
				val b = new Bird()
				assert.throwsException{ => b.fly(0) }
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
				val b = new Bird()
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
				val b = new Bird()
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
				val b = new Bird()
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
				val b = new Bird()
				try 
					b.fly(200)
				catch e {
					assert.equals('Method requirements not met: Not satisfied (kms <= 100)', e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
}