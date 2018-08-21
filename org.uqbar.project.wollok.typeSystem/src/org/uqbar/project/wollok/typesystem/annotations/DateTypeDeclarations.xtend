package org.uqbar.project.wollok.typesystem.annotations

class DateTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Date.constructor(Number, Number, Number)
		(Date == Date) => Boolean
		Date - Date => Number
		Date >> "initialize" === #[Number, Number, Number] => Void
		Date >> "plusDays" === #[Number] => Date
		Date >> "plusMonths" === #[Number] => Date
		Date >> "plusYears" === #[Number] => Date
		Date >> "isLeapYear" === #[] => Boolean
		Date >> "day" === #[] => Number
		Date >> "dayOfWeek" === #[] => Number
		Date >> "month" === #[] => Number
		Date >> "year" === #[] => Number
		Date >> "minusDays" === #[Number] => Date
		Date >> "minusMonths" === #[Number] => Date
		Date >> "minusYears" === #[Number] => Date
		Date >> "between" === #[Date, Date] => Boolean
		Date >> "toSmartString" === #[Boolean] => String;
	}
}