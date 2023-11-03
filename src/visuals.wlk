import wollok.game.*
import keyboardSettings.*
import music.*
import intro.*
import menu.*
import store.*
import gameplay.*

class Visual {
	var property position
	var property image
}

class Pantalla {
	const property codigo
	const objetos
	method mostrar() {objetos.forEach{obj => game.addVisual(obj)}}
	method ocultar() {objetos.forEach{obj => game.removeVisual(obj)}}
	
	// Teclado
	method up()
	method down()
	method left()
	method right()
	method enter()
	method r()
	method num1()
	method num2()
	method space()
}

//--------------------- LO QUE SE MUESTRA EN PANTALLA ---------------------

object enPantalla {
	var property hay = intro
	method codigo() = hay.codigo()
	/*
	   0 = Intro
	   1 = Menu
	   2 = Tienda
	   3 = Juego
	   4 = Controles
	   5 = Transicion
	 */
}

//----------------------- CAMBIO ENTRE PANTALLAS -----------------------

object cambio {
	method entre(anterior, siguiente) {
		self.controlarMusica(anterior, siguiente)
		anterior.ocultar()
		siguiente.mostrar()
		enPantalla.hay(siguiente)
	}
	
	method conTransicionEntre(anterior, siguiente) {
		self.controlarMusica(anterior, siguiente)
		transicion.realizar(anterior, siguiente)
	}
	
	method controlarMusica(anterior, siguiente) {
		if (siguiente.codigo() == juego.codigo()) {musica.pausar()}
		if (anterior.codigo() == juego.codigo()) {musica.reanudar()}
	}
}

object transicion {
	var property position = game.at(-15, 0)
	method image() = "transicion.png"
	
	method realizar(anterior, siguiente) {
		enPantalla.hay(estadoIntermedio)
		game.addVisual(self)
		game.onTick(25, "Transicion", {position = position.right(1)})
		game.schedule(25 * 20, {
			anterior.ocultar()
			siguiente.mostrar()
			game.removeVisual(self)
			game.addVisual(self)
		})
		game.schedule(25 * 40, {
			game.removeTickEvent("Transicion")
			game.removeVisual(self)
			position = game.at(-15, 0)
			enPantalla.hay(siguiente)
		})
	}
}

object estadoIntermedio inherits Pantalla (
	codigo = 5,
	objetos = [] ){
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