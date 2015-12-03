package org.uqbar.project.wollok.typesystem;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;

/**
 * An engine that performs type inference and type checks.
 * Common interface for the different implementations.
 * To be able to compare them with the same tests cases.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface TypeSystem {
  /**
   * # 1: First step
   * Builds any needed graph or rules based on the program.
   */
  public abstract void analyse(final /* EObject */Object root);
  
  /**
   * # 2:
   * Second step. Goes through all the bindings and tries to infer types.
   */
  public abstract void inferTypes();
  
  /**
   * # 3:
   * Then you can perform queries for types.
   */
  public abstract WollokType type(final /* EObject */Object obj);
  
  public abstract Iterable<TypeExpectationFailedException> issues(final /* EObject */Object obj);
}
