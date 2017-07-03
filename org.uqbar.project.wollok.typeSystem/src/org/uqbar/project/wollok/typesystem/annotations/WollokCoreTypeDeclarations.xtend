package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Integer + Integer => Integer
		Integer - Integer => Integer
		Integer * Integer => Integer

		String >> "size" === #[] => Integer

		Collection >> "add" === #[ELEMENT] => Void

		List >> "first" === #[] => ELEMENT
		List >> "add" === #[ELEMENT] => Void
		

		// console
		console >> "println" === #[Any] => Void
	}
}
