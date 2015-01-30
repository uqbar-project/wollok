package org.uqbar.project.wollok.interpreter.nativeobj

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * Anota un método de un objeto nativo como
 * que es la implementación de un mensaje.
 * Esto permite resolver el caso en que
 * queremos que el mensaje wollok sea un simbolo
 * o una palabra reservada en java/xtend,
 * con lo cual no podemos usar el nombre del método
 * para matchear con el mensaje que se le manda.
 * 
 * @author jfernandes
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
annotation NativeMessage {
	String value
}