package wollok.lib{
	object console {
		method println(obj) native
		method readLine() native
		method readInt() native
	}
	
	object tester{
		method assert(value) native
		method assertEquals(expected, actual) native
	}
}