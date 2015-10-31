package org.uqbar.project.wollok.game

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class BalloonMessage {
	var String text
	var long timestamp = 0
	var long timeToLive = 2000
	
	new (String aText){
		text = aText
	}
	
	def boolean removeMe(){
		if (timestamp == 0) return false
		return new Date().time - timestamp > timeToLive  
	}
	
	def getText(){
		if (timestamp == 0)
			timestamp = new Date().time
		return text	
	}
}