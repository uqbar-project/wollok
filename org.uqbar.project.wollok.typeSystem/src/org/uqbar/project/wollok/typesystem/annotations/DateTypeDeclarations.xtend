package org.uqbar.project.wollok.typesystem.annotations

class DateTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Date.comparable
		Date.variable("day", Number)
		Date.variable("month", Number)
		Date.variable("year", Number)
		Date - Date => Number
		Date >> "plusDays" === #[Number] => Date
		Date >> "plusMonths" === #[Number] => Date
		Date >> "plusYears" === #[Number] => Date
		Date >> "isLeapYear" === #[] => Boolean
		Date >> "internalDayOfWeek" === #[] => Number
		Date >> "minusDays" === #[Number] => Date
		Date >> "minusMonths" === #[Number] => Date
		Date >> "minusYears" === #[Number] => Date
		Date >> "between" === #[Date, Date] => Boolean
		Date >> "toSmartString" === #[Boolean] => String;
	}
}