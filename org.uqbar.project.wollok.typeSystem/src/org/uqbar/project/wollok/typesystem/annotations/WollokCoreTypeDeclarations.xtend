package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		// TODO: Uncomment all definitions when solving closure parameters
		(Object == Any) => Boolean;
		Object >> "equals" === #[Any] => Boolean;
		Object >> "toString" === #[] => String;
		Object >> "printString" === #[] => String;
		Object >> "internalToSmartString" === #[Boolean] => String;

		(Boolean == Any) => Boolean
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean
		Boolean >> "toString" === #[] => String;

		PairType.constructor(PKEY, PVALUE)
		PairType >> "key" === #[] => PKEY;
		PairType >> "value" === #[] => PVALUE;

	}
}
