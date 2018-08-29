package org.uqbar.project.wollok.typesystem.annotations

class CollectionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Collection + Collection.of(ELEMENT) => Collection.of(ELEMENT);
		Collection >> "min" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "max" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "internalToSmartString" === #[Boolean] => String;

		#[Collection, List, Set].forEach [
			it >> "asSet" === #[] => Set.of(ELEMENT)
			it >> "occurrencesOf" === #[ELEMENT] => Number
		]

		Collection >> "filter" === #[predicate(ELEMENT)] => SelfType.of(ELEMENT);
		Range >> "filter" === #[predicate(Number)] => List.of(Number);

		(List == Any) => Boolean;
		List + List.of(ELEMENT) => List.of(ELEMENT);
		List >> "equals" === #[Any] => Boolean;
		List >> "first" === #[] => ELEMENT
		List >> "drop" === #[Number] => List.of(ELEMENT)
		List >> "take" === #[Number] => List.of(ELEMENT)

		Collection.mutableCollection(ELEMENT)
		List.mutableCollection(ELEMENT)
		Set.mutableCollection(ELEMENT)
		Range.basicCollection(Number)

		#[Collection, List, Set, Range, Dictionary].forEach [
			it >> "size" === #[] => Number
		]

		Dictionary >> "forEach" === #[closure(#[DKEY, DVALUE], Void)] => Void;

		Range >> "internalToSmartString" === #[Boolean] => String;

		(Set == Any) => Boolean
		Set >> "equals" === #[Any] => Boolean;
		Set + Set.of(ELEMENT) => Set.of(ELEMENT);
	}

	def basicCollection(AnnotationContext C, TypeAnnotation E) {
		C >> "isEmpty" === #[] => Boolean
		C >> "contains" === #[E] => Boolean
		C >> "asList" === #[] => List.of(E)
		C >> "anyOne" === #[] => E

		C >> "forEach" === #[closure(#[E], Void)] => Void
		C >> "find" === #[predicate(E)] => E;
		C >> "all" === #[predicate(E)] => Boolean
		C >> "any" === #[predicate(E)] => Boolean
		C >> "find" === #[predicate(E)] => E
		C >> "findOrDefault" === #[predicate(E), E] => E
		C >> "findOrElse" === #[predicate(E), closure(#[], E)] => E
		C >> "count" === #[predicate(E)] => Number
		C >> "sum" === #[closure(#[E], Number)] => Number;
	}

	def mutableCollection(AnnotationContext C, TypeAnnotation E) {
		C.basicCollection(E)
		C >> "add" === #[E] => Void
		C >> "remove" === #[E] => Void
		C >> "addAll" === #[Collection.of(E)] => Void
		C >> "removeAll" === #[Collection.of(E)] => Void
		C >> "removeAllSuchThat" === #[predicate(E)] => Void
	}
}
