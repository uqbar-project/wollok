package org.uqbar.project.wollok.game;

import java.io.File;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

@SuppressWarnings("all")
public class GameFactory {
  private Document doc;
  
  private Gameboard gameboard;
  
  public void setGame(final Gameboard aGameboard) {
    this.gameboard = aGameboard;
    this.cargarXML("config.xml");
    this.parseXML();
  }
  
  private void parseXML() {
    try {
      NodeList nList = this.doc.getElementsByTagName("configuration");
      for (int temp = 0; (temp < nList.getLength()); temp++) {
        {
          Node nNode = nList.item(temp);
          short _nodeType = nNode.getNodeType();
          boolean _equals = (_nodeType == Node.ELEMENT_NODE);
          if (_equals) {
            Element eElement = ((Element) nNode);
            String _parseNode = this.parseNode(eElement, "gameboardTitle");
            this.gameboard.setTittle(_parseNode);
            String _parseNode_1 = this.parseNode(eElement, "gameboardWidth");
            int _parseInt = Integer.parseInt(_parseNode_1);
            this.gameboard.setCantCellX(_parseInt);
            String _parseNode_2 = this.parseNode(eElement, "gameboardHeight");
            int _parseInt_1 = Integer.parseInt(_parseNode_2);
            this.gameboard.setCantCellY(_parseInt_1);
            VisualComponent _characterVisualcomponent = this.gameboard.getCharacterVisualcomponent();
            String _parseNode_3 = this.parseNode(eElement, "imageCharacter");
            _characterVisualcomponent.setImage(_parseNode_3);
          }
        }
      }
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  private void cargarXML(final String string) {
    try {
      File fXmlFile = new File(string);
      DocumentBuilderFactory _newInstance = DocumentBuilderFactory.newInstance();
      DocumentBuilder _newDocumentBuilder = _newInstance.newDocumentBuilder();
      Document _parse = _newDocumentBuilder.parse(fXmlFile);
      this.doc = _parse;
      Element _documentElement = this.doc.getDocumentElement();
      _documentElement.normalize();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  private String parseNode(final Element anElement, final String label) {
    NodeList _elementsByTagName = anElement.getElementsByTagName(label);
    Node _item = _elementsByTagName.item(0);
    return _item.getTextContent();
  }
}
