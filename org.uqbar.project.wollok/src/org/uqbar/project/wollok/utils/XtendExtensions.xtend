package org.uqbar.project.wollok.utils

import java.util.List
import java.util.Random
import java.util.function.BiConsumer

/**
 * Our extensions to basic Java/XTend classes
 */
class XtendExtensions {
	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }
	
	/**
	 * Returns an random element  
	 */
	static def random(List<Integer> it) {
		val index = new Random().nextInt(size)
		get(index)
	}
	
	static def <T, U> biForEach(Iterable<T> it1, Iterable<U> it2, BiConsumer<T, U> function) {
		val iter1 = it1.iterator()
		val iter2 = it2.iterator()

		while (iter1.hasNext() && iter2.hasNext()) {
			function.accept(iter1.next(), iter2.next())
		}

		if (iter1.hasNext() || iter2.hasNext()) {
			throw new IllegalArgumentException(
				"beForeach received two iterables with different amount of elements.")
		}
	}
	
}