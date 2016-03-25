package classes.natives {

	class MyNative {
		method aNativeMethod() native
		
		method uppercased() {
			return self.aNativeMethod().toUpperCase()
		} 
	}
	
}

