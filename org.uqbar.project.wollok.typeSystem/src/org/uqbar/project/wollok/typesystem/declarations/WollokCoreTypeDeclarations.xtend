package org.uqbar.project.wollok.typesystem.declarations

import static org.uqbar.project.wollok.sdk.WollokDSK.*

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		"Integer" + INTEGER => INTEGER
		"Integer" - INTEGER => INTEGER
		"Integer" * INTEGER => INTEGER

		// Otra sintaxis posible
		// "Integer" >> "-" === #[INTEGER] => INTEGER
	}
}

