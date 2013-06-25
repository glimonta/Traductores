#Gabriela Limonta 10-10385
#John Delgado 10-10196

require 'Type'
require 'SymTable'

class ContextError < RuntimeError
end

class NoConcuerdaEspecial < ContextError
  def initialize(izquierdo, operador)
    @izquierdo = izquierdo
    @operador = operador
  end

  def to_s
    "Error en la línea #{@izquierdo.linea}, columna #{@izquierdo.columna}: intento de '#{@operador.texto}' la variable '#{@izquierdo.texto}' es del tipo '#{@izquierdo.type}'."
  end
end

class NoConcuerdan < ContextError
  def initialize(izquierdo, operador, derecho)
    @izquierdo = izquierdo
    @derecho = derecho
    @operador = operador
  end

  def to_s
    "Error en la línea #{@izquierdo.linea}, columna #{@izquierdo.columna}: intento de '#{@operador}' la variable '#{@izquierdo.texto}' del tipo '#{@izquierdo.class}' y la variable '#{@derecho.texto}' del tipo '#{@derecho.class}'."
  end
end

class NoMutable < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error en línea #{@token.linea}, columna #{@token.columna}: se intenta modificar la variable '#{@token.texto}' la cual pertenece a una iteracion"
  end
end

class NoDeclarada < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error en línea #{@token.linea}, columna #{@token.columna}: no puede usar la variable '#{token.texto}' pues no ha sido declarada"
  end
end

class NoSonRangeNiEnteros < ContextError
  def initialize(token, token2)
     @token = token
     @token2 = token2
  end

  def to_s
    "Las variables '#{@token2.texto}' y '#{@token.texto}', en la linea #{@token.linea}, no son del mismo tipo"
  end
end

class NoSonRange < ContextError
  def initialize(token, token2)
     @token = token
     @token2 = token2
  end

  def to_s
    "Las variables '#{@token2.texto}' y '#{@token.texto}', en la linea #{@token.linea}, no son del tipo range"
  end
end

class NoSonBool < ContextError
  def initialize(token, token2)
     @token = token
     @token2 = token2
  end

  def to_s
    "Las variables '#{@token2.texto}' y '#{@token.texto}', en la linea #{@token.linea}, no son del tipo bool"
  end
end

class NoSonEnteros < ContextError
  def initialize(token, token2)
     @token = token
     @token2 = token2
  end

  def to_s
    "Las variables '#{@token2.texto}' y '#{@token.texto}', en la linea #{@token.linea}, no son del tipo int"
  end
end

class ErrorIteracion_I < ContextError
   def to_s
     "El tipo de expresion no es un booleano"
   end
end

class ErrorIteracion_D < ContextError
   def to_s
     "El tipo de rango no es un range"
   end
end

class NoEsInt < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "La variable '#{@token.texto}', no es del tipo int"
  end
end

class NoEsBool < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "La variable '#{@token.texto}', no es del tipo bool"
  end
end

class NoEsRange < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "La variable '#{@token.texto}', no es del tipo range"
  end
end


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

    def method_missing(nombre, *argumentos)
      par = @hijos.map {|nombre_, contenido| [nombre_.sub(/\A[.-]/, ''), contenido] }.assoc(nombre.to_s.gsub(/_/, ' '))
      raise NoMethodError::new("undefined method `#{nombre}' for #{self.class.name}") if par.nil?
      par[1]
    end
  end

  # Se le asigna el nombre a la clase
  Object::const_set nombre, clase
end

# A continuación generamos todas las clases necesarias para cubrir el lenguaje.
generaClase(Object, 'AST', [])
  generaClase(AST, 'Declaracion'  , ['variables', 'tipo'])
  generaClase(AST, 'Programa'     , ['instruccion'])
  generaClase(AST, 'Caso'         , ['rango', 'instruccion'])
  generaClase(AST, 'Expresion'    , [])
    generaClase(Expresion, 'Modulo'         , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Por'            , ['operando izquierdo', 'operando derecho'])#usar delegados
    generaClase(Expresion, 'Mas'            , ['operando izquierdo', 'operando derecho'])#usar delegados
    generaClase(Expresion, 'Resta'          , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Construccion'   , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Division'       , ['operando izquierdo', 'operando derecho'])
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
    generaClase(Instruccion, 'Asignacion'      , ['var', 'expresion'])
    generaClase(Instruccion, 'Bloque'          , ['declaraciones', '-instrucciones']) #TODO hay que arreglar lo del . y el - para el method_missing
    generaClase(Instruccion, 'Read'            , ['variable'])
    generaClase(Instruccion, 'Write'           , ['elementos'])
    generaClase(Instruccion, 'Writeln'         , ['elementos'])
    generaClase(Instruccion, 'Condicional_Else', ['condicion', 'verdadero', 'falso'])
    generaClase(Instruccion, 'Condicional_If'  , ['condicion', 'verdadero'])
    generaClase(Instruccion, 'Case'            , ['exp', 'casos'])
    generaClase(Instruccion, 'Iteracion_Det'   , ['variable', 'rango', 'instruccion'])
    generaClase(Instruccion, 'Iteracion_Indet' , ['condicion', 'instruccion'])

# Modificamos la clase AST para agregarle el to_s y to_string
class AST
  # Se encarga de pasar a string el AST llamando a to_string con profundidad cero
  # y eliminando cualquier salto de línea del inicio y cualquier cantidad de
  # espacios en blancos.
  def to_s
    (to_string 0).sub(/\A[\n ]*/, '').gsub(/\s+$/, '')
  end

  # Se encarga de pasar a string el AST a la profundidad indicada.
  def to_string(profundidad)
    # Creamos un string con el nombre de la clase en mayusculas
    # continuado por el string generado por to_string de sus hijos.
    @hijos.inject("\n" + self.class.to_s.upcase) do |acum, cont|
      # Se utiliza un formato que permite ignorar la impresion de ciertos
      # nombres de atributos y/o elementos de alguna clase. Por ejemplo:
      # No se deben imprimir las declaraciones ni la palabra 'instrucciones'
      # para un bloque. De este modo se le coloca un . a lo que no queremos imprimir
      # (declaraciones) y un - a los titulos de atributos que no queremos imprimir
      # (instrucciones)
      case cont[0]
        # Si el primer caracter es un '.' se genera solamente lo que se lleva acumulado
        when /\A\./
          acum
        # Si el primer caracter es un '-' se genera el string acumulado mas el to_string
        # del contenido del atributo
        when /\A-/
          acum + cont[1].to_string(1)
        # En cualquier otro caso se genera el string que contiene el nombre del atributo
        # seguido por dos puntos y luego el to_string del contenido del atributo
        else
          acum + "\n  #{cont[0]}: #{ cont[1].to_string(2) }"
        end
    # Por ultimo se identa adecuadamente sustituyendo el inicio del string por la cantidad
    # de espacios en blanco necesarios (2*profundidad)
    end.gsub(/^/, '  '*profundidad)
  end
end

# Modificamos la clase Programa para agregar un to_string diferente
class Programa
  # Se encarga de imprimir el contenido del programa
  # sin imprimir la palabra 'PROGRAMA' en el AST
  def to_string(profundidad)
    @hijos[0][1].to_string(profundidad)
  end

  def check
    self.instruccion.check(SymTable::new)
  end
end

class Expresion
  attr_reader :type
end

class Modulo
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Modulo", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Modulo", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Modulo", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonEnteros::new unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Int
  end
end

class Por
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    case [self.operando_izquierdo.type, self.operando_derecho.type]
      when [Rangex::Int  , Rangex::Int] then @type = Rangex::Int
      when [Rangex::Range, Rangex::Int] then @type = Rangex::Range
      else
        raise NoConcuerdan::new self.operando_izquierdo.nombre, "Multiplicacion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable)
        raise NoConcuerdan::new self.operando_izquierdo.valor , "Multiplicacion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable)
        raise NoConcuerdan::new self.operando_izquierdo.nombre, "Multiplicacion", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero)
    end
  end
end

class Mas
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    if Rangex::Range == self.operando_izquierdo.type then
      raise NoConcuerdan::new self.operando_izquierdo.nombre, "Union", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
      raise NoConcuerdan::new self.operando_izquierdo.valor , "Union", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
      raise NoConcuerdan::new self.operando_izquierdo.nombre, "Union", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    else
      raise NoConcuerdan::new self.operando_izquierdo.nombre, "Suma", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
      raise NoConcuerdan::new self.operando_izquierdo.valor , "Suma", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
      raise NoConcuerdan::new self.operando_izquierdo.nombre, "Suma", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    end
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = self.operando_izquierdo.type
  end
end

class Resta
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Resta", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Resta", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Resta", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonEnteros::new unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Int
  end
end

class Construccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Construccion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Construccion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Construccion", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonEnteros::new unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Range
  end
end

class Division
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Division", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Division", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Division", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonEnteros::new unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Int
  end
end

class Desigual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Desigual", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Desigual", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Desigual", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Menor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Menor que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Menor que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Menor que", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Menor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Menor o igual que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Menor o igual que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Menor o igual que", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Interseccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Interseccion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Interseccion", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Interseccion", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRange::new unless Rangex::Range == self.operando_derecho.type
    @type = Rangex::Range
  end
end

class Igual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Igual", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Igual", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Igual", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Mayor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Mayor que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Mayor que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Mayor que", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Mayor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Mayor o igual que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Mayor o igual que", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Entero) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Mayor o igual que", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Entero) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonRangeNiEnteros::new unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Pertenece
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    raise NoEsInt::new unless Rangex::Int == self.operando_izquierdo.type
    self.operando_derecho.check(tabla)
    raise NoEsRange::new unless Rangex::Range == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class And
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "And", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "And", self.operando_derecho.nombre if (self.operando_izquierdo.instance_of?(True) or self.operando_izquierdo.instance_of?(False)) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "And", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and (self.operando_izquierdo.instance_of?(True) or self.operando_izquierdo.instance_of?(False)) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonBool unless Rangex::Bool == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class Or
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Or", self.operando_derecho.nombre if self.operando_izquierdo.instance_of?(Variable) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.valor , "Or", self.operando_derecho.nombre if (self.operando_izquierdo.instance_of?(True) or self.operando_izquierdo.instance_of?(False)) and self.operando_derecho.instance_of?(Variable) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoConcuerdan::new self.operando_izquierdo.nombre, "Or", self.operando_derecho.valor if self.operando_izquierdo.instance_of?(Variable) and (self.operando_izquierdo.instance_of?(True) or self.operando_izquierdo.instance_of?(False)) and self.operando_izquierdo.type != self.operando_derecho.type
    raise NoSonBool::new unless Rangex::Bool == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class Not
  def check(tabla)
    self.operando.check(tabla)
    raise NoEsBool::new unless Rangex::Bool == self.operando.type
    @type = Rangex::Bool
  end
end

class Menos_Unario
  def check(tabla)
    self.operando.check(tabla)
    raise NoEsInt::new unless Rangex::Int == self.operando.type
    @type = Rangex::Int
  end
end

class Entero
  def check(tabla)
    @type = Rangex::Int
  end
end

class True
  def check(tabla)
    @type = Rangex::Bool
  end
end

class False
  def check(tabla)
    @type = Rangex::Bool
  end
end

class Variable
  def check(tabla)
    variable = tabla.find(self.nombre.texto)
    raise NoDeclarada::new self.nombre if variable.nil?
    @type = variable[:tipo]
  end
end

class Funcion_Bottom
  def check(tabla)
    self.argumento.check(tabla)
    raise NoEsRange::new unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Length
  def check(tabla)
    self.argumento.check(tabla)
    raise NoEsRange::new unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Length
  def check(tabla)
    self.argumento.check(tabla)
    raise NoEsRange::new unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion
  def check(tabla)
    self.argumento.check(tabla)
    raise NoEsRange::new unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Asignacion
  def check(tabla)
    variable = tabla.find(self.var.texto)
    raise NoDeclarada::new self.var if variable.nil?

    raise NoMutable::new self.var unless variable[:es_mutable]

    self.expresion.check(tabla)
    raise NoConcuerdaEspecial::new self.var self.expresion unless variable[:tipo] == self.expresion.type
  end
end

class Bloque
  def check(tabla)
    tabla2 = self.declaraciones.inject(SymTable::new(tabla)) do |acum, declaracion|
      declaracion.variables.inject(acum) do |acum2, variable|
        acum2.insert(variable, declaracion.tipo.to_type)
      end
    end

    self.instrucciones.each do |instruccion|
      instruccion.check(tabla2)
    end
  end
end

class Read
  def check(tabla)
    variable = tabla.find(self.variable.texto)
    raise NoDeclarada::new self.variable if variable.nil?
    raise NoMutable::new self.varible unless variable[:es_mutable]
  end
end

class Write
  def check(tabla)
    self.elementos.each do |elemento|
      elemento.check(tabla) unless elemento.is_a?(TkString)
    end
  end
end

class Writeln
  def check(tabla)
    self.elementos.each do |elemento|
      elemento.check(tabla) unless elemento.is_a?(TkString)
    end
  end
end

class Condicional_Else
  def check(tabla)
    self.condicion.check(tabla)
    raise NoEsBool:: new unless Rangex::Bool == self.condicion.type

    self.verdadero.check(tabla)
    self.falso.check(tabla)
  end
end

class Condicional_If
  def check(tabla)
    self.condicion.check(tabla)
    raise NoEsBool::new self.condicion unless Rangex::Bool == self.condicion.type

    self.verdadero.check(tabla)
  end
end

class Case
  def check(tabla)
    self.exp.check(tabla)
    raise NoEsInt::new self.condicion unless Rangex::Int == self.condicion.type

    self.casos.each do |caso|
      caso.check(tabla) unless caso.is_a?(TkString)
    end
  end
end

class Iteracion_Det
  def check(tabla)
    self.rango.check(tabla)
    raise ErrorIteracion_D::new unless Rangex::Range == self.rango.type
    tabla2 = SymTable::new(tabla).insert(self.variable, Rangex::Int, false)
    self.instruccion.check(tabla2)
  end
end

class Iteracion_Indet
  def check(tabla)
    self.condicion.check(tabla)
    raise ErrorIteracion_I::new unless Rangex::Bool == self.condicion.type

    self.instruccion.check(tabla)
  end
end
