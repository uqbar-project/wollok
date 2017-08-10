package org.uqbar.project.wollok.typesystem.annotations

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
		(Number > Number) => Boolean;
		(Number < Number) => Boolean;
		Number >> ">=" === #[Number] => Boolean
		Number >> "<=" === #[Number] => Boolean

		Integer + Number => Number
		Integer - Number => Number
		Integer * Number => Number
		Integer / Number => Number;
		(Integer > Number) => Boolean;
		(Integer < Number) => Boolean;
		Integer >> ">=" === #[Number] => Boolean
		Integer >> "<=" === #[Number] => Boolean

		Double + Number => Double
		Double - Number => Double
		Double * Number => Double
		Double / Number => Double;
		(Double > Double) => Boolean;
		(Double < Double) => Boolean
		Double >> ">=" === #[Number] => Boolean
		Double >> "<=" === #[Number] => Boolean;

		(String == Any) => Boolean
		String >> "size" === #[] => Integer
		String + String => String;
		(String > String) => Boolean;
		(String < String) => Boolean

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
		(Date > Date) => Boolean;
		(Date < Date) => Boolean;

		(Position == Any) => Boolean;

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Integer
		console >> "newline" === #[] => Void
	}
}
