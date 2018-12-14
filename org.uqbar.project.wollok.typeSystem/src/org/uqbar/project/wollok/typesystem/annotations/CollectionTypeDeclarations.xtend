package org.uqbar.project.wollok.typesystem.annotations

class CollectionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		#[Collection, Set, List].forEach [ collectionDeclarations(ELEMENT) ]
		
		List >> "first" === #[] => ELEMENT
		List >> "head" === #[] => ELEMENT
		List >> "last" === #[] => ELEMENT
		List >> "get" === #[Number] => ELEMENT
		List >> "take" === #[Number] => List.of(ELEMENT)		
		List >> "drop" === #[Number] => List.of(ELEMENT)
		List >> "subList" === #[Number, Number] => List.of(ELEMENT)
		List >> "reverse" === #[] => List.of(ELEMENT)
		List >> "withoutDuplicates" === #[] => List.of(ELEMENT)
		List >> "sortBy" === #[predicate(ELEMENT, ELEMENT)] => Void
		
		Set >> "union" === #[Collection.of(ELEMENT)] => Set.of(ELEMENT)
		Set >> "intersection" === #[Collection.of(ELEMENT)] => Set.of(ELEMENT)
		Set >> "difference" === #[Collection.of(ELEMENT)] => Set.of(ELEMENT)
		
		Range.basicCollection(Number)
		Range >> "filter" === #[predicate(Number)] => List.of(Number);
		Range >> "internalToSmartString" === #[Boolean] => String;

		Dictionary.clear
		Dictionary.sizedCollection
		Dictionary >> "forEach" === #[closure(#[DKEY, DVALUE], Void)] => Void;
	}

	def basicCollection(AnnotationContext C, TypeAnnotation E) {
		C.sizedCollection
		C >> "asList" === #[] => List.of(E)
		
		C >> "anyOne" === #[] => E
		C >> "contains" === #[E] => Boolean

		C >> "forEach" === #[closure(#[E], Void)] => Void
		C >> "find" === #[predicate(E)] => E;
		C >> "all" === #[predicate(E)] => Boolean
		C >> "any" === #[predicate(E)] => Boolean
		C >> "find" === #[predicate(E)] => E
		C >> "findOrDefault" === #[predicate(E), E] => E
		C >> "findOrElse" === #[predicate(E), closure(#[], E)] => E
		C >> "count" === #[predicate(E)] => Number
		
		C >> "map" === #[closure(#[E], T)] => List.of(T);
		C >> "flatMap" === #[closure(#[E], List.of(T))] => List.of(T);
		C >> "fold" === #[T, closure(#[T, E], T)] => T;
	}

	def mutableCollection(AnnotationContext C, TypeAnnotation E) {
		C.basicCollection(E)
		C >> "add" === #[E] => Void
		C >> "remove" === #[E] => Void
		C >> "addAll" === #[Collection.of(E)] => Void
		C >> "removeAll" === #[Collection.of(E)] => Void
		C >> "removeAllSuchThat" === #[predicate(E)] => Void
	}

	def collectionDeclarations(AnnotationContext C, TypeAnnotation E) { 
		C + Collection.of(E) => SelfType.of(E);
		C.mutableCollection(E)
		C.comparableCollection(E)
		C.sumableCollection(E)
		C.clear

		C >> "toStringPrefix" === #[] => String
		C >> "toStringSuffix" === #[] => String
		C >> "join" === #[String] => String
		C >> "join" === #[] => String
		
		C >> "asSet" === #[] => Set.of(E)
		C >> "occurrencesOf" === #[E] => Number
		C >> "sortedBy" === #[predicate(E, E)] => List.of(E);
		
		C >> "copy" === #[] => SelfType.of(E);
		C >> "newInstance" === #[] => SelfType.of(Any);
		C >> "filter" === #[predicate(E)] => SelfType.of(E);
//		C >> "flatten" === #[] => SelfType.of(E); //TODO: Should be C<C<E>>
	}

	//TODO: Define comparables
	def comparableCollection(AnnotationContext C, TypeAnnotation E) {
		C >> "min" === #[] => E;
		C >> "max" === #[] => E;
		C >> "min" === #[closure(#[E], Number)] => E;
		C >> "max" === #[closure(#[E], Number)] => E;
		C >> "minIfEmpty" === #[closure(#[], E)] => E;
		C >> "maxIfEmpty" === #[closure(#[], E)] => E;
		C >> "minIfEmpty" === #[closure(#[E], Number), closure(#[], E)] => E;
		C >> "maxIfEmpty" === #[closure(#[E], Number), closure(#[], E)] => E;
	}

	//TODO: Define sumables
	def sumableCollection(AnnotationContext C, TypeAnnotation E) {
		C >> "sum" === #[] => Number; //TODO: Should be C<Number>
		C >> "sum" === #[closure(#[E], Number)] => Number;
	}

	def sizedCollection(AnnotationContext C) {
		C >> "size" === #[] => Number
		C >> "isEmpty" === #[] => Boolean
	}
	
	def clear(AnnotationContext C) {
		C >> "clear" === #[] => Void
	}
}
