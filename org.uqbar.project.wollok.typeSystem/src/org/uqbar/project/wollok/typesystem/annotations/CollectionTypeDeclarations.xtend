package org.uqbar.project.wollok.typesystem.annotations

class CollectionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection.of(ELEMENT) => Collection.of(ELEMENT);
		Collection >> "min" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "max" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "internalToSmartString" === #[Boolean] => String;

		#[Collection, List, Set].forEach [
			it >> "asSet" === #[] => Set.of(ELEMENT)
			it >> "occurrencesOf" === #[ELEMENT] => Number
		]

		// TODO This should use SELF type.
		Collection >> "filter" === #[predicate(ELEMENT)] => List.of(ELEMENT);

		(List == Any) => Boolean;
		List + List.of(ELEMENT) => List.of(ELEMENT);
		List >> "equals" === #[Any] => Boolean;
		List >> "add" === #[ELEMENT] => Void
		List >> "first" === #[] => ELEMENT
		List >> "drop" === #[Number] => List.of(ELEMENT)
		List >> "take" === #[Number] => List.of(ELEMENT)
		List >> "sum" === #[closure(#[ELEMENT], Number)] => Number

		val (AnnotationContext, TypeAnnotation)=>void basicCollection = [ collectionType, elementType |
			collectionType >> "isEmpty" === #[] => Boolean
			collectionType >> "contains" === #[elementType] => Boolean
			collectionType >> "asList" === #[] => List.of(elementType)

			collectionType >> "forEach" === #[closure(#[elementType], Void)] => Void
			collectionType >> "find" === #[predicate(elementType)] => elementType;
			collectionType >> "all" === #[predicate(elementType)] => Boolean
			collectionType >> "any" === #[predicate(elementType)] => Boolean
			collectionType >> "find" === #[predicate(elementType)] => elementType
			collectionType >> "findOrDefault" === #[predicate(elementType), elementType] => elementType
			collectionType >> "findOrElse" === #[predicate(elementType), closure(#[], elementType)] => elementType
			collectionType >> "count" === #[predicate(elementType)] => Number
		]

		basicCollection.apply(Collection, ELEMENT)
		basicCollection.apply(List, ELEMENT)
		basicCollection.apply(Set, ELEMENT)
		basicCollection.apply(Range, Number)

		#[Collection, List, Set, Range, Dictionary].forEach [
		        it >> "size" === #[] => Number
		]

		Dictionary >> "forEach" === #[closure(#[DKEY, DVALUE], Void)] => Void;

		Range >> "sum" === #[closure(#[Number], Number)] => Number;
		Range >> "internalToSmartString" === #[Boolean] => String;
		Range >> "filter" === #[closure(#[Number], Boolean)] => List.of(Number);

		(Set == Any) => Boolean
		Set >> "equals" === #[Any] => Boolean;
		Set + Set.of(ELEMENT) => Set.of(ELEMENT);
		Set >> "add" === #[ELEMENT] => Void
		Set >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
	}
}