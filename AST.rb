def generaClase(superclase, nombre, atributos)
  clase = Class::new(superclase) do
    @atributos = atributos

    class << self
      attr_accessor :atributos
    end

    def initialize(*argumentos)
      raise ArgumentError::new("wrong number of arguments (#{ argumentos.length } for #{ self.class.atributos.length })") if argumentos.length != self.class.atributos.length

      @hijos = [self.class.atributos, argumentos].transpose
    end
  end
  Object::const_set nombre, clase
end

generaClase(Object, 'AST', [])
  generaClase(AST, 'Declaracion', ['variables', 'tipo'])
  generaClase(AST, 'Declaraciones', ['declaraciones'])
  generaClase(AST, 'Programa'   , ['instruccion'])
  generaClase(AST, 'Caso'       , ['rango', 'instruccion'])
  generaClase(AST, 'Expresion', [])
    generaClase(Expresion, 'Modulo'         , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Multiplicacion' , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Suma'           , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Resta'          , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Construccion'   , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Division'       , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Diferencia'     , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Desigual'       , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Menor_Que'      , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Menor_Igual_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Interseccion'   , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Igual'          , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Mayor_Que'      , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Mayor_Igual_Que', ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Pertenece'      , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'And'            , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Or'             , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Not'            , ['operando'])
    generaClase(Expresion, 'Menos_Unario'   , ['operando'])
    generaClase(Expresion, 'Entero'         , ['valor'])
    generaClase(Expresion, 'True'           , [])
    generaClase(Expresion, 'False'          , [])
    generaClase(Expresion, 'Variable'       , ['nombre'])
    generaClase(Expresion, 'Funcion_Bottom' , ['argumento'])
    generaClase(Expresion, 'Funcion_Length' , ['argumento'])
    generaClase(Expresion, 'Funcion_Rtoi'   , ['argumento'])
    generaClase(Expresion, 'Funcion_Top'    , ['argumento'])
  generaClase(AST, 'Instruccion', [])
    generaClase(Instruccion, 'Asignacion'      , ['var', 'val'])
    generaClase(Instruccion, 'Bloque'          , ['.declaraciones', '-instrucciones'])
    generaClase(Instruccion, 'Read'            , ['variable'])
    generaClase(Instruccion, 'Write'           , ['elementos'])
    generaClase(Instruccion, 'Writeln'         , ['elementos'])
    generaClase(Instruccion, 'Condicional_Else', ['condicion', 'verdadero', 'falso'])
    generaClase(Instruccion, 'Condicional_If'  , ['condicion', 'verdadero'])
    generaClase(Instruccion, 'Case'            , ['exp', 'casos'])
    generaClase(Instruccion, 'Iteracion_Det'   , ['variable', 'rango', 'instruccion'])
    generaClase(Instruccion, 'Iteracion_Indet' , ['condicion', 'instruccion'])

class AST
  def to_s
    (to_string 0).sub(/\A[\n ]*/, '').gsub(/\s+$/, '')
  end

  def to_string(profundidad)
    @hijos.inject("\n" + self.class.to_s.upcase) do |acum, cont|
      case cont[0]
        when /\A\./
          acum
        when /\A-/
          acum + cont[1].to_string(1)
        else
          acum + "\n  #{cont[0]}: #{ cont[1].to_string(2) }"
        end
    end.gsub(/^/, '  '*profundidad)
  end
end

class Programa
  def to_string(profundidad)
    @hijos[0][1].to_string(profundidad)
  end
end
