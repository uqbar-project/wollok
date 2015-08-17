package org.uqbar.project.wollok.game

import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.Node
import org.w3c.dom.NodeList

class GameFactory {

	var Document doc
	var Gameboard gameboard

	def void setGame(Gameboard aGameboard) {
		this.gameboard = aGameboard
		cargarXML("config.xml")
		parseXML()
	}

	private def parseXML() {
		try {
			var NodeList nList = doc.getElementsByTagName("configuration");
			for (var int temp = 0; temp < nList.getLength(); temp++) {
				var Node nNode = nList.item(temp);
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					var Element eElement = nNode as Element;
					//System.out.println("Staff id : " + eElement.getAttribute("id"));
					gameboard.tittle = parseNode(eElement, "gameboardTitle")
					gameboard.setCantCellX(Integer.parseInt(parseNode(eElement, "gameboardWidth")))
					gameboard.setCantCellY(Integer.parseInt(parseNode(eElement, "gameboardHeight")))
					gameboard.getCharacterVisualcomponent().image = parseNode(eElement, "imageCharacter")
					//<imageCharacter>sokoban.jpg</imageCharacter>
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private def cargarXML(String string) {
		try {
			var File fXmlFile = new File(string);
			doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(fXmlFile);
			doc.getDocumentElement().normalize();

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private def String parseNode(Element anElement, String label) {
		anElement.getElementsByTagName(label).item(0).getTextContent()
	}
}
