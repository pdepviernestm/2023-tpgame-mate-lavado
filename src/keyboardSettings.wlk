import visuals.*
import wollok.game.*
import menu.*
import store.*
import gameplay.*
import music.*

object teclado {
	
	method configurate() {
		keyboard.up().onPressDo {enPantalla.hay().up()}
		keyboard.down().onPressDo {enPantalla.hay().down()}
		keyboard.left().onPressDo {enPantalla.hay().left()}
		keyboard.right().onPressDo {enPantalla.hay().right()}
		keyboard.enter().onPressDo {enPantalla.hay().enter()}
		keyboard.r().onPressDo {enPantalla.hay().r()}
		keyboard.num1().onPressDo {enPantalla.hay().num1()}
		keyboard.num2().onPressDo {enPantalla.hay().num2()}
		keyboard.space().onPressDo {enPantalla.hay().space()}
	}
}
