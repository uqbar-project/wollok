package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
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
		(Double > Number) => Boolean;
		(Double < Number) => Boolean
		Double >> ">=" === #[Number] => Boolean
		Double >> "<=" === #[Number] => Boolean

		String >> "size" === #[] => Integer
		String + String => String;
		(String > String) => Boolean;
		(String < String) => Boolean

		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection

		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "last" === #[] => ELEMENT
		List >> "anyOne" === #[] => ELEMENT
		List >> "size" === #[] => Integer
		List >> "clear" === #[] => Void
		List >> "remove" === #[ELEMENT] => Void
		List >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer
	    List >> "all" === #[closure(#[ELEMENT], Boolean)] => Boolean
		List >> "max" === #[closure(#[ELEMENT], Number)] => ELEMENT 
		// deberia ser Any (ordenable)
		List >> "count" === #[closure(#[ELEMENT], Boolean)] => Integer
		//List >> "forEach" === #[closure(#[ELEMENT], Void)] => Void
		List >> "filter" === #[closure(#[ELEMENT], Boolean)] => List
	
		Range >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer
		 
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "contains" === #[ELEMENT] => Boolean
		Set >> "sum" === #[closure(#[ELEMENT], Integer)] => Integer
		
		Date - Date => Integer;
		(Date > Date) => Boolean;
		(Date < Date) => Boolean

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Integer
		console >> "newline" === #[] => Void
	}
}
