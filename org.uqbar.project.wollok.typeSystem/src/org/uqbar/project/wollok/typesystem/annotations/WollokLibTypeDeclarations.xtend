package org.uqbar.project.wollok.typesystem.annotations

class WollokLibTypeDeclarations extends TypeDeclarations {
	override declarations() {
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => Void

		assertWKO >> "that" === #[Boolean] => Void
		assertWKO >> "notThat" === #[Boolean] => Void
		assertWKO >> "equals" === #[Any, Any] => Void
		assertWKO >> "notEquals" === #[Any, Any] => Void
		assertWKO >> "throwsException" === #[closure(#[], Any)] => Void
		assertWKO >> "throwsExceptionLike" === #[ExceptionType, closure(#[], Any)] => Void
		assertWKO >> "throwsExceptionWithMessage" === #[String, closure(#[], Any)] => Void
		assertWKO >> "throwsExceptionWithType" === #[ExceptionType, closure(#[], Any)] => Void
		assertWKO >> "throwsExceptionByComparing" === #[closure(#[], Any), closure(#[Any], Boolean)] => Void
		assertWKO >> "fail" === #[String] => Void;

		InstanceVariableMirror >> "value" === #[] => Void

		StringPrinter >> "println" === #[Any] => Void
		StringPrinter >> "getBuffer" === #[] => String
	}
}
