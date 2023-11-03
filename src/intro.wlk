import wollok.game.*
import visuals.*
import music.*

object intro inherits Pantalla (
	codigo = 0,
	objetos = [fondoIntro] ){
		
	override method musicaAlOcultar() {musica.reproducir()}
}

const fondoIntro = new Visual (position = game.origin(), image = "introModelo.png")