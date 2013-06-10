#Gabriela Limonta 10-10385
#John Delgado 10-10196

# Se encarga de crear una nueva clase dada la superclase,
# el nombre de la nueva clase y los atributos que tendrá
# la misma.
def generaClase(superclase, nombre, atributos)
  #Creamos una nueva clase que herede de superclase
  clase = Class::new(superclase) do
    #Asignamos los atributos
    @atributos = atributos

    # Queremos que el campo atributos sea una variable de la clase y no de cada subclase
    # por lo que declaramos atributos en la clase singleton
    class << self
      attr_accessor :atributos
    end

    # Se encarga de inicializar el elemento de la clase
    def initialize(*argumentos)
      # Se levanta una excepcion si el numero de argumentos es diferente
      # al numero de atributos que debe tener.
      raise ArgumentError::new("wrong number of arguments (#{ argumentos.length } for #{ self.class.atributos.length })") if argumentos.length != self.class.atributos.length

      # En hijos se tendrá un arreglo que contiene pares de nombres de atributos y su valor correspondiente.
      @hijos = [self.class.atributos, argumentos].transpose
    end
  end

  # Se le asigna el nombre a la clase
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
