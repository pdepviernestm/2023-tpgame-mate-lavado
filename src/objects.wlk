import gameplay.*
import wollok.game.*
import store.*
import visuals.*
import menu.*

class ObjetoDeJuego {
	var property image
	var property position = game.at(15, 10)
	var property ultimaPosicion = 15
	const property posicionesPosibles
	
	method aparecer(posicion) {
		ultimaPosicion = posicion
		position = game.at(ultimaPosicion, 10)
	}
	
	method aparecer() {self.aparecer(posicionesPosibles.anyOne())}
	
	method mover() {position = position.down(1)}
}

class Chocable inherits ObjetoDeJuego{
	method chocar()
}

class Obstaculo inherits Chocable {
	override method chocar() {
		if (not auto.inmunidad()) {
			auto.vidasEnPartida(auto.vidasEnPartida() - 1)
			auto.inmunidad(true)
			game.schedule(1000, {auto.inmunidad(false)})
			cartelVidas.actualizar()
			corazon.aparece()
			if (auto.vidasEnPartida() == 0) {
				juego.terminarEventos()
				enPantalla.hay(estadoIntermedio)
				game.schedule(3000, {
					cambio.conTransicionEntre(juego, menu)
				})
			}
		}
	}
}

class Barril inherits Obstaculo (
	image = "barril.png",
	posicionesPosibles = [4,5,6,7,8]
) {}

class Vaca inherits Obstaculo (
	image = "vaca.png",
	posicionesPosibles = [4,6,8] ) {
	
	override method aparecer() {
		const libre = generador.lugaresLibres().filter{num => posicionesPosibles.contains(num)}
		self.aparecer(libre.anyOne())
	}
	
	method correrse() {
		if (self.position().x() == auto.position().x()) {
			position = position.up(1)
			if (self.position().x() == posicionesPosibles.first()) {position = position.left(1)}
			else {position = position.right(1)}
		}
	}
}

class Moneda inherits Chocable (
	image = "moneda.png",
	posicionesPosibles = [4,5,6,7,8] ) {
		
	override method chocar() {
		position = game.at(20, 10)
		monedasTienda.agregar(1)
	}
}

class Cactus inherits ObjetoDeJuego (
	image = "cactus.png",
	posicionesPosibles = [0, 1, 2, 11, 12, 13] ){
}