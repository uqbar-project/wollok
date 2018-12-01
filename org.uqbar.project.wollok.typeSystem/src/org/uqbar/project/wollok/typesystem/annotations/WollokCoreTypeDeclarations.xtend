package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
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

		// Closure >> "apply" === #[List] => RETURN

		// This must come at last, because of "allTypes"
		allTypes.forEach[ T |
			(T == Any) => Boolean;
			T >> "equals" === #[Any] => Boolean;
			T >> "toString" === #[] => String;
			T >> "printString" === #[] => String;
			T >> "internalToSmartString" === #[Boolean] => String;			
		]
	}
}
