package org.uqbar.project.wollok.typesystem.bindings;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;

/**
 * A type expectation.
 * A rule that a type must complies in order to be valid.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface TypeExpectation {
  public abstract void check(final WollokType actualType) throws TypeExpectationFailedException;
}
