package org.uqbar.project.wollok.validation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Declares the default severity value for a check method
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.METHOD})
public @interface DefaultSeverity {
	
 CheckSeverity value() default CheckSeverity.ERROR;
	
}