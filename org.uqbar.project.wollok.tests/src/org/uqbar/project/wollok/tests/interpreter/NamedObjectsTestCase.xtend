package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class NamedObjectsTestCase extends AbstractWollokInterpreterTestCase {
	@Test
	def void effects() {
		#[
			'''
				object pepita {
					var energy = 0
					method energyLevel(){
						return energy
					}
					
					method addEnergy(amount){
						energy = energy + amount
					}
				}

				program namedObjects{
					assert.equals(0, pepita.energyLevel())
					pepita.addEnergy(10)
					assert.equals(10, pepita.energyLevel())
				}
			'''
		].interpretPropagatingErrors
	}

	@Test
	def unusedVariables() {
		val model = '''
			object pepita {
				var energia = 0
				method getEnergia(){ return energia }
				method setEnergia(x){ energia = x }
			}
		'''.parse

		model.assertNoIssues
	}

	@Test
	def void usingThis() {
		'''
			object pepita {
				method uno(){
					return this.otro()
				}
				method otro(){
					return 5
				}
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void referencingObject() {
		'''
			object pp {
			    val ps = #[pepita]
			    
			    method unMethod(){
			        var x = pepita
			        return x
			    }
			
			    method getPs(){
			        return ps
			    }
			}
			
			object pepita {}
			
			program xxx{
				pp.unMethod()
				assert.equals(pepita, pp.getPs().get(0))
			}
		'''.interpretPropagatingErrors
	}
}
