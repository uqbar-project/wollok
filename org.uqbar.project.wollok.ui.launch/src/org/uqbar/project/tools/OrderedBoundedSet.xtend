package org.uqbar.project.tools

import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.Set
import java.io.Serializable

class OrderedBoundedSet<E> implements Set<E>, Serializable{
	
	val List<E> internalData
	val int maxCapacity
	
	new(int maxCapacity){
		this.maxCapacity = maxCapacity
		internalData = new ArrayList<E>(maxCapacity)
	}
	
	override add(E e) {
		if(internalData.contains(e))
			return false
			
		if(internalData.size == maxCapacity){
			internalData.remove(0)
		}
		
		internalData.add(internalData.size, e)
		
		return true
	}

	override addAll(Collection<? extends E> c) {
		var accum = false		
		for(E x : c){
			accum = this.add(x) || accum
		}
		accum
	}
	
	override clear() {
		internalData.clear
	}
	
	override contains(Object o) {
		internalData.contains(o)
	}
	
	override containsAll(Collection<?> c) {
		c.forall[this.contains(it)]
	}
	
	override isEmpty() {
		internalData.isEmpty
	}
	
	override iterator() {
		internalData.iterator
	}
	
	override remove(Object o) {
		internalData.remove(o)
	}
	
	override removeAll(Collection<?> c) {
		internalData.removeAll(c)
	}
	
	override retainAll(Collection<?> c) {
		internalData.retainAll(c)
	}
	
	override size() {
		internalData.size()
	}
	
	override toArray() {
		internalData.toArray
	}
	
	override <T> toArray(T[] a) {
		internalData.toArray(a)
	}
	
	def E first(){
		this.internalData.get(0)
	}

	def E first(int offset){
		this.internalData.get(offset)
	}
	
	def E last(){
		this.last(0)
	}
	
	def E last(int offset){
		this.internalData.get(internalData.size - 1 - offset)
	}
}