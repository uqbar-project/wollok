package org.uqbar.project.wollok.interpreter.operation

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * Marks a method as a unary operation implementation.
 * The method must receives one parameter
 * 
 * @author tesonep
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
annotation UnaryOperation {
	String value
}