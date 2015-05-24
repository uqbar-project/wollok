package org.uqbar.project.wollok.debugger.client

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * A method that handles an interpreter event on the debugger side.
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
annotation HandlesEvent {
	
	String value 
	
}