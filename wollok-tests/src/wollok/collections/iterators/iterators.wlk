
mixin Iterator {

	method next()
	
	method hasNext()

}

mixin Iterable {
	method iterator()
}

class LinkedList {
	var head
	var size
	var last
	
	method add(element) {
		const newNode = new LinkedListNode(element)
		last.next(newNode)
		newNode.previous(last)
		new List()
		last = newNode
	}
	
	method get(index) {
		if (index > size)
			throw new IndexOutOfBoundException("Wanted to access index " + index + " in a list of size " + size)
	}

	
}

class IndexOutOfBoundException inherits Exception {
	constructor(message) = super(message)
}

class LinkedListNode {
	var element
	constructor(_element) {
		element = _element
	}
}