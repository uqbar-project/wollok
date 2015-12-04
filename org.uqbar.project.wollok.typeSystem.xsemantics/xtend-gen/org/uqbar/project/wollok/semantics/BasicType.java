package org.uqbar.project.wollok.semantics;

import com.google.common.base.Objects;
import it.xsemantics.runtime.RuleEnvironment;
import java.util.Collections;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Pure;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * Base class for all types
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class BasicType implements WollokType {
  @Property
  private String _name;
  
  public BasicType(final String name) {
    this.setName(name);
  }
  
  public void acceptAssignment(final WollokType other) {
    boolean _notEquals = (!Objects.equal(other, this));
    if (_notEquals) {
      throw new TypeSystemException("Incompatible type");
    }
  }
  
  public boolean understandsMessage(final MessageType message) {
    return true;
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final RuleEnvironment g) {
    return WollokType.WAny;
  }
  
  public WollokType refine(final WollokType previouslyInferred, final RuleEnvironment g) {
    WollokType _xblockexpression = null;
    {
      boolean _notEquals = (!Objects.equal(previouslyInferred, this));
      if (_notEquals) {
        throw new TypeSystemException(((("Incompatible type " + this) + " is not compatible with ") + previouslyInferred));
      }
      _xblockexpression = previouslyInferred;
    }
    return _xblockexpression;
  }
  
  public Iterable<MessageType> getAllMessages() {
    return Collections.<MessageType>unmodifiableList(CollectionLiterals.<MessageType>newArrayList());
  }
  
  public String toString() {
    return this.getName();
  }
  
  @Pure
  public String getName() {
    return this._name;
  }
  
  public void setName(final String name) {
    this._name = name;
  }
}
