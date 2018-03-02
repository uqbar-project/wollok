package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ConcreteType

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		
		(Object == Any) => Boolean;

		(Boolean == Any) => Boolean		
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean
		Boolean >> "toString" === #[] => String;

		Number + Number => Number
		Number - Number => Number
		Number * Number => Number
		Number >> "/" === #[Number] => Number
		Number >> ">" === #[Number] => Boolean
		Number >> "<" === #[Number] => Boolean
		Number >> ">=" === #[Number] => Boolean
		Number >> "<=" === #[Number] => Boolean
		Number / Number => Number
		Number >> "between" === #[Number, Number] => Boolean
		Number % Number => Number;

		(String == Any) => Boolean
		String >> "size" === #[] => Number
		String + String => String;
		(String > String) => Boolean

		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection;

		(List == Any) => Boolean
		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "size" === #[] => Number
		List >> "sum" === #[closure(#[ELEMENT], Number)] => Number
		
		Range >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		 
		(Set == Any) => Boolean
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "contains" === #[ELEMENT] => Boolean
		Set >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		
		(Date == Any) => Boolean;
		Date - Date => Number;

		(Position == Any) => Boolean;

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => Void

		comparable(Number, String, Date)
	}
	
	def comparable(SimpleTypeAnnotation<? extends ConcreteType>... types) {
		types.forEach[ T |
			(T > T) => Boolean;
			(T < T) => Boolean;
			(T <= T) => Boolean;
			(T >= T) => Boolean;
		]
	}
}
