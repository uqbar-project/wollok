package org.uqbar.project.wollok.interpreter.nativeobj

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * Annotates a given java method as the native implementation
 * of a wollok message.
 * 
 * This allows us to expose to wollok a message with a name
 * that is a reserved word in java-side.
 * Or also when we want to use symbols (which java doesn't allow)
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
annotation NativeMessage {
	String value
}