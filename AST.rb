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

    def method_missing(nombre, *argumentos)
      par = @hijos.map {|nombre, contenido| [nombre.sub(/\A[.-]/, ''), contenido] }.assoc(nombre.gsub(/_/, ' '))
      if par.nil? then
        raise NoMethodError::new("undefined method `#{nombre}' for #{self.name}")
      else
        par[1]
      end
    end
  end

  # Se le asigna el nombre a la clase
  Object::const_set nombre, clase
end

# A continuación generamos todas las clases necesarias para cubrir el lenguaje.
generaClase(Object, 'AST', [])
  generaClase(AST, 'Declaracion'  , ['variables', 'tipo'])
  generaClase(AST, 'Declaraciones', ['declaraciones'])
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
    generaClase(Instruccion, 'Bloque'          , ['.declaraciones', '-instrucciones']) #TODO hay que arreglar lo del . y el - para el method_missing
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
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho
    raise "Los tipos de las variables no son enteros" unless Rangex::Int == self.operando_derecho
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
      else raise "Error en el por. Las variables no son ambas enteras, o no es un entero y un rango"
    end
  end
end

class Mas
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = self.operando_izquierdo.type
  end
end

class Resta
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros" unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Int
  end
end

class Construccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros" unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Range
  end
end

class Division
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros" unless Rangex::Int == self.operando_derecho.type
    @type = Rangex::Int
  end
end

class Desigual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Menor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Menor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Interseccion
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son rangos" unless Rangex::Range == self.operando_derecho.type
    @type = Rangex::Range
  end
end

class Igual
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Mayor_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Mayor_Igual_Que
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son enteros o rangos" unless [Rangex::Int, Rangex::Range].include?(self.operando_derecho.type)
    @type = Rangex::Bool
  end
end

class Pertenece
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    raise "La variable izquierda no es un entero" unless Rangex::Int == self.operando_izquierdo.type
    self.operando_derecho.check(tabla)
    raise "La variable derecha no es un rango" unless Rangex::Range == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class And
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son booleanos" unless Rangex::Bool == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class Or
  def check(tabla)
    self.operando_izquierdo.check(tabla)
    self.operando_derecho.check(tabla)
    raise "Los tipos de las variables no concuerdan" unless self.operando_izquierdo.type == self.operando_derecho.type
    raise "Los tipos de las variables no son booleanos" unless Rangex::Bool == self.operando_derecho.type
    @type = Rangex::Bool
  end
end

class Not
  def check(tabla)
    self.operando.check(tabla)
    raise "El tipo de la variable no es booleano" unless Rangex::Bool == self.operando.type
    @type = Rangex::Bool
  end
end

class Menos_Unario
  def check(tabla)
    self.operando.check(tabla)
    raise "El tipo de la variable no es entero" unless Rangex::Int == self.operando.type
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
    variable = tabla.find(self.nombre)
    if variable.is_nil? then
      raise "La variable no está declarada"
    else
      @type = variable[tipo]
  end
end

class Funcion_Bottom
  def check(tabla)
    self.argumento.check(tabla)
    raise "El tipo de la variable no es un rango" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Length
  def check(tabla)
    self.argumento.check(tabla)
    raise "El tipo de la variable no es un rango" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion_Length
  def check(tabla)
    self.argumento.check(tabla)
    raise "El tipo de la variable no es un rango" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Funcion
  def check(tabla)
    self.argumento.check(tabla)
    raise "El tipo de la variable no es un rango" unless Rangex::Range == self.argumento.type
    @type = Rangex::Int
  end
end

class Asignacion
  def check(tabla)
    variable = tabla.find(self.var)
    raise "Se modifica una variable no mutable" unless variable[es_mutable]

    self.expresion.check(tabla)
    raise "El tipo de la variable no concuerda" unless variable[tipo] == self.expresion.type
  end
end

class Bloque
  def check(tabla)
    tabla2 = self.declaraciones.inject(SymTable::new(tabla)) do |acum, declaracion|
      declaracion.variables.inject(acum) do |acum2, variable|
        acum2.insert(variable, declaracion.tipo)
      end
    end

    self.instrucciones.each do |instruccion|
      instruccion.check(tabla2)
    end
  end
end

class Read
  def check(tabla)
    variable = tabla.find(self.variable)
    raise "Se modifica una variable no mutable" unless variable[es_mutable]
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
    raise "El tipo de expresion no es booleano" unless Rangex::Bool == self.condicion.type

    self.verdadero.check(tabla)
    self.falso.check(tabla)
  end
end

class Condicional_If
  def check(tabla)
    self.condicion.check(tabla)
    raise "El tipo de expresion no es booleano" unless Rangex::Bool == self.condicion.type

    self.verdadero.check(tabla)
  end
end

class Case
  def check(tabla)
    self.exp.check(tabla)
    raise "El tipo de expresion no es un entero" unless Rangex::Int == self.condicion.type

    self.casos.each do |caso|
      caso.check(tabla) unless caso.is_a?(TkString)
    end
  end
end

class Iteracion_Det
  def check(tabla)
    self.rango.check(tabla)
    raise "El tipo del rango no es range" unless Rangex::Range == self.rango.type
    tabla2 = tabla::new(tabla).insert(self.variable, Rangex::Int, false)
    self.instruccion.check(tabla2)
  end
end

class Iteracion_Indet
  def check(tabla)
    self.condicion.check(tabla)
    raise "El tipo de expresion no es booleano" unless Rangex::Bool == self.condicion.type

    self.instruccion.check(tabla)
  end
end

end
