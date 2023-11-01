import wollok.game.*
import visuals.*
import gameplay.*
import music.*
import menu.*

object tienda inherits Pantalla (
	codigo = 2,
	objetos = [fondoTienda, seleccionador] + tablas + [tick, monedas] ){
	
	// Teclado
	override method up() {seleccionador.arriba()}
	override method down() {seleccionador.abajo()}
	override method left() {seleccionador.izquierda()}
	override method right() {seleccionador.derecha()}
	override method enter() {
		const seleccionado = seleccionador.apuntaA()
		if (not seleccionado.comprado()) {seleccionado.comprar()}
		else if (seleccionado.esAspecto()) {seleccionado.efecto()}
	}
	override method r() {cambio.aMenu()}
	override method num1() {menu.num1()}
	override method num2() {menu.num2()}
	override method space() {monedas.agregar(10)}
}

object monedas {
	var property position = game.at(13,8)
	var property cantidad = 0
	
	method text() = cantidad.toString()
	method textColor() = "4C092A"
	method descontar(_cantidad) {cantidad = cantidad - _cantidad}
	method agregar(_cantidad) {cantidad = cantidad + _cantidad}
}

const fondoTienda = new Visual (position = game.origin(), image = "fondoTienda.jpg")

class Tabla {
	var property position
	var property image
	const tablaComprada
	const property esAspecto = false
	
	const precio
	var property comprado = false
	
	method comprar() {
		if (monedas.cantidad() >= precio) {
			monedas.descontar(precio)
			comprado = true
			self.efecto()
			image = tablaComprada
		}
	}
	
	method efecto()
}

class TablaDeAspecto inherits Tabla (esAspecto = true) {
	const nuevoAspecto
	
	override method comprar() {
		super()
		tick.position(self.position())
	}
	
	override method efecto() {
		if (tick.position() == self.position()) {
			tick.position(game.at(15,10))
			auto.image("mate.png")
		}
		else {
			tick.position(self.position())
			auto.image(nuevoAspecto)
		}
	}
}

const tabla1 = new TablaDeAspecto (
	position = game.at(1,5),
	image = "Tabla1.png",
	tablaComprada = "Tabla1comp.png",
	precio = 15,
	nuevoAspecto = "mateSombrero.png" )
	
const tabla2 = new TablaDeAspecto (
	position = game.at(5,5),
	image = "Tabla2.png",
	tablaComprada = "Tabla2comp.png",
	precio = 30,
	nuevoAspecto = "mateAzul.png" )

const tabla3 = new TablaDeAspecto (
	position = game.at(9,5),
	image = "Tabla3.png",
	tablaComprada = "Tabla3comp.png",
	precio = 100,
	nuevoAspecto = "rayoMcqueen.png" )

object tabla4 inherits Tabla (
	position = game.at(1,1),
	image = "Tabla4.png",
	tablaComprada = "Tabla4comp.png",
	precio = 45 ){
	override method efecto() {tormenta.image("tormentaTraslucida.png")}
}

object tabla5 inherits Tabla (
	position = game.at(5,1),
	image = "Tabla5.png",
	tablaComprada = "Tabla5comp.png",
	precio = 60 ){
	override method efecto() {auto.aumentaAgilidad()}
}

object tabla6 inherits Tabla (
	position = game.at(9,1),
	image = "Tabla6.png",
	tablaComprada = "Tabla6comp.png",
	precio = 75 ){
	override method efecto() {auto.vidaExtra()}
}

const tablas = [tabla1, tabla2, tabla3, tabla4, tabla5, tabla6]

object seleccionador {
	var property position = game.at(1,4)
	var property image = "seleccionador.png"
	
	var apuntaA = 0
	method apuntaA() = tablas.get(apuntaA)

	method arriba() {
		if (position.y() == 0) {
			position = game.at(position.x(), 4)
			apuntaA = apuntaA - 3
		}
	}
	
	method abajo() {
		if (position.y() == 4) {
			position = game.at(position.x(), 0)
			apuntaA = apuntaA + 3
		}
	}
	
	method derecha() {
		if (position.x() < 9) {
			position = game.at(position.x() + 4, position.y())
			apuntaA = apuntaA + 1
		}
	}
	
	method izquierda() {
		if (position.x() > 1) {
			position = game.at(position.x() - 4, position.y())
			apuntaA = apuntaA - 1
		}
	}
}

object tick {
	var property position = game.at(15,10)
	const property image = "tick.png"
}