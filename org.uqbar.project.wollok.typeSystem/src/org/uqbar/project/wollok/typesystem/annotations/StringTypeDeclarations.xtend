package org.uqbar.project.wollok.typesystem.annotations

class StringTypeDeclarations extends TypeDeclarations {
	override declarations() {
		(String == Any) => Boolean
		String >> "length" === #[] => Number
		String >> "size" === #[] => Number
		String >> "charAt" === #[Number] => String
		String >> "startsWith" === #[String] => Boolean
		String >> "endsWith" === #[String] => Boolean
		String >> "indexOf" === #[String] => Number
		String >> "lastIndexOf" === #[String] => Number
		String >> "toUpperCase" === #[] => String
		String >> "trim" === #[] => String
		String >> "contains" === #[String] => Boolean
		String >> "isEmpty" === #[] => Boolean
		String >> "substring" === #[Number] => String
		String >> "substring" === #[Number, Number] => String
		String >> "split" === #[String] => List.of(String)
		String >> "equalsIgnoreCase" === #[String] => Boolean
		String >> "printString" === #[] => String
		String >> "toString" === #[] => String
		String >> "replace" === #[String, String] => String
		String + String => String;
		(String > String) => Boolean
		String >> "take" === #[Number] => String
		String >> "drop" === #[Number] => String
		String >> "words" === #[] => List.of(String)
		String >> "capitalize" === #[] => String
	}
}