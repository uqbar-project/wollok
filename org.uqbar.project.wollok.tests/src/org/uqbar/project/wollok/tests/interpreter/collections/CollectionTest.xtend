package org.uqbar.project.wollok.tests.interpreter.collections

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class CollectionTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testCollectionAsInstanceVariable() { #['''
		object pajarera{
			val pajaros = #[]
			method agregar(unPajaro){
				pajaros.add(unPajaro)
			}
			method quitar(unPajaro){
				pajaros.remove(unPajaro)
			}
			method cantidad(){
				return pajaros.size()
			}
		}
		
		object pepita{
			
		}

		program p {
			pajarera.agregar(pepita)
			pajarera.quitar(pepita)
			assert.that(pajarera.cantidad() == 0)
		}'''].interpretPropagatingErrors
	}
	
	@Test
	def void test_issue_40() {
		'''
		object pajarera {
		    var energiaMenor = 100 
		    var pajaros = #[pepita, pepe]
		    method menorValor(){
		        pajaros.forEach[a | a.sosMenor(energiaMenor)]
		        return energiaMenor
		    }      
		
		    method setEnergiaMenor(valor){
		        energiaMenor = valor
		    }
		}
		
		object pepe {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(10)
		    }
		}
		
		object pepita {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(25)
		    }
		}
		program p {
			val menor = pajarera.menorValor()
			assert.equals(10, menor)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAddAll() { 
		'''
		program p {
			val unos = #[1,2,3,4]
			val otros = #[5,6,7,8]
			
			val todos = #[]
			todos.addAll(unos)
			todos.addAll(otros)			
			assert.equals(8, todos.size())
		}'''.interpretPropagatingErrors
	}

	@Test
	def void testFlatMap() {
		'''
		program p {
			assert.equals(#[1,2,3,4], #[#[1,2], #[3,4]].flatten())
			assert.equals(#[1,2,3,4], #[#[1,2], #[], #[3,4]].flatten())
			assert.equals(#[], #[].flatten())
			assert.equals(#[], #[#[]].flatten())
		}'''.interpretPropagatingErrors
	}
}
