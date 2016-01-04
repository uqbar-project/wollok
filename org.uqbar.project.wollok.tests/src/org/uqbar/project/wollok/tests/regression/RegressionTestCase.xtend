package org.uqbar.project.wollok.tests.regression

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author jfernandes
 */
class RegressionTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void bug_38() {
			'''object pajarera {
		    var pajaros = #[pepita,pepe,pepona]
		
		    method agregarA(pajaro){
		        pajaros.add(pajaro)
		    }
		
		    method sacarA(pajaro){
		        pajaros.remove(pajaro)
		    }
		
		    method cuantosHay(){
		        return pajaros.size()
		    }
		
		    method getPajaros(){
		        return pajaros
		    }
		
		    method alimentarATodosCon(comida){
		        pajaros.forEach[p|p.comer(comida)]
		    }
		
		    method hacerVolarATodas20M(metros){
		        pajaros.forEach[p|p.volar(metros)]
		    }
		
		    method cualEstaSaludable(){
		        return pajaros.filter[p|p.energia() > 100]
		    }
		
		    method retornaEnergias(energiaMinima){
		        return  pajaros.filter[p|p.energia() < energiaMinima]
		    }
		
		    method el(){
		        var filtro1 = #[]
		        var filtro2 = #[]
		        var filtro3 = #[]
		
		        filtro1 = pajaros.filter[p|p.energia() <= pepita.energia()]
		        filtro2 = filtro1.filter[pp|pp.energia() <= pepona.energia()]
		        filtro3 = filtro2.filter[ppp|ppp.energia() <= pepe.energia()]
		
		
		        //var filtro2 = filtro1.filter[pp|pp.energia() > pepe.energia()]
		        //return filtro2.filter[ppp|[ppp.energia() > pepona.energia()]]
		
		        return this.comparaEnergia(filtro3)
		    }
		
		    method alimentaBajaEnergia(filtro3){
		        filtro3.forEach[pppp|pppp.com()]
		        //pepe.com()
		        this.comparaEnergia(filtro3)
		    }
		
		    method comparaEnergia(filtro3){
		        var filtro4 = #[]
		        filtro4 = filtro3.filter[p|p.energia() >= 30]
		
		        if (filtro4.size() == 0) {    
		            this.alimentaBajaEnergia(filtro3)
		            return pepe.energia()
		        }else{
		            return "La energia de pepe es 30"
		        }
		    }
		
		    method esta(pajaro){
		        return pajaros.contains(pajaro)
		    }
		
		    method getEnergias(){
		        return pajaros.map[p|p.energia()]
		    }
		
		    method estanTodosVivos(){
		        return pajaros.forAll[p|p.energia() > 0]
		    }
		}
		object pepita {
		    var energia = 30
		
		    method volar(metros){
		        return energia -= 10
		    }
		
		    method comer(comida){
		        energia -= comida.energia()
		    }
		    method energia(){
		        return energia
		    }
		}
		
		object pepona {
		    var energia = 20
		
		    method volar(metros){
		        return energia -= 20
		    }
		
		    method comer(comida){
		        energia -= comida.energia()
		    }
		    method energia(){
		        return energia
		    }
		}
		
		object pepe {
		    var energia = 10
		
		    method volar(metros){
		        return energia -= 5
		    }
		
		    method comer(comida){
		        energia -= comida.energia()
		    }
		
		    method com(){
		        energia += 10
		    }
		
		    method energia(){
		        return energia
		    }
		
		}'''.interpretPropagatingErrors
}

	@Test
	def void bug_213() {
		'''object pepita inherits Golondrina {
			}
	
		class Golondrina {
		    var energia = 100
		    method volar(kms) {
		        this.modificar(-kms * 2)
		    }
		    method modificar(n) {
		        energia += n 
		    }
		    method getEnergia() = energia
		}
		
		program p {
			pepita.volar(2)		
		}
		'''.interpretPropagatingErrors
	}
	
}