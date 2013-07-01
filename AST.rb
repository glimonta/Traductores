#Gabriela Limonta 10-10385
#John Delgado 10-10196
module Rangex; end

require 'Type'
require 'SymTable'
require 'Ubicacion'

class ContextError < RuntimeError
end

class ErrorDeTipo < ContextError
  def initialize(inicio, final, operacion, tipo_izq, tipo_der)
    @inicio = inicio
    @final = final
    @operacion = operacion
    @tipo_izq = tipo_izq
    @tipo_der = tipo_der
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion #{@operacion} entre operandos de tipos \"#{@tipo_izq}\" y \"#{@tipo_der}\""
  end
end

class ErrorDeTipoUnario < ContextError
  def initialize(incio, final, operacion, tipo)
    @inicio = inicio
    @final = final
    @operacion = operacion
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion #{@operacion} a un operando de tipo \"#{@tipo}\""
  end
end

class NoDeclarada < ContextError
  def initialize(inicio, final, nombre)
    @inicio = inicio
    @final = final
    @nombre = nombre
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la variable \"#{@nombre}\" no se encuentra declarada"
  end
end

class ErrorDeTipoFuncion < ContextError
  def initialize(inicio, final, nombre_funcion,tipo)
    @inicio = inicio
    @final = final
    @nombre_funcion = nombre_funcion
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la #{@nombre_funcion} es de tipo \"#{@tipo}\" y se esperaba tipo \"Range\""
  end
end

class ErrorModificarIteracion < ContextError
  def initialize(inicio, final, nombre)
    @inicio = inicio
    @final = final
    @nombre = nombre
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta modificar la variable \"#{@nombre}\" que pertenece a una iteración"
  end
end

class ErrorDeTipoAsignacion < ContextError
  def initialize(inicio, final, tipo_asig, nombre, tipo_var)
    @inicio = inicio
    @final = final
    @tipo_asig = tipo_asig
    @nombre = nombre
    @tipo_var = tipo_var
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta asignar algo del tipo \"#{@tipo_asig}\" a la variable \"#{@nombre}\" de tipo \"#{@tipo_var}\""
  end
end

class ErrorCondicionCondicional < ContextError
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condición es de tipo \"#{@tipo}\""
  end
end

class ErrorExpresionCase < ContextError
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la expresión del case es de tipo \"#{@tipo}\""
  end
end

class ErrorRangoIteracion < ContextError
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango de la iteración es de tipo \"#{@tipo}\""
  end
end

class ErrorCondicionIteracion < ContextError
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condición de la iteración es de tipo \"#{@tipo}\""
  end
end

class ErrorRangoCaso < ContextError
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango del caso es del tipo \"#{@tipo}\" en vez de range"
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

  class << self
    attr_accessor :tipos_correctos
  end

  def check_types(clase_error = ErrorDeTipo)
    tiposHijos = @hijos.reject {|_, hijo| !(hijo.is_a? Expresion)}.map {|_, hijo| hijo.type}
    @type = self.class.tipos_correctos[tiposHijos]
    if @type.nil? then
      @type = Rangex::TypeError
      unless tiposHijos.include?(Rangex::TypeError) then
        $ErroresContexto << clase_error::new(inicio, final, self.class.name.gsub(/_/,' '), *tiposHijos)
      end
    end
  end
end

class Modulo
  @tipos_correctos = { [Rangex::Int, Rangex::Int] => Rangex::Int }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_type
  end
end

class Caso
  def check(tabla)
    self.rango.check(tabla)
    if Rangex::Range != self.rango.type then
      @type = Rangex::TypeError
      $ErroresContexto << ErrorRangoCaso::new(@inicio, @final, self.rango.type)
    end
    @inicio = self.rango.inicio
    self.instruccion.check(tabla)
  end
end

class Por
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int] => Rangex::Int  ,
    [Rangex::Range, Rangex::Int] => Rangex::Range
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Mas
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Int  ,
    [Rangex::Range, Rangex::Range] => Rangex::Range
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Resta
  @tipos_correctos = { [Rangex::Int, Rangex::Int] => Rangex::Int }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Construccion
  @tipos_correctos = { [Rangex::Int, Rangex::Int] => Rangex::Range }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Division
  @tipos_correctos = { [Rangex::Int, Rangex::Int] => Rangex::Int }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Desigual
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool,
    [Rangex::Bool , Rangex::Bool ] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Menor_Que
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Menor_Igual_Que
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Interseccion
  @tipos_correctos = { [Rangex::Range, Rangex::Range] => Rangex::Bool }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Igual
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool,
    [Rangex::Bool , Rangex::Bool ] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Mayor_Que
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Mayor_Igual_Que
  @tipos_correctos = {
    [Rangex::Int  , Rangex::Int  ] => Rangex::Bool,
    [Rangex::Range, Rangex::Range] => Rangex::Bool
  }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Pertenece
  @tipos_correctos = { [Rangex::Int, Rangex::Range] => Rangex::Bool }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class And
  @tipos_correctos = { [Rangex::Bool, Rangex::Bool] => Rangex::Bool }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Or
  @tipos_correctos = { [Rangex::Bool, Rangex::Bool] => Rangex::Bool }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end
end

class Not
  @tipos_correctos = { [Rangex::Bool] => Rangex::Bool }

  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando.final
    check_types(ErrorDeTipoUnario)
  end
end

class Menos_Unario
  @tipos_correctos = { [Rangex::Int] => Rangex::Int }

  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando_derecho.final
    check_types(ErrorDeTipoUnario)
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
    begin
      variable = tabla.find(self.nombre.texto)
    rescue RedefinirError => r
      $ErroresContexto << r
    end

    if variable.nil? then
      @type = Rangex::TypeError
      $ErroresContexto << NoDeclarada::new(@inicio, @final, self.nombre.texto)
    else
      @type = variable[:tipo]
    end
  end
end

class Funcion_Bottom
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end
end

class Funcion_Length
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end
end

class Funcion_Top
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end
end

class Funcion_Rtoi
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end
end

class Asignacion
  def check(tabla)
    begin
      variable = tabla.find(self.var.texto)

      if variable.nil? then
        $ErroresContexto << NoDeclarada::new(@inicio, @final, self.var.texto)
      else
        unless variable[:es_mutable] then
          $ErroresContexto << ErrorModificarIteracion::new(@inicio, @final, self.var.texto)
        end
      end
    rescue RedefinirError => r
      $ErroresContexto << r
    end

    self.expresion.check(tabla)
    @final = self.expresion.final
    unless [variable[:tipo], Rangex::TypeError].include?(self.expresion.type) then
      $ErroresContexto << ErrorDeTipoAsignacion::new(@inicio, @final, self.expresion.type, self.var.texto, variable[:tipo])
    end
  end
end

class Bloque
  def check(tabla)
    begin
      tabla2 = self.declaraciones.inject(SymTable::new(tabla)) do |acum, declaracion|
        declaracion.variables.inject(acum) do |acum2, variable|
          acum2.insert(variable, declaracion.tipo.to_type)
        end
      end

      self.instrucciones.each do |instruccion|
        instruccion.check(tabla2)
      end
    rescue RedefinirError => r
      $ErroresContexto << r
    end
  end
end

class Read
  def check(tabla)
    begin
      variable = tabla.find(self.variable.texto)
    rescue RedefinirError => r
      $ErroresContexto << r
    end

    if variable.nil? then
      $ErroresContexto << NoDeclarada::new(@inicio, @final, self.var.texto)
    end
    unless variable[:es_mutable]
      $ErroresContexto << ErrorModificarIteracion::new(@inicio, @final, self.var.texto)
    end
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
  @final = self.elementos.final
  end
end

class Condicional_Else
  def check(tabla)
    self.condicion.check(tabla)
    unless [Rangex::Bool, Rangex::TypeError].include?(self.condicion.type) then
      $ErroresContexto << ErrorCondicionCondicional::new(@inicio, @final, self.condicion.type)
    end

    self.verdadero.check(tabla)
    self.falso.check(tabla)
    @final = self.falso.final
  end
end

class Condicional_If
  def check(tabla)
    self.condicion.check(tabla)
    unless [Rangex::Bool, Rangex::TypeError].include?(self.condicion.type) then
      $ErroresContexto << ErrorCondicionCondicional::new(@inicio, @final, self.condicion.type)
    end

    self.verdadero.check(tabla)
    @final = self.verdadero.final
  end
end

class Case
  def check(tabla)
    self.exp.check(tabla)
    unless [Rangex::Int, Rangex::TypeError].include?(self.exp.type) then
      $ErroresContexto << ErrorExpresionCase::new(@inicio, @final, self.exp.type)
    end

    self.casos.each do |caso|
      caso.check(tabla) unless caso.is_a?(TkString)
    end
  end
end

class Iteracion_Det
  def check(tabla)
    self.rango.check(tabla)
    unless [Rangex::Range, Rangex::TypeError].include?(self.rango.type) then
      $ErroresContexto << ErrorRangoIteracion::new(@inicio, @final, self.rango.type)
    end
    tabla2 = SymTable::new(tabla).insert(self.variable, Rangex::Int, false)

    self.instruccion.check(tabla2)
    @final = self.instruccion.final
  end
end

class Iteracion_Indet
  def check(tabla)
    self.condicion.check(tabla)
    unless [Rangex::Bool, Rangex::TypeError].include?(self.condicion.type) then
      $ErroresContexto << ErrorCondicionIteracion::new(@inicio, @final, self.condicion.type)
    end

    self.instruccion.check(tabla)
    @final = self.instruccion.final
  end
end
