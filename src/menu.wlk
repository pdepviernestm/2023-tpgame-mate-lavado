import wollok.game.*
import visuals.*
import store.*
import gameplay.*
import music.*

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
const botonJugar = new Visual (position = game.at(8,7), image = "playButton.png")
const botonTienda = new Visual (position = game.at(8,5), image = "shopButton.png")
const botonControles = new Visual (position = game.at(8,3), image = "controlsButton.png")
const teclas = new Visual (position = game.at(10, 0), image = "teclas.png")

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
	codigo = 4,
	objetos = [pantallaControles, teclasControles] ){
		
	// Teclado
	override method r() {cambio.entre(self, menu)}
	override method num1() {menu.num1()}
	override method num2() {menu.num2()}
}

const pantallaControles = new Visual (position = game.at(0, 0), image = "fondoControles.png")

const teclasControles = new Visual (position = game.at(10, 0), image = "teclasControles.png")