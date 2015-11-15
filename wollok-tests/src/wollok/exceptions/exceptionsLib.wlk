class A {
	method m1() {
		throw new MyException()
	}
}


class MyException inherits wollok.lang.Exception {
}
