package org.uqbar.project.wollok.typesystem.declarations

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.ELEMENT

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Integer + INTEGER => INTEGER
		Integer - INTEGER => INTEGER
		Integer * INTEGER => INTEGER

		// Otra sintaxis posible
		// "Integer" >> "-" === #[INTEGER] => INTEGER
		List >> "first" === #[] => ELEMENT
		String >> "size" === #[] => INTEGER
		Collection >> "add" === #[ELEMENT] => VOID

		// console
		console >> "println" === #[OBJECT] => VOID
	}
}
