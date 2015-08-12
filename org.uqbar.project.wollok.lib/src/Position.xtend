import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger

class Position {
	var int x  
	var int y
		
	def getX() {
		return new WollokInteger(x);
	}
	
	def setX(int x) {
		this.x = x;
	}
	
	def getY() {
		return new WollokInteger(y);
	}
	
	def setY(int y) {
		this.y = y;
	}	
	
}	