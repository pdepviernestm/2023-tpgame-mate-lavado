import wollok.game.*
import visuals.*
import store.*
import gameplay.*
import music.*

object menu inherits Pantalla (
	codigo = 1,
	objetos = [fondo, cartel, botonJugar, botonTienda, botonControles, puntero] ){
		
	// Teclado
	override method up() {puntero.arriba()}
	override method down() {puntero.abajo()}
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
const botonJugar = new Visual (position = game.at(8,7), image = "playButton.png")
const botonTienda = new Visual (position = game.at(8,5), image = "shopButton.png")
const botonControles = new Visual (position = game.at(8,3), image = "controlsButton.png")

object puntero inherits Visual (position = game.at(12,6), image = "pointer.png") {
	
	var apuntaA = 0
	method apuntaA() = [juego, tienda, controles].get(apuntaA)
	
	method arriba(){
		if(apuntaA > 0) {
			apuntaA--
			self.position(self.position().up(2))
		}
	}
	
	method abajo(){
		if(apuntaA < 2) {
			apuntaA++
			self.position(self.position().down(2))
		}
	}
}

object controles inherits Pantalla (
	codigo = 5,
	objetos = [pantallaControles] ){
		
	// Teclado
	override method up() {}
	override method down() {}
	override method left() {}
	override method right() {}
	override method enter() {}
	override method r() {cambio.aMenu()}
	override method num1() {menu.num1()}
	override method num2() {menu.num2()}
	override method space() {}
}

const pantallaControles = new Visual (position = game.at(0, 0), image = "transicion.png")