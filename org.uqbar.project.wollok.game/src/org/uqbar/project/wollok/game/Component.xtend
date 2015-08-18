package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Component {
	var String image
	var boolean solid
	var boolean mayIMove
	
	new (){
		super()
	}
	new(String image, boolean imSolid, boolean mayIMove){
		this.image = image
		this.solid = imSolid
		this.mayIMove = mayIMove
	}
}