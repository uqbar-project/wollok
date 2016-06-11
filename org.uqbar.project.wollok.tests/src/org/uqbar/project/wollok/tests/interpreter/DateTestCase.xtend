package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author dodain
 */
class DateTestCase extends AbstractWollokInterpreterTestCase {

	
	@Test
	def void unDateNoTieneTiempoEntoncesDosNowEnMomentosDistintosSonIguales() {
		'''program a {
			const ahora1 = new Date()
			const ahora2 = new Date() 
			assert.that(ahora1.equals(ahora2))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void dosDatesIgualesPuedenSerDistintosObjetos() {
		'''program a {
			const ahora1 = new Date()
			const ahora2 = new Date() 
			assert.that(ahora1.equals(ahora2))
			assert.notThat(ahora1 == ahora2)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void El2000FueBisiesto() {
		'''program a {
			const el2000 = new Date(4, 5, 2000)
			assert.that(el2000.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2001NoFueBisiesto() {
		'''program a {
			const el2001 = new Date(4, 5, 2001)
			assert.notThat(el2001.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2004FueBisiesto() {
		'''program a {
			const el2004 = new Date(4, 5, 2004)
			assert.that(el2004.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2100NoSeraBisiesto() {
		'''program a {
			const el2100 = new Date(4, 5, 2100)
			assert.notThat(el2100.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void ayerEsMenorQueHoy() {
		'''program a {
			var ayer = new Date()
			ayer = ayer.minusDays(1)
			const hoy = new Date()
			assert.that(ayer < hoy) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void unaFechaDel2001EsMenorQueHoy() {
		'''program a {
			const elAyer = new Date(10, 6, 2001)
			const hoy = new Date()
			assert.that(elAyer < hoy) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void hoyEstaEntreAyerYManiana() {
		'''program a {
			var ayer = new Date()
			ayer = ayer.minusDays(1)
			const hoy = new Date()
			var maniana = new Date()
			maniana = maniana.plusDays(1)
			assert.that(hoy > ayer)
			assert.that(hoy >= ayer)
			assert.that(hoy < maniana)
			assert.that(hoy <= maniana)
			assert.that(hoy.between(ayer, maniana)) 
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void unDiaMartesEsElSegundoDiaDeLaSemana() {
		'''program a {
			const dia = new Date(7, 6, 2016)
			assert.equals(dia.dayOfWeek(), 2) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void diferenciaDeDosFechasDistintas() {
		'''program a {
			const dia1 = new Date(7, 6, 2016)
			const dia2 = new Date(9, 7, 2016)
			assert.equals(dia2 - dia1, 32) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void diferenciaDeDosFechasIguales() {
		'''program a {
			const dia1 = new Date()
			const dia2 = new Date()
			assert.equals(dia2 - dia1, 0) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sumoDosMeses() {
		'''program a {
			const diaOriginal = new Date(31, 12, 2015)
			const diaFinal = new Date(29, 2, 2016)
			const result = diaOriginal.plusMonths(2)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void restoDosMeses() {
		'''program a {
			const diaOriginal = new Date(29, 2, 2016)
			const diaFinal = new Date(29, 12, 2015)
			const result = diaOriginal.minusMonths(2)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sumoUnAnio() {
		'''program a {
			const diaOriginal = new Date(29, 2, 2016)
			const diaFinal = new Date(28, 2, 2017)
			const result = diaOriginal.plusYears(1)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void restoUnAnio() {
		'''program a {
			const diaOriginal = new Date(28, 2, 2017)
			const diaFinal = new Date(28, 2, 2016)
			const result = diaOriginal.minusYears(1)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}
		
}	
