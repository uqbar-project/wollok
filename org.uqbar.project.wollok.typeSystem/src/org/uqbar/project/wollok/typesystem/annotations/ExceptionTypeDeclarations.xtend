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
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement //TODO: private methods?
		
		//TODO: StackTraceElement? Because seems like a "private" class
	}
}