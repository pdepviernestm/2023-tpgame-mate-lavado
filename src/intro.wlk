import wollok.game.*
import visuals.*

object intro inherits Pantalla (
	codigo = 0,
	objetos = [fondoIntro] ){
}

const fondoIntro = new Visual (position = game.origin(), image = "introModelo.png")