package org.uqbar.project.wollok.typesystem.annotations

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean

		PairType.variable("x", PKEY)
		PairType.variable("y", PVALUE)
		PairType >> "key" === #[] => PKEY;
		PairType >> "value" === #[] => PVALUE;

		// Closure >> "apply" === #[List] => RETURN //TODO: VarArgs

		// This must come at last, because of "allTypes"
		// TODO1: should include Object type?
		// TODO2: should only be declared for Object?
		allTypes.forEach[ O |
			(O == T) => Boolean;
			(O != T) => Boolean;
			(O === T) => Boolean;
			(O !== T) => Boolean;
			(O -> T) => PairType.instance(#{PKEY.paramName -> SELF, PVALUE.paramName -> T});
			O >> "identity" === #[] => Number; 
			O >> "equals" === #[T] => Boolean;
			O >> "toString" === #[] => String;
			O >> "printString" === #[] => String;
			O >> "shortDescription" === #[] => String;
			O >> "kindName" === #[] => String;
			O >> "className" === #[] => String;
			O >> "error" === #[String] => Void(ThrowException);
			/* privates */
			O >> "messageNotUnderstood" === #[String, List.of(Object)] => Void(ThrowException)
			O >> "generateDoesNotUnderstandMessage" === #[String, String, Number] => String
		]
	}
}
