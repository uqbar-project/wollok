package org.uqbar.project.wollok.interpreter.operation

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * Marks a method as a binary operation implementation.
 * The method must receives two parameters (left and right operands)
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
annotation BinaryOperation {
	String value
}