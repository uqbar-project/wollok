package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class GlobalConstantsTestCase extends AbstractWollokInterpreterTestCase {
	@Test
	def void effects() {
		#[
			'''
				class Golondrina {
					var energy = 0
					method energyLevel(){
						return energy
					}
					
					method addEnergy(amount){
						energy = energy + amount
					}
				}
				
				const pepita = new Golondrina()

				program globalConstants {
					assert.equals(0, pepita.energyLevel())
					pepita.addEnergy(10)
					assert.equals(10, pepita.energyLevel())
				}
			'''
		].interpretPropagatingErrors
	}

	@Test
	def void references() {
		'''
			class Golondrina {
				var property energia = 0
				
				method entrenar() { energia += 1 }
			}
			
			class Entrenador {
			    const property ave
			    method entrenar() { ave.entrenar() }
			}
			
			const chuck = new Entrenador(ave = pepita)
			
			const pepita = new Golondrina()
			
			program xxx {
				assert.equals(0, pepita.energia())
				chuck.entrenar()
				assert.equals(1, pepita.energia())
			}
		'''.interpretPropagatingErrors
	}
}
