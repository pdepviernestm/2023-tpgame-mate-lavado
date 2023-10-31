import wollok.game.*
import visuals.*

object intro inherits Pantalla (
	codigo = 0,
	objetos = [fondoIntro] ){
		
	// Teclado
	override method up() {}
	override method down() {}
	override method left() {}
	override method right() {}
	override method enter() {}
	override method r() {}
	override method num1() {}
	override method num2() {}
	override method space() {}
}

const fondoIntro = new Visual (position = game.origin(), image = "introModelo.png")