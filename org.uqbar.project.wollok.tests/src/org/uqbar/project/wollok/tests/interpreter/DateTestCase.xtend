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
		const year2000 = new Date(day = 4, month = 5, year = 2000)
		assert.that(year2000.isLeapYear())
		'''.test
	}

	// Default behavior is truncate decimals
	// We should add more tests changing IDE preferences
	@Test
	def void year2000WasLeapWithDecimals() {
		'''
		const year2000 = new Date(day = 4.8, month = 5.1, year = 2000.7)
		assert.that(year2000.isLeapYear())
		'''.test
	}
	@Test
	def void year2001WasNotLeap() {
		'''
		const year2001 = new Date(day = 4, month = 5, year = 2001)
		assert.notThat(year2001.isLeapYear())
		'''.test
	}

	@Test
	def void year2004WasLeap() {
		'''
		const year2004 = new Date(day = 4, month = 5, year = 2004)
		assert.that(year2004.isLeapYear())
		'''.test
	}

	@Test
	def void year2100WasNotLeap() {
		'''
		const year2100 = new Date(day = 4, month = 5, year = 2100)
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
		const elyesterday = new Date(day = 10, month = 6, year = 2001)
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
		const aDay = new Date(day = 7, month = 6, year = 2016)
		assert.equals(aDay.internalDayOfWeek(), 2) 
		'''.test
	}
	
	@Test
	def void tuesdayDayOfWeekIsTuesdayObject() {
		'''
		const aDay = new Date(day = 7, month = 6, year = 2016)
		assert.equals(aDay.dayOfWeek(), tuesday) 
		'''.test
	}

	@Test
	def void differenceBetweenDatesPositive() {
		'''
		const day1 = new Date(day = 7, month = 6, year = 2016)
		const day2 = new Date(day = 9, month = 7, year = 2016)
		assert.equals(day2 - day1, 32) 
		'''.test
	}

	@Test
	def void differenceBetweenDatesNegative() {
		'''
		const day1 = new Date(day = 7, month = 6, year = 2016)
		const day2 = new Date(day = 9, month = 7, year = 2016)
		assert.equals(day1 - day2, -32) 
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
		const originalDay = new Date(day = 31, month = 12, year = 2015)
		const finalDay = new Date(day = 29, month = 2, year = 2016)
		const result = originalDay.plusMonths(2)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractTwoMonths() {
		'''
		const originalDay = new Date(day = 29, month = 2, year = 2016)
		const finalDay = new Date(day = 29, month = 12, year = 2015)
		const result = originalDay.minusMonths(2)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractTwoMonthsPassingDecimals() {
		'''
		const originalDay = new Date(day = 29, month = 2, year = 2016)
		const finalDay = new Date(day = 29, month = 12, year = 2015)
		const result = originalDay.minusMonths(2.4)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void addOneYear() {
		'''
		const originalDay = new Date(day = 29, month = 2, year = 2016)
		const finalDay = new Date(day = 28, month = 2, year = 2017)
		const result = originalDay.plusYears(1)
		assert.that(result.equals(finalDay))
		'''.test
	}

	@Test
	def void subtractOneYear() {
		'''
		const originalDay = new Date(day = 28, month = 2, year = 2017)
		const finalDay = new Date(day = 28, month = 2, year = 2016)
		const result = originalDay.minusYears(1)
		assert.that(result.equals(finalDay))
		'''.test
	}
		
	@Test
	def void toStringDefaultTest() {
		'''
		const aDay = new Date(day = 28, month = 12, year = 2016)
		assert.equals("a Date[day = 28, month = 12, year = 2016]", aDay.toString())
		assert.equals("a Date[day = 28, month = 12, year = 2016]", aDay.toSmartString(false))
		'''.test
	}
	
	@Test
	def void toStringWithA1DigitMonthTest() {
		'''
		const aDay = new Date(day = 28, month = 2, year = 2016)
		assert.equals("a Date[day = 28, month = 2, year = 2016]", aDay.toString())
		assert.equals("a Date[day = 28, month = 2, year = 2016]", aDay.toSmartString(false))
		'''.test
	}

	@Test
	def void plusDaysUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation plusDays doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).plusDays(null) })
		'''.test
	}
	
	@Test
	def void plusMonthsUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation plusMonths doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).plusMonths(null) })
		'''.test
	}
	
	@Test
	def void plusYearsUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation plusYears doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).plusYears(null) })
		'''.test
	}
	
	@Test
	def void differenceFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"2\" to type wollok.lang.Date", { new Date(day = 28, month = 2, year = 2017) - "2" })
		'''.test
	}

	@Test
	def void minusDaysUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation minusDays doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).minusDays(null) })
		'''.test
	}
	
	@Test
	def void minusMonthsUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation minusMonths doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).minusMonths(null) })
		'''.test
	}
	
	@Test
	def void minusYearsUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation minusYears doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).minusYears(null) })
		'''.test
	}
	
	@Test
	def void betweenFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter 2 to type wollok.lang.Date", { new Date(day = 28, month = 2, year = 2017).between(2, 9) })
		'''.test
	}

	@Test
	def void betweenNull() {
		'''
		assert.throwsExceptionWithMessage("Operation > doesn't support null parameters", { new Date(day = 28, month = 2, year = 2017).between(null, null) })
		'''.test
	}

	@Test
	def void greaterThanFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter 2 to type wollok.lang.Date", { new Date(day = 28, month = 2, year = 2017) > 2 })
		'''.test
	}

	@Test
	def void plusDaysFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).plusDays("a") })
		'''.test
	}
	
	@Test
	def void plusMonthsFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).plusMonths("a") })
		'''.test
	}
	
	@Test
	def void plusYearsFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).plusYears("a") })
		'''.test
	}
	
	@Test
	def void minusDaysFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).minusDays("a") })
		'''.test
	}
	
	@Test
	def void minusMonthsFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).minusMonths("a") })
		'''.test
	}
	
	@Test
	def void minusYearsFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { new Date(day = 28, month = 2, year = 2017).minusYears("a") })
		'''.test
	}

}
