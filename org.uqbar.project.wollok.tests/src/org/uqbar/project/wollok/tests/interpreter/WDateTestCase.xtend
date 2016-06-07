package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author dodain
 */
class WDateTestCase extends AbstractWollokInterpreterTestCase {

	
	@Test
	def void unDateNoTieneTiempoEntoncesDosNowEnMomentosDistintosSonIguales() {
		'''program a {
			const ahora1 = new WDate()
			const ahora2 = new WDate() 
			assert.that(ahora1.equals(ahora2))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void dosDatesIgualesPuedenSerDistintosObjetos() {
		'''program a {
			const ahora1 = new WDate()
			const ahora2 = new WDate() 
			assert.that(ahora1.equals(ahora2))
			assert.notThat(ahora1 == ahora2)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void El2000FueBisiesto() {
		'''program a {
			const el2000 = new WDate(4, 5, 2000)
			assert.that(el2000.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2001NoFueBisiesto() {
		'''program a {
			const el2001 = new WDate(4, 5, 2001)
			assert.notThat(el2001.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2004FueBisiesto() {
		'''program a {
			const el2004 = new WDate(4, 5, 2004)
			assert.that(el2004.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void El2100NoSeraBisiesto() {
		'''program a {
			const el2100 = new WDate(4, 5, 2100)
			assert.notThat(el2100.isLeapYear())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void ayerEsMenorQueHoy() {
		'''program a {
			var ayer = new WDate()
			ayer = ayer.minusDays(1)
			const hoy = new WDate()
			assert.that(ayer < hoy) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void unaFechaDel2001EsMenorQueHoy() {
		'''program a {
			const elAyer = new WDate(10, 6, 2001)
			const hoy = new WDate()
			assert.that(elAyer < hoy) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void hoyEstaEntreAyerYManiana() {
		'''program a {
			var ayer = new WDate()
			ayer = ayer.minusDays(1)
			const hoy = new WDate()
			var maniana = new WDate()
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
			const dia = new WDate(7, 6, 2016)
			assert.equals(dia.dayOfWeek(), 2) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void diferenciaDeDosFechasDistintas() {
		'''program a {
			const dia1 = new WDate(7, 6, 2016)
			const dia2 = new WDate(9, 7, 2016)
			assert.equals(dia2 - dia1, 32) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void diferenciaDeDosFechasIguales() {
		'''program a {
			const dia1 = new WDate()
			const dia2 = new WDate()
			assert.equals(dia2 - dia1, 0) 
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sumoDosMeses() {
		'''program a {
			const diaOriginal = new WDate(31, 12, 2015)
			const diaFinal = new WDate(29, 2, 2016)
			const result = diaOriginal.plusMonths(2)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void restoDosMeses() {
		'''program a {
			const diaOriginal = new WDate(29, 2, 2016)
			const diaFinal = new WDate(29, 12, 2015)
			const result = diaOriginal.minusMonths(2)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sumoUnAnio() {
		'''program a {
			const diaOriginal = new WDate(29, 2, 2016)
			const diaFinal = new WDate(28, 2, 2017)
			const result = diaOriginal.plusYears(1)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void restoUnAnio() {
		'''program a {
			const diaOriginal = new WDate(28, 2, 2017)
			const diaFinal = new WDate(28, 2, 2016)
			const result = diaOriginal.minusYears(1)
			assert.that(result.equals(diaFinal))
		}
		'''.interpretPropagatingErrors
	}
		
}	
