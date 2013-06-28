#Gabriela Limonta 10-10385
#John Delgado 10-10196
module Rangex; end

require 'Type'
require 'SymTable'
require 'Ubicacion'

class ContextError < RuntimeError
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
    "Error en la línea #{@token.linea}, columna #{@token.columna}: La variable '#{@token.texto}', no es del tipo int"
  end
end

class NoEsBool < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error en la línea #{@token.linea}, columna #{@token.columna}: La variable '#{@token.texto}', no es del tipo bool"
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

      @inicio = nil
      @final = nil
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
  attr_reader :inicio, :final

  def set_inicio(i)
    @inicio = i
    self
  end

  def set_final(f)
    @final = f
    self
  end

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
    @final = self.instruccion.final
  end
end

class Expresion
  attr_reader :type
end

class Modulo
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion modulo entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Int != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion modulo entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Int
  end
end

class Caso
  def check(tabla)
    self.rango.check(tabla)
    if Rangex::Range != self.rango.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango del caso es del tipo \"#{self.rango.type}\" en vez de range"
    end
    @inicio = self.rango.inicio
    self.instruccion.check(tabla)
  end
end

class Por
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    case [self.operando_izquierdo.type, self.operando_derecho.type]
      when [Rangex::Int  , Rangex::Int] then @type = Rangex::Int
      when [Rangex::Range, Rangex::Int] then @type = Rangex::Range
      else
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer una operacion con \"por\" entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    end
  end
end

class Mas
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_derecho.type != self.operando_izquierdo.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mas entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if !([Rangex::Int, Rangex::Range].include?(self.operando_izquierdo.type)) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mas entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = self.operando_izquierdo.type
  end
end

class Resta
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion resta entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Int != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion resta entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Int
  end
end

class Construccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion construccion entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Int != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion construccion entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Range
  end
end

class Division
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion division entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Int != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion division entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Int
  end
end

class Desigual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion desigual entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion desigual entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Menor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion menor que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion menor que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Menor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion menor o igual que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion menor o igual que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Interseccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion interseccion entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Range != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion interseccion entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Range
  end
end

class Igual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion igual entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion igual entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Mayor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mayor que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mayor que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Mayor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mayor o igual que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if ![Rangex::Int, Rangex::Range].include?(self.operando_derecho.type) then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion mayor o igual que entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Pertenece
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    if Rangex::Int != self.operando_izquierdo.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion pertenece entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    end
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if Rangex::Range != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion pertenece entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    end
    @type = Rangex::Bool
  end
end

class And
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion and entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Bool != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion and entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Or
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    if self.operando_izquierdo.type != self.operando_derecho.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion or entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
    else
      if Rangex::Bool != self.operando_derecho.type then
        @type = Rangex::TypeError
        raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion or entre operandos de tipos \"#{self.operando_izquierdo.type}\" y \"#{self.operando_derecho.type}\""
      end
    end
    @type = Rangex::Bool
  end
end

class Not
  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando.final
    if Rangex::Bool != self.operando.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion not a un operando de tipo \"#{self.operando.type}\""
    end
    @type = Rangex::Bool
  end
end

class Menos_Unario
  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando_derecho.final
    if Rangex::Int != self.operando.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion menos unario a un operando de tipo \"#{self.operando.type}\""
    end
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
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la variable \"#{self.nombre.texto}\" no se encuentra declarada" if variable.nil?
    @type = variable[:tipo]
  end
end

class Funcion_Bottom
  def check(tabla)
    self.argumento.check(tabla)
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la funcion bottom es de tipo \"#{self.argumento.type}\"" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Length
  def check(tabla)
    self.argumento.check(tabla)
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la funcion length es de tipo \"#{self.argumento.type}\"" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Top
  def check(tabla)
    self.argumento.check(tabla)
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la funcion top es de tipo \"#{self.argumento.type}\"" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Rtoi
  def check(tabla)
    self.argumento.check(tabla)
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la funcion rtoi es de tipo \"#{self.argumento.type}\"" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Asignacion
  def check(tabla)
    variable = tabla.find(self.var.texto)
    if variable.nil? then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la variable \"#{self.var.texto}\" no ha sido declarada"
    end

    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta modificar la variable \"#{self.var.texto}\" que pertenece a una iteración" unless variable[:es_mutable]

    self.expresion.check(tabla)
    @final = self.expresion.final
    if variable[:tipo] != self.expresion.type then
      @type = Rangex::TypeError
      raise  "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta asignar algo del tipo \"#{self.expresion.type}\" a la variable \"#{self.var.texto}\" de tipo \"#{self.var.type}\""
    end
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
    if variable.nil? then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la variable \"#{self.var.texto}\" no ha sido declarada"
    end
    @type = Rangex::TypeError
    raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta modificar la variable \"#{self.var.texto}\" que pertenece a una iteración" unless variable[:es_mutable]
  end
end

class Write
  def check(tabla)
    self.elementos.each do |elemento|
      elemento.check(tabla) unless elemento.is_a?(TkString)
    end
    @final = self.elementos.final
  end
end

class Writeln
  def check(tabla)
    self.elementos.each do |elemento|
      elemento.check(tabla) unless elemento.is_a?(TkString)
    end
  end
  #@final = self.elementos.final
end

class Condicional_Else
  def check(tabla)
    self.condicion.check(tabla)
    if Rangex::Bool != self.condicion.type then
        raise NoEsBool::new self.condicion.nombre if self.condicion.instance_of?(Variable)
        raise NoEsBool::new self.condicion.valor  if (self.condicion.instance_of?(True) or self.condicion.instance_of?(False))
    end

    self.verdadero.check(tabla)
    self.falso.check(tabla)
    @final = self.falso.final
  end
end

class Condicional_If
  def check(tabla)
    self.condicion.check(tabla)
    if Rangex::Bool != self.condicion.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condicion de la iteracion es de tipo \"#{self.condicion.type}\""
    end

    self.verdadero.check(tabla)
    @final = self.verdadero.final
  end
end

class Case
  def check(tabla)
    self.exp.check(tabla)
    if Rangex::Int != self.exp.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la expresión del case es de tipo \"#{self.condicion.type}\""
    end

    self.casos.each do |caso|
      caso.check(tabla) unless caso.is_a?(TkString)
    end
  end
end

class Iteracion_Det
  def check(tabla)
    self.rango.check(tabla)
    if Rangex::Range != self.rango.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango de la iteración es de tipo \"#{self.condicion.type}\""
    end
    tabla2 = SymTable::new(tabla).insert(self.variable, Rangex::Int, false)
    self.instruccion.check(tabla2)
    @final = self.instruccion.final
  end
end

class Iteracion_Indet
  def check(tabla)
    self.condicion.check(tabla)
    if Rangex::Bool != self.condicion.type then
      @type = Rangex::TypeError
      raise "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condicion de la iteración es de tipo \"#{self.condicion.type}\""
    end

    self.instruccion.check(tabla)
    @final = self.instruccion.final
  end
end
