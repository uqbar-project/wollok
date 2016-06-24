package org.uqbar.project.wollok.utils

import java.util.Optional
import java.util.function.Function

class OptionalExtensions {
		
	def static <T> Optional<T> toOptional(T it) {
		Optional.ofNullable(it)
	}
	
	def static <T> Optional<T> or(Optional<T> it, Optional<T> other) {
		it.orElse(other.orElse(null)).toOptional
	}
	
	def static <T> Optional<T> firstOrOptional(Iterable<T> it, Function<T, Boolean> predicate) {
		findFirst(predicate).toOptional
	}
	
	def static <T> Optional<T> firstNotNull(Iterable<T> it) {
		filterNull.head.toOptional
	}
	
}