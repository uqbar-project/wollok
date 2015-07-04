package org.uqbar.project.wollok.semantics;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeSystemException extends RuntimeException {
  public TypeSystemException() {
  }
  
  public TypeSystemException(final String message) {
    super(message);
  }
}
