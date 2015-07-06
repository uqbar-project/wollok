package org.uqbar.project.wollok.semantics;

import com.google.inject.Inject;
import it.xsemantics.runtime.RuleEnvironment;
import it.xsemantics.runtime.RuleFailedException;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.util.ITextRegionWithLineInformation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.semantics.AnyType;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;

/**
 * Type system implementation based on xsemantics
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class XSemanticsTypeSystem implements TypeSystem {
  @Inject
  protected WollokDslTypeSystem xsemanticsSystem;
  
  private RuleEnvironment env;
  
  public void analyse(final EObject p) {
    RuleEnvironment _emptyEnvironment = this.xsemanticsSystem.emptyEnvironment();
    this.env = _emptyEnvironment;
    EList<EObject> _eContents = p.eContents();
    final Procedure1<EObject> _function = new Procedure1<EObject>() {
      public void apply(final EObject e) {
        XSemanticsTypeSystem.this.xsemanticsSystem.inferTypes(XSemanticsTypeSystem.this.env, e);
      }
    };
    IterableExtensions.<EObject>forEach(_eContents, _function);
  }
  
  public WollokType resolvedType(final EObject o) {
    WollokType _xtrycatchfinallyexpression = null;
    try {
      WollokType _env = this.xsemanticsSystem.<WollokType>env(this.env, o, WollokType.class);
      _xtrycatchfinallyexpression = _env;
    } catch (final Throwable _t) {
      if (_t instanceof RuleFailedException) {
        final RuleFailedException e = (RuleFailedException)_t;
        AnyType _xblockexpression = null;
        {
          final ICompositeNode node = NodeModelUtils.getNode(o);
          Resource _eResource = o.eResource();
          URI _uRI = _eResource.getURI();
          String _plus = ("FAILED TO INFER TYPE FOR: " + _uRI);
          String _plus_1 = (_plus + "[");
          ITextRegionWithLineInformation _textRegionWithLineInformation = node.getTextRegionWithLineInformation();
          int _lineNumber = _textRegionWithLineInformation.getLineNumber();
          String _plus_2 = (_plus_1 + Integer.valueOf(_lineNumber));
          String _plus_3 = (_plus_2 + "]: ");
          String _text = node.getText();
          String _plus_4 = (_plus_3 + _text);
          InputOutput.<String>println(_plus_4);
          String _message = e.getMessage();
          String _plus_5 = (">> " + _message);
          InputOutput.<String>println(_plus_5);
          _xblockexpression = WollokType.WAny;
        }
        _xtrycatchfinallyexpression = _xblockexpression;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
  
  public WollokType type(final EObject obj) {
    return this.resolvedType(obj);
  }
  
  public void inferTypes() {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  public Iterable<TypeExpectationFailedException> issues(final EObject obj) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
}
