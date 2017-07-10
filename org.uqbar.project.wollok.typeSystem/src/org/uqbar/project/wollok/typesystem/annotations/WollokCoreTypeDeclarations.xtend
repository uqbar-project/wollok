package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		
		Integer + Integer => Integer
		Integer - Integer => Integer
		Integer * Integer => Integer
		Integer >> "/" === #[Integer] => Integer
		Integer >> ">" === #[Integer] => Boolean
		Integer >> "<" === #[Integer] => Boolean
		Integer >> ">=" === #[Integer] => Boolean
		Integer >> "<=" === #[Integer] => Boolean
		
		Double + Double => Integer
		Double * Double => Integer
		Double >> "/" === #[Integer] => Integer

		String >> "size" === #[] => Integer
		String + String => String

		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection

		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "size" === #[] => Integer
		List >> "sum" === #[Any] => Integer //TODO: Closure type annotation
		
		Set + Set => Set

		// console
		console >> "println" === #[Any] => Void
	}
}
