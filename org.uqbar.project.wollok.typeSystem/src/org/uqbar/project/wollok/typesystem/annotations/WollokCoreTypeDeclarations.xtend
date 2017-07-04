package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Integer + Integer => Integer
		Integer - Integer => Integer
		Integer * Integer => Integer
		
		Double + Double => Double

		String >> "size" === #[] => Integer
		String + String => String

		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection

		List + List => List
		List >> "first" === #[] => ELEMENT
		List >> "add" === #[ELEMENT] => Void
		
		Set + Set => Set

		// console
		console >> "println" === #[Any] => Void
	}
}
