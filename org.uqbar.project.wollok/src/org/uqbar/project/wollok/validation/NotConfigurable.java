package org.uqbar.project.wollok.validation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * To ignore a @check method.
 * It won't be available to enabled / disabled it from preferences.
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.METHOD})
public @interface NotConfigurable {

}
