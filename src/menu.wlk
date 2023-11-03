import wollok.game.*
import visuals.*
import store.*
import gameplay.*
import music.*
import controls.*

object menu inherits Pantalla (
	codigo = 1,
	objetos = [fondo, cartel, botonJugar, botonTienda, botonControles, puntero, teclas] ){
		
	// Teclado
	override method up() {puntero.arriba()}
	override method down() {puntero.abajo()}
	override method enter() {
		if (puntero.apuntaA().codigo() == juego.codigo())
			cambio.conTransicionEntre(self, juego)
		else cambio.entre(self, puntero.apuntaA())
	}
	override method r() {game.stop()}
	override method num1() {musica.bajarVolumen()}
	override method num2() {musica.subirVolumen()}
}

const fondo = new Visual (position = game.origin(), image = "background.jpg")
const cartel = new Visual (position = game.at(1,0), image = "logo.png")
const teclas = new Visual (position = game.at(10, 0), image = "teclas.png")

class Boton {
	const property position
	const property image
	const property cualEs
}

const botonJugar = new Boton (position = game.at(8,6), image = "playButton.png", cualEs = juego)
const botonTienda = new Boton (position = game.at(8,4), image = "shopButton.png", cualEs = tienda)
const botonControles = new Boton (position = game.at(8,2), image = "controlsButton.png", cualEs = controles)

object puntero inherits Visual (position = game.at(8,6), image = "pointer.png") {
	
	var property apuntaA = juego
	var fila = 0
	
	method configurar() {
		game.addVisual(self)
		game.onCollideDo(self, {boton => self.apuntaA(boton.cualEs())})
		game.removeVisual(self)
	}
	
	method arriba(){
		if(fila > 0) {
			fila--
			self.position(self.position().up(2))
		}
	}
	
	method abajo(){
		if(fila < 2) {
			fila++
			self.position(self.position().down(2))
		}
	}
}