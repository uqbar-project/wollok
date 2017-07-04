package org.uqbar.project.wollok.utils

import java.lang.reflect.Field

class ReflectionExtensions {
	
	static def assign(Object receiver, String variableName, Object object) {
		var Class<?> receiverClass = receiver.class
		var mustCheck = true
		while (mustCheck) {
			try {
				val Field f1 = receiverClass.getDeclaredField(variableName)
				f1.accessible = true
				f1.set(receiver, object)
				mustCheck = false
			} catch (NoSuchFieldException e) {
				receiverClass = receiverClass.superclass
				mustCheck = receiverClass !== null
			}	
		}
	}
	
	static def Object invoke(Object receiver, String methodName, Object ... parameters){
		val clazz = receiver.class
		val method = clazz.getDeclaredMethod(methodName, parameters.map[it.class])
		method.accessible = true
		method.invoke(receiver, parameters)
	}
	
	static def Object get(Object receiver, String instanceVariableName){
		val clazz = receiver.class
		val instVar = clazz.getDeclaredField(instanceVariableName)
		instVar.accessible = true
		instVar.get(receiver)
	}
	
}