import visuals.*
import menu.*
import wollok.game.*

object controles inherits Pantalla (
	codigo = 4,
	objetos = [pantallaControles, teclasControles] ){
		
	// Teclado
	override method r() {cambio.entre(self, menu)}
	override method num1() {menu.num1()}
	override method num2() {menu.num2()}
}

const pantallaControles = new Visual (position = game.at(0, 0), image = "fondoControles.png")

const teclasControles = new Visual (position = game.at(10, 0), image = "teclasControles.png")