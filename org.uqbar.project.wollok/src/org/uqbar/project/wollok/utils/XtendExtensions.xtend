package org.uqbar.project.wollok.utils

import java.util.List
import java.util.Map
import java.util.Random
import java.util.function.BiConsumer
import java.util.function.BiFunction

import static extension java.lang.Math.*

/**
 * Our extensions to basic Java/XTend classes
 * 
 * @author npasserini
 */
class XtendExtensions {
	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }

	/**
	 * Returns a substring from the begining until the last occurrence of a given character.  
	 */
	static def copyUptoLast(String string, Character character) {
		string.substring(0, string.lastIndexOf(character))
	}

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

		while(iter1.hasNext() && iter2.hasNext()) {
			function.accept(iter1.next(), iter2.next())
		}

		if(iter1.hasNext() || iter2.hasNext()) {
			throw new IllegalArgumentException("beForeach received two iterables with different amount of elements.")
		}
	}

	static def <T, U> boolean biForAll(Iterable<T> it1, Iterable<U> it2, BiFunction<T, U, Boolean> function) {
		val iter1 = it1.iterator()
		val iter2 = it2.iterator()
		var result = true

		while(result && iter1.hasNext() && iter2.hasNext()) {
			result = function.apply(iter1.next(), iter2.next())
		}

		if(iter1.hasNext() != iter2.hasNext()) {
			throw new IllegalArgumentException("beForeach received two iterables with different amount of elements.")
		}

		result
	}

	/**
	 * Returns a copy of the list with the last element removed, 
	 * or an empty list if the received list is empty.
	 */
	static def <T> allButLast(List<T> list) {
		list.subList(0, (list.size - 1).max(0))
	}

	static def <T> copyWithout(Iterable<T> list, T... toRemove) {
		list.clone => [
			toRemove.forEach[elem|remove(elem)]
		]
	}

	static def <T> boolean notNullAnd(T receiver, (T)=>boolean action) {
		receiver !== null && action.apply(receiver)
	}

	/**
	 * Our own map values that actually computes the mapped value instead of saving the transformation.
	 * This might not be as fast as Google #mapValues, but is easier to debug.
	 */
	static def <K, V1, V2> Map<K, V2> doMapValues(Map<K, V1> original, (V1)=>V2 transformation) {
		newHashMap(original.entrySet.map[key -> transformation.apply(value)])
	}

	/**
	 * Our own map values that actually computes the mapped value instead of saving the transformation.
	 * In this version, the transformation receives both key and value as parameters.
	 * 
	 * This might not be as fast as Google #mapValues, but is easier to debug.
	 */
	static def <K, V1, V2> Map<K, V2> doMapValues(Map<K, V1> original, (K, V1)=>V2 transformation) {
		newHashMap(original.entrySet.map[key -> transformation.apply(key,value)])
	}

	static def <T, R> Iterable<R> flatMap(Iterable<T> original, (T)=>Iterable<R> transformation) {
		original.map(transformation).flatten
	}

	static def <T> Iterable<Iterable<T>> subsetsOfSize(Iterable<T> input, int size) {
		val data = input.toList
		if(data.size == size)
			return newArrayList(data)
		else if(size == 1)
			return data.map[newArrayList(it)]
		else {
			(0 .. (data.size - size)).map [ index |
				val current = data.get(index)
				data.subList(index + 1, data.size).subsetsOfSize(size - 1).map[#[current] + it]
			].flatten
		}
	}
}
