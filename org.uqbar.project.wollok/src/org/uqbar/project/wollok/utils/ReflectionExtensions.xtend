package org.uqbar.project.wollok.utils

import java.lang.reflect.Field

class ReflectionExtensions {
	
	static def assign(Object receiver, String variableName, Object object) {
		var Class<?> receiverClass = Class.forName(receiver.class.name)
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
	
}