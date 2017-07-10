package org.uqbar.project.wollok.utils

import java.lang.reflect.Field

class ReflectionExtensions {
	
	static def assign(Object receiver, String variableName, Object object) {
		val Field f1 = getField(receiver.class, variableName)
		f1.set(receiver, object)
	}
	
	static def getField(Class<?> c, String variableName) {
		var Class<?> receiverClass = c
		var mustCheck = true
		while (mustCheck) {
			try {
				val Field f1 = receiverClass.getDeclaredField(variableName)
				f1.accessible = true
				return f1
			} catch (NoSuchFieldException e) {
				receiverClass = receiverClass.superclass
				mustCheck = receiverClass !== null
			}	
		}
		return null
	}

	static def getFieldValue(Object o, String name) {
		getField(o.class, name).get(o)
	}

	static def executeMethod(Object o, String methodName, Object[] args) {
		val method = (o.class).getDeclaredMethod(methodName, args.map[it.class])
		method.accessible = true
		method.invoke(o, args)
	}
	
}