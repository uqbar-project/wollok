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

		Number + Number => Number
		Number - Number => Number
		Number * Number => Number
		Number / Number => Number;
		Number >> "between" === #[Number, Number] => Boolean

		Integer + Number => Number
		Integer - Number => Number
		Integer * Number => Number
		Integer / Number => Number;
		Integer % Number => Integer;

		Double + Number => Double
		Double - Number => Double
		Double * Number => Double
		Double / Number => Double;
		Double % Number => Integer;

		(String == Any) => Boolean
		String >> "size" === #[] => Integer
		String + String => String;

		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection;

		(List == Any) => Boolean
		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "size" === #[] => Integer
		List >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer
		
		Range >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer;
		 
		(Set == Any) => Boolean
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "contains" === #[ELEMENT] => Boolean
		Set >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer;
		
		(Date == Any) => Boolean;
		Date - Date => Integer;

		(Position == Any) => Boolean;

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Integer
		console >> "newline" === #[] => Void

		comparable(Number, Integer, Double, String, Date)
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
