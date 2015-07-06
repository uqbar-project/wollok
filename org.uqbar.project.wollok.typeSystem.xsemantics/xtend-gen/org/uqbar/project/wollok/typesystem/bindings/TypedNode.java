package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.collect.Iterables;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.ExactTypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.bindings.TypingListener;

/**
 * An AST node complemented with typing information.
 * There are two different nodes:
 *  those that already come from the AST with type information (FixedTypeNode)
 *  and those that don't and therefore should be inferred.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class TypedNode {
  private List<TypingListener> listeners = CollectionLiterals.<TypingListener>newArrayList();
  
  protected EObject model;
  
  private BoundsBasedTypeSystem system;
  
  private List<TypeExpectation> expectations = CollectionLiterals.<TypeExpectation>newArrayList();
  
  public TypedNode(final EObject object, final BoundsBasedTypeSystem typeSystem) {
    this.model = object;
    this.system = typeSystem;
  }
  
  public void inferTypes() {
  }
  
  public void assignType(final WollokType type) {
  }
  
  public abstract WollokType getType();
  
  public EObject getModel() {
    return this.model;
  }
  
  private List<TypeExpectationFailedException> errors = CollectionLiterals.<TypeExpectationFailedException>newArrayList();
  
  public Iterable<TypeExpectationFailedException> issues() {
    ArrayList<TypeExpectationFailedException> _newArrayList = CollectionLiterals.<TypeExpectationFailedException>newArrayList();
    final Function2<ArrayList<TypeExpectationFailedException>, TypeExpectation, ArrayList<TypeExpectationFailedException>> _function = new Function2<ArrayList<TypeExpectationFailedException>, TypeExpectation, ArrayList<TypeExpectationFailedException>>() {
      public ArrayList<TypeExpectationFailedException> apply(final ArrayList<TypeExpectationFailedException> issues, final TypeExpectation expect) {
        ArrayList<TypeExpectationFailedException> _xblockexpression = null;
        {
          try {
            WollokType _type = TypedNode.this.getType();
            expect.check(_type);
          } catch (final Throwable _t) {
            if (_t instanceof TypeExpectationFailedException) {
              final TypeExpectationFailedException e = (TypeExpectationFailedException)_t;
              e.setModel(TypedNode.this.model);
              issues.add(e);
            } else {
              throw Exceptions.sneakyThrow(_t);
            }
          }
          _xblockexpression = issues;
        }
        return _xblockexpression;
      }
    };
    ArrayList<TypeExpectationFailedException> _fold = IterableExtensions.<TypeExpectation, ArrayList<TypeExpectationFailedException>>fold(this.expectations, _newArrayList, _function);
    return Iterables.<TypeExpectationFailedException>concat(_fold, this.errors);
  }
  
  public boolean addError(final TypeExpectationFailedException e) {
    return this.errors.add(e);
  }
  
  public void addExpectation(final TypeExpectation expectation) {
    this.expectations.add(expectation);
  }
  
  public void expectType(final WollokType type) {
    ExactTypeExpectation _exactTypeExpectation = new ExactTypeExpectation(type);
    this.addExpectation(_exactTypeExpectation);
  }
  
  public void addListener(final TypingListener listener) {
    this.listeners.add(listener);
  }
  
  public void removeListener(final TypingListener listener) {
    this.listeners.remove(listener);
  }
  
  public void fireTypeChanged() {
    TypingListener[] _clone = ((TypingListener[])Conversions.unwrapArray(this.listeners, TypingListener.class)).clone();
    final Procedure1<TypingListener> _function = new Procedure1<TypingListener>() {
      public void apply(final TypingListener it) {
        WollokType _type = TypedNode.this.getType();
        it.notifyTypeSet(_type);
      }
    };
    IterableExtensions.<TypingListener>forEach(((Iterable<TypingListener>)Conversions.doWrapArray(_clone)), _function);
  }
}
