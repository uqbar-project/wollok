package org.uqbar.project.wollok.typesystem.declarations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Integer + Integer => Integer
		Integer - Integer => Integer
		Integer * Integer => Integer

		// Otra sintaxis posible
		// "Integer" >> "-" === #[INTEGER] => INTEGER
		List >> "first" === #[] => ELEMENT
		String >> "size" === #[] => Integer
		Collection >> "add" === #[ELEMENT] => Void

		// console
		console >> "println" === #[Any] => Void
	}
}
