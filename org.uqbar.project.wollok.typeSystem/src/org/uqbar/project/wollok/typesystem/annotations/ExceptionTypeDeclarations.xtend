package org.uqbar.project.wollok.typesystem.annotations

class ExceptionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		ExceptionType.constructor(String)
		ExceptionType.constructor(String, ExceptionType)
		ExceptionType >> "printStackTrace" === #[] => Void
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List.of(String)
		ExceptionType >> "getStackTrace" === #[] => List.of(String)
		ExceptionType >> "getMessage" === #[] => String
		ExceptionType >> "getCause" === #[] => ExceptionType
		/* privates */
		ExceptionType >> "printStackTrace" === #[unionType(console, StringPrinter)] => Void
		ExceptionType >> "printStackTraceWithPrefix" === #[String, unionType(console, StringPrinter)] => Void
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement
		
		//TODO: Properties!
//		StackTraceElement >> "contextDescription" === #[] => String
//		StackTraceElement >> "location" === #[] => String
	}
}