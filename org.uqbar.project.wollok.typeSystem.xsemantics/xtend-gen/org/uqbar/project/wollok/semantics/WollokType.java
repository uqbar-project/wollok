package org.uqbar.project.wollok.semantics;

import it.xsemantics.runtime.RuleEnvironment;
import org.uqbar.project.wollok.semantics.AnyType;
import org.uqbar.project.wollok.semantics.BooleanType;
import org.uqbar.project.wollok.semantics.IntType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.StringType;
import org.uqbar.project.wollok.semantics.VoidType;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;

/**
 * @author npasserini
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface WollokType {
  public final static IntType WInt = new IntType();
  
  public final static StringType WString = new StringType();
  
  public final static BooleanType WBoolean = new BooleanType();
  
  public final static VoidType WVoid = new VoidType();
  
  public final static AnyType WAny = new AnyType();
  
  public abstract String getName();
  
  public abstract void acceptAssignment(final WollokType other);
  
  public abstract boolean understandsMessage(final MessageType message);
  
  public abstract WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final RuleEnvironment g);
  
  /**
   * This type was found while inferring a type.
   * So it has the opportunity to refine the type.
   * If he founds that they are not compatible at all, then it could fail
   * throwing TypeSystemException which will cause a type check error.
   */
  public abstract WollokType refine(final WollokType previouslyInferred, final RuleEnvironment g);
  
  /**
   * Returns all messages that this types defines.
   * This is useful for content assist, for example.
   */
  public abstract Iterable<MessageType> getAllMessages();
}
