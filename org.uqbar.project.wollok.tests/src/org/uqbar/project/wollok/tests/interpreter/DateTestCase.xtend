package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author dodain
 */
class DateTestCase extends AbstractWollokInterpreterTestCase {

	
	@Test
	def void twoDatesAreEqualsBecauseTheyHaveNoTime() {
		'''
		const now1 = new Date()
		const now2 = new Date() 
		assert.that(now1.equals(now2))
		assert.that(now1 == now2)
		'''.test
	}

	def void twoEqualDatesCanBeDifferentObject() {
		'''
		const now1 = new Date()
		const now2 = new Date() 
		assert.that(now1 == now2)
		assert.that(now1 !== now2)
		'''.test
	}
	
	@Test
	def void year2000WasLeap() {
		'''
		const year2000 = new Date(4, 5, 2000)
		assert.that(year2000.isLeapYear())
		'''.test
	}

	// Default behavior is truncate decimals
	// We should add more tests changing IDE preferences
	@Test
	def void year2000WasLeapWithDecimals() {
		'''
		const year2000 = new Date(4.8, 5.1, 2000.7)
		assert.that(year2000.isLeapYear())
		'''.test
	}
	@Test
	def void year2001WasNotLeap() {
		'''
		const year2001 = new Date(4, 5, 2001)
		assert.notThat(year2001.isLeapYear())
		'''.test
	}

	@Test
	def void year2004WasLeap() {
		'''
		const year2004 = new Date(4, 5, 2004)
		assert.that(year2004.isLeapYear())
		'''.test
	}

	@Test
	def void year2100WasNotLeap() {
		'''
		const year2100 = new Date(4, 5, 2100)
		assert.notThat(year2100.isLeapYear())
		'''.test
	}

	@Test
	def void yesterdayIsLessThanToday() {
		'''
		var yesterday = new Date()
		yesterday = yesterday.minusDays(1)
		const today = new Date()
		assert.that(yesterday < today) 
		'''.test
	}

	@Test
	def void a2001DateIsLessThanToday() {
		'''
		const elyesterday = new Date(10, 6, 2001)
		const today = new Date()
		assert.that(elyesterday < today) 
		'''.test
	}

	@Test
	def void todayIsBetweenYesterdayAndTomorrow() {
		'''
		var yesterday = new Date()
		yesterday = yesterday.minusDays(1)
		const today = new Date()
		var tomorrow = new Date()
		tomorrow = tomorrow.plusDays(1)
		assert.that(today > yesterday)
		assert.that(today >= yesterday)
		assert.that(today < tomorrow)
		assert.that(today <= tomorrow)
		assert.that(today.between(yesterday, tomorrow)) 
		'''.test
	}
	
	@Test
	def void tuesdayIsSecondDayOfWeek() {
		'''
		const aDay = new Date(7, 6, 2016)
		assert.equals(aDay.dayOfWeek(), 2) 
		'''.test
	}

	@Test
	def void differenceBetweenDates() {
		'''
		const day1 = new Date(7, 6, 2016)
		const day2 = new Date(9, 7, 2016)
		assert.equals(day2 - day1, 32) 
		'''.test
	}

	@Test
	def void differenceBetweenEqualDates() {
		'''
		const day1 = new Date()
		const day2 = new Date()
		assert.equals(day2 - day1, 0) 
		'''.test
	}

	@Test
	def void addTwoMonths() {
		'''
		const originalDay = new Date(31, 12, 2015)
		const finalDay = new Date(29, 2, 2016)
		const result = originalDay.plusMonths(2)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractTwoMonths() {
		'''
		const originalDay = new Date(29, 2, 2016)
		const finalDay = new Date(29, 12, 2015)
		const result = originalDay.minusMonths(2)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractTwoMonthsPassingDecimals() {
		'''
		const originalDay = new Date(29, 2, 2016)
		const finalDay = new Date(29, 12, 2015)
		const result = originalDay.minusMonths(2.4)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void addOneYear() {
		'''
		const originalDay = new Date(29, 2, 2016)
		const finalDay = new Date(28, 2, 2017)
		const result = originalDay.plusYears(1)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractOneYear() {
		'''
		const originalDay = new Date(28, 2, 2017)
		const finalDay = new Date(28, 2, 2016)
		const result = originalDay.minusYears(1)
		assert.that(result.equals(finalDay))
		'''.test
	}
		
	@Test
	def void toStringDefaultTest() {
		'''
		const aDay = new Date(28, 12, 2016)
		assert.equals("a Date[day = 28, month = 12, year = 2016]", aDay.toString())
		assert.equals("a Date[day = 28, month = 12, year = 2016]", aDay.toSmartString(false))
		'''.test
	}
	
	@Test
	def void toStringWithA1DigitMonthTest() {
		'''
		const aDay = new Date(28, 2, 2016)
		assert.equals("a Date[day = 28, month = 2, year = 2016]", aDay.toString())
		assert.equals("a Date[day = 28, month = 2, year = 2016]", aDay.toSmartString(false))
		'''.test
	}

}	
