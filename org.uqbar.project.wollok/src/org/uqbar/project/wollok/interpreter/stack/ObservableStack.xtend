package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import java.util.Set
import java.util.Stack

/**
 * @author jfernandes
 */
class ObservableStack<E> extends Stack<E> implements Serializable {
	private Set<StackObserver<E>> observers = newHashSet
	
	override push(E item) {
		val previous = if (isEmpty) null else peek
		val o = super.push(item)
		observers.forEach[pushed(previous, item)]
		o
	}
	
	override pop() {
		val o = super.pop()
		observers.forEach[poped(o)]
		o
	}
	
	def addObserver(StackObserver o) {
		this.observers.add(o)
	}
	def removeObserver(StackObserver o) {
		this.observers.remove(o)
	}
	
}

/**
 * @author jfernandes
 */
interface StackObserver<E> {
	def void pushed(E parent, E child);
	def void poped(E e);
}