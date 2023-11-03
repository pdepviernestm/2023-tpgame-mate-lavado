import wollok.game.*
import visuals.*
import gameplay.*
import music.*
import menu.*

object tienda inherits Pantalla (
	codigo = 2,
	objetos = [fondoTienda, seleccionador] + tablas + [tick, monedasTienda, teclas] ){
	
	// Teclado
	override method up() {seleccionador.arriba()}
	override method down() {seleccionador.abajo()}
	override method left() {seleccionador.izquierda()}
	override method right() {seleccionador.derecha()}
	override method enter() {seleccionador.apuntaA().comprar()}
	override method r() {cambio.entre(self, menu)}
	override method num1() {menu.num1()}
	override method num2() {menu.num2()}
	override method space() {monedasTienda.agregar(10)}
}

object monedasTienda {
	var property position = game.at(13,8)
	var property cantidad = 0
	
	method text() = cantidad.toString()
	method textColor() = "4C092A"
	method descontar(_cantidad) {cantidad = cantidad - _cantidad}
	method agregar(_cantidad) {cantidad = cantidad + _cantidad}
}

const fondoTienda = new Visual (position = game.origin(), image = "fondoTienda.jpg")





class Tabla {
	const identificador
	const property precio
	var property estado = noComprado
	
	var property position
	method image() = "Tabla" + identificador.toString() + estado.descripcion() + ".png"
	
	method comprar() {estado.comprar(self)}
	
	method trasComprar() {}
	
	method efecto()
}

class TablaDeAspecto inherits Tabla {
	const property aspectoOriginal = auto.image()
	const property nuevoAspecto
	
	override method trasComprar() {self.efecto()}
	
	override method efecto() {
		if (tick.position() == self.position().up(1)) {
			tick.position(game.at(15,10))
			auto.image(aspectoOriginal)
		}
		else {
			tick.position(self.position().up(1))
			auto.image(nuevoAspecto)
		}
	}
}

object noComprado {
	method comprar(seleccionado) {
		if (monedasTienda.cantidad() >= seleccionado.precio()) {
			seleccionado.estado(comprado)
			seleccionado.efecto()
			monedasTienda.descontar(seleccionado.precio())
		}
	}
	
	method descripcion() = ""
}

object comprado {
	method comprar(seleccionado) {seleccionado.trasComprar()}
	
	method descripcion() = "comp"
}

const tabla1 = new TablaDeAspecto (
	identificador = 1,
	precio = 15,
	position = game.at(1,4),
	nuevoAspecto = "mateSombrero.png" )
	
const tabla2 = new TablaDeAspecto (
	identificador = 2,
	precio = 30,
	position = game.at(5,4),
	nuevoAspecto = "mateAzul.png" )

const tabla3 = new TablaDeAspecto (
	identificador = 3,
	precio = 100,
	position = game.at(9,4),
	nuevoAspecto = "rayoMcqueen.png" )

object tabla4 inherits Tabla (
	identificador = 4,
	precio = 45,
	position = game.at(1,0) ){
	override method efecto() {tormenta.image("tormentaTraslucida.png")}
}

object tabla5 inherits Tabla (
	identificador = 5,
	precio = 60,
	position = game.at(5,0) ){
	override method efecto() {auto.aumentaAgilidad()}
}

object tabla6 inherits Tabla (
	identificador = 6,
	precio = 75,
	position = game.at(9,0) ){
	override method efecto() {auto.vidaExtra()}
}

const tablas = [tabla1, tabla2, tabla3, tabla4, tabla5, tabla6]

object seleccionador {
	var property position = game.at(1,4)
	var property image = "seleccionador.png"
	
	var property apuntaA
	
	method configurar() {
		game.addVisual(self)
		game.onCollideDo(self, {tabla => self.apuntaA(tabla)})
		game.removeVisual(self)
	}

	method arriba() {
		if (position.y() < tabla1.position().y()) position = position.up(4)
	}
	
	method abajo() {
		if (position.y() > tabla6.position().y()) position = position.down(4)
	}
	
	method derecha() {
		if (position.x() < tabla6.position().x()) position = position.right(4)
	}
	
	method izquierda() {
		if (position.x() > tabla1.position().x()) position = position.left(4)
	}
}

object tick {
	var property position = game.at(15,10)
	const property image = "tick.png"
}