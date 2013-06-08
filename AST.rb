def generaClase(superclase, nombre, atributos)
  clase = Class::new(superclase) do
    @etiqueta = nombre.upcase

    def initialize(*argumentos)
      raise ArgumentError::new("wrong number of arguments (#{ argumentos.length } for #{ atributos.length })") if argumentos.length != atributos.length

      @hijos = [atributos, argumentos].transpose.inject({}) do |acum, x|
        acum[x[0]] = x[1]
        acum
      end
    end
  end
  Object::const_set nombre, clase
end

generaClase(Object, 'AST', [])
  generaClase(AST, 'Expresion', [])
    generaClase(Expresion, 'Modulo', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Multiplicacion', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Suma', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Resta', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Construccion', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Division', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Diferencia', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Desigual', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Menor_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Menor_Igual_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Interseccion', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Igual', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Mayor_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Mayor_Igual_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Pertenece', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'And', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Or', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Not', ['operando'])
    generaClase(Expresion, 'Menos_Unario', ['operando'])
    generaClase(Expresion, 'Entero', ['valor'])
    generaClase(Expresion, 'True', [])
    generaClase(Expresion, 'False', [])
    generaClase(Expresion, 'Variable', ['nombre'])
    generaClase(Expresion, 'Funcion_Bottom', ['argumento'])
    generaClase(Expresion, 'Funcion_Length', ['argumento'])
    generaClase(Expresion, 'Funcion_Rtoi', ['argumento'])
    generaClase(Expresion, 'Funcion_Top', ['argumento'])
  generaClase(AST, 'Instruccion', [])
    generaClase(Instruccion, 'Asignacion', ['var', 'val'])
    generaClase(Instruccion, 'Bloque', ['declaraciones', 'instrucciones'])
    generaClase(Instruccion, 'Read', ['variable'])
    generaClase(Instruccion, 'Write', ['elementos'])
    generaClase(Instruccion, 'Condicional_Else', ['condicion', 'instruccionIf', 'instruccionElse'])
    generaClase(Instruccion, 'Condicional_If', ['condicion', 'instruccion'])
    generaClase(Instruccion, 'Case', ['exp', 'casos'])
    generaClase(Instruccion, 'Iteracion_Det', ['variable', 'rango', 'instruccion'])
    generaClase(Instruccion, 'Iteracion_Indet', ['condicion', 'instruccion'])
  generaClase(AST, 'Declaracion', ['declaraciones'])
  generaClase(AST, 'String', ['valor'])
  generaClase(AST, 'Programa', ['instruccion'])

class AST

  class << self #Clase singleton
    attr_accessor :regex
  end

  def to_s
    to_string 0
  end

  def to_string(profundidad)
    @hijos.inject(self.class.nombre) do |acum, cont|
      acum + "\n  #{cont[0]} : #{ cont[1].to_string(profundidad + 1) }"
    end.gsub(/^/, '  '*profundidad)
  end
end

#TODO para el caso de cosas como listas el to_string será distinto ya que
#to_string fallará cuando haga cont[1].to_stringblahblahblah entonces se
#tiene que sobreescribir este metodo y blah blah
#Para los tokens pasa igual, cuando llego a ellos to_string no va a servir
#asi que tengo que hacer un to_string que les sirva a ellos para imprimirse.
