package org.uqbar.project.wollok.typesystem.annotations

class NumberTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Number.comparable
		Number + Number => Number
		Number - Number => Number
		Number * Number => Number
		Number / Number => Number
		Number % Number => Number
		Number ** Number => Number
		Number .. Number => Range
		
		Number >> "div" === #[Number] => Number
		Number >> "rem" === #[Number] => Number
		Number >> "max" === #[Number] => Number
		Number >> "min" === #[Number] => Number
		Number >> "gcd" === #[Number] => Number;
		Number >> "lcm" === #[Number] => Number;
		Number >> "roundUp" === #[Number] => Number
		Number >> "truncate" === #[Number] => Number;
		Number >> "randomUpTo" === #[Number] => Number;
		Number >> "limitBetween" === #[Number, Number] => Number
		Number >> "squareRoot" === #[] => Number
		Number >> "roundUp" === #[] => Number
		Number >> "invert" === #[] => Number
		Number >> "square" === #[] => Number
		Number >> "digits" === #[] => Number;
		Number >> "plus" === #[] => Number;
		Number >> "abs" === #[] => Number

		Number >> "odd" === #[] => Boolean
		Number >> "even" === #[] => Boolean
		Number >> "isPrime" === #[] => Boolean;
		Number >> "isInteger" === #[] => Boolean;
		Number >> "between" === #[Number, Number] => Boolean
		
		Number >> "stringValue" === #[] => String
		Number >> "times" === #[closure(#[Number], Void)] => Void; // TODO: Effect dependency 
		
		/* privates */
		Number >> "checkNotNull" === #[T, String] => Void //TODO: Effect???
		Number >> "coerceToInteger" === #[] => Number
		Number >> "coerceToPositiveInteger" === #[] => Number
	}
}
