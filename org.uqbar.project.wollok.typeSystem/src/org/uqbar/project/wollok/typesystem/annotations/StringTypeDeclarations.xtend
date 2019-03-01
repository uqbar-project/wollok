package org.uqbar.project.wollok.typesystem.annotations

class StringTypeDeclarations extends TypeDeclarations {
	override declarations() {
		String.sized
		String.comparable
		String.contains(String)
		String + String => String;
		
		String >> "trim" === #[] => String
		String >> "length" === #[] => Number
		String >> "capitalize" === #[] => String
		String >> "toUpperCase" === #[] => String
		String >> "toLowerCase" === #[] => String
		String >> "charAt" === #[Number] => String
		String >> "substring" === #[Number] => String
		String >> "substring" === #[Number, Number] => String
		String >> "replace" === #[String, String] => String
		String >> "indexOf" === #[String] => Number
		String >> "lastIndexOf" === #[String] => Number

		String >> "words" === #[] => List.of(String)
		String >> "split" === #[String] => List.of(String)
		
		String >> "endsWith" === #[String] => Boolean
		String >> "startsWith" === #[String] => Boolean
		String >> "equalsIgnoreCase" === #[String] => Boolean
		
		String >> "take" === #[Number] => String
		String >> "drop" === #[Number] => String
	}
}