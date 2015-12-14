package classes.natives {

	class MyNative {
		method aNativeMethod() native
		
		method uppercased() {
			return this.aNativeMethod().toUpperCase()
		} 
	}
	
}

