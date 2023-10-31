import wollok.game.*
import visuals.*
import store.*
import gameplay.*
import music.*

object menu inherits Pantalla (
	codigo = 1,
	objetos = [fondo, cartel, botonJugar, botonTienda, puntero] ){
		
	// Teclado
	override method up() {puntero.botonJugar()}
	override method down() {puntero.botonTienda()}
	override method left() {}
	override method right() {}
	override method enter() {cambio.desdeMenu()}
	override method r() {game.stop()}
	override method num1() {musica.bajarVolumen()}
	override method num2() {musica.subirVolumen()}
	override method space() {}
}

const fondo = new Visual (position = game.origin(), image = "background.jpg")

const cartel = new Visual (position = game.at(1,0), image = "logo.png")

const botonJugar = new Visual (position = game.at(8,6), image = "playButton.png")

const botonTienda = new Visual (position = game.at(8,4), image = "shopButton.png")

object puntero inherits Visual (position = game.at(12,5), image = "pointer.png") {
	var property apuntaA = juego
	
	method botonJugar(){
		apuntaA = juego
		self.position(game.at(12,5))
	}
	
	method botonTienda(){
		apuntaA = tienda
		self.position(game.at(12,3))
	}
}