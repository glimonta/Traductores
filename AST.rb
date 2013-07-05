#Gabriela Limonta 10-10385
#John Delgado 10-10196
module Rangex; end

require 'Type'
require 'SymTable'
require 'Ubicacion'

# Se crea una nueva clase que engloba a todos los errores de contexto
class ContextError < RuntimeError
end

# Se crea un error de tipo para cuando los tipos de una operación no son adecuados, con su to_s correspondiente para ser impreso en pantalla.
class ErrorDeTipo < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final, la operación donde ocurrió el error
  # y los tipos que habían en el operando izquierdo y derecho.
  def initialize(inicio, final, operacion, tipo_izq, tipo_der)
    @inicio = inicio
    @final = final
    @operacion = operacion
    @tipo_izq = tipo_izq
    @tipo_der = tipo_der
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error (línea y columna de inicio y final), la operación y los tipos.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion #{@operacion} entre operandos de tipos \"#{@tipo_izq}\" y \"#{@tipo_der}\""
  end
end

# Se crea un error de tipo unario para cuando el tipo de una operación unaria no es adecuado, con su to_s correspondiente para ser impreso en pantalla.
class ErrorDeTipoUnario < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final, la operación donde ocurrió el error
  # y el tipo que habia en el operando.
  def initialize(incio, final, operacion, tipo)
    @inicio = inicio
    @final = final
    @operacion = operacion
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error (línea y columna de inicio y final), la operación y el tipo del operando.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: se intenta hacer la operacion #{@operacion} a un operando de tipo \"#{@tipo}\""
  end
end

# Se crea un error de no declaración de variable para cuando se intenta utilizar una variable que no ha sido declarada anteriormente.
class NoDeclarada < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el nombre de la variable que no fue declarada.
  def initialize(inicio, final, nombre)
    @inicio = inicio
    @final = final
    @nombre = nombre
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error (línea y columna de inicio y final) y el nombre de la variable que no fue declarada.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: la variable \"#{@nombre}\" no se encuentra declarada"
  end
end

# Se crea un error de tipo para las funciones, se utiliza cuando se le pasa un operando con tipo incorrecto a alguna de las funciones del lenguaje.
class ErrorDeTipoFuncion < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final, el nombre de la función y el tipo del operando
  def initialize(inicio, final, nombre_funcion,tipo)
    @inicio = inicio
    @final = final
    @nombre_funcion = nombre_funcion
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error (línea y columna de inicio y final), el nombre de la función, el tipo recibido y el tipo esperado.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el argumento de la #{@nombre_funcion} es de tipo \"#{@tipo}\" y se esperaba tipo \"Range\""
  end
end

# Se crea un error para cuando se intenta modificar la variable de un for.
class ErrorModificarIteracion < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el nombre de la variable que se intentó modificar.
  def initialize(inicio, final, nombre)
    @inicio = inicio
    @final = final
    @nombre = nombre
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el nombre de la variable que se intenta modificar.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta modificar la variable \"#{@nombre}\" que pertenece a una iteración"
  end
end

# Se crea un error para cuando se intenta hacer una asignación entre una variable y una expresión de tipos distintos.
class ErrorDeTipoAsignacion < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final, el tipo de la expresión, el nombre de la variable y el tipo de la variable.
  def initialize(inicio, final, tipo_asig, nombre, tipo_var)
    @inicio = inicio
    @final = final
    @tipo_asig = tipo_asig
    @nombre = nombre
    @tipo_var = tipo_var
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final), el tipo de la expresión, el nombre de la variable y el tipo de la misma.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: se intenta asignar algo del tipo \"#{@tipo_asig}\" a la variable \"#{@nombre}\" de tipo \"#{@tipo_var}\""
  end
end

# Se crea un error para cuando la condicion de un condicional es de tipo distinto a booleano.
class ErrorCondicionCondicional < ContextError
  def initialize(inicio, final, tipo)
  # Se encarga de inicializar con la ubicación de inicio y final y el tipo de la condición.
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el tipo de la condición.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condición es de tipo \"#{@tipo}\""
  end
end

# Se crea un error para cuando la expresión de un case es de un tipo no adecuado.
class ErrorExpresionCase < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el tipo de la expresión.
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el tipo de la expresión.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la expresión del case es de tipo \"#{@tipo}\""
  end
end

# Se crea un error para cuando el rango de una iteración es de un tipo diferente a range.
class ErrorRangoIteracion < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el tipo del rango.
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el tipo del rango.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango de la iteración es de tipo \"#{@tipo}\""
  end
end

# Se crea un error para cuando la condición de la iteración es diferente de bool.
class ErrorCondicionIteracion < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el tipo de la condición.
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el tipo de la condición.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: la condición de la iteración es de tipo \"#{@tipo}\""
  end
end

# Se crea un error para cuando el rango de un caso es de un tipo diferente a range.
class ErrorRangoCaso < ContextError
  # Se encarga de inicializar con la ubicación de inicio y final y el tipo del rango.
  def initialize(inicio, final, tipo)
    @inicio = inicio
    @final = final
    @tipo = tipo
  end

  # Se define el to_s correspondiente que imprime le rango donde ocurre el error (línea y columna de inicio y final) y el tipo del rango.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la linea #{@final.linea}, columna #{@final.columna}: el rango del caso es del tipo \"#{@tipo}\" en vez de range"
  end
end

# Se crea una clase para englobar a todos los errores que puedan ocurrir en la verificación dinámica.
class DynamicError < RuntimeError
end

# Se crea una clase para los errores de overflow que puedan existir en la verificación dinámica.
class ErrorOverflow < DynamicError
  # Se inicializa con la ubicación de inicio y final.
  def initialize(inicio, final)
    @incio = inicio
    @final = final
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y un mensaje informativo.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: El resultado no puede representarse en 32 bits"
  end
end

# Se crea una clase para cuando existe un rango inválido en el programa.
class RangoInvalido < DynamicError
  # Se inicializa con la ubicación de inicio y final.
  def initialize(inicio, final)
    @inicio = inicio
    @final = final
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y un mensaje informativo.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: El rango es inválido."
  end
end

# Se crea una clase para cuando existe un error de división entre cero.
class DivisionCero < DynamicError
  # Se inicializa con la ubicación de inicio y final.
  def initialize(inicio, final)
    @inicio = inicio
    @final = final
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y un mensaje informativo.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: Intento de división entre cero."
  end
end

# Se crea una clase para cuando existe un rango vacio en el programa.
class RangoVacio < DynamicError
  # Se inicializa con la ubicación de inicio y final.
  def initialize(inicio, final)
    @inicio = inicio
    @final = final
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y un mensaje informativo.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: El rango es vacio."
  end
end

# Se crea una clase de error para cuando una variable no se encuentra inicializada.
class NoInicializada < DynamicError
  # Se inicializa con la ubicación de inicio y final y el nombre de la variable.
  def initialize(inicio, final, nombre)
    @inicio = inicio
    @final = final
    @nombre = nombre
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y el nombre de la variable que no ha sido inicializada.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: La variable \"#{@nombre}\" no ha sido inicializada."
  end
end

# Se crea una clase de error para cuando el rango de la función rtoi tiene mas de un elemento.
class RangoRtoi < DynamicError
  # Se inicializa con la ubicación de inicio y final.
  def initialize(inicio, final)
    @inicio = inicio
    @final = final
  end

  # Se define el to_s correspondiente que imprime el rango donde ocurre el error y un mensaje informativo.
  def to_s
    "Error entre la línea #{@inicio.linea}, columna #{@inicio.columna} y la línea #{@final.linea}, columna #{@final.columna}: El rango de la función rtoi tiene mas de un elemento."
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
    generaClase(Expresion, 'Por'            , ['operando izquierdo', 'operando derecho'])
    generaClase(Expresion, 'Mas'            , ['operando izquierdo', 'operando derecho'])
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
    generaClase(Instruccion, 'Bloque'          , ['declaraciones', '-instrucciones'])
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

  # Se encarga de la verificación estática del programa.
  def check
    # Llama al check de la instrucción del programa con una tabla de símbolos vacia.
    self.instruccion.check(SymTable::new)
    # Asigna la ubicación final al objeto de la clase.
    @final = self.instruccion.final
  end

  # Se encarga de la verificación dinámica del programa.
  def run
    # Llama al run de la instrucción del programa con una tabla de símbolos nueva.
    self.instruccion.run(SymTable::new)
  end
end

# Se modifica la clase Expresión para agregar nuevas cosas.
class Expresion
  # Se agrega un type que permite saber el tipo de la expresión.
  attr_reader :type

  # Se agrega en la clase singleton un atributo llamado tipos_correctos que almacena en forma de diccionario
  # las combinaciones de tipos correctas que puede recibir una expresión.
  class << self
    attr_accessor :tipos_correctos
  end

  # Se encarga de chequear los tipos de la expresión evaluada y toma como parametro la clase de error que va a
  # utilizar para crear un nuevo error en caso de haberlo, agrega un error a la lista de errores de contexto si hay,
  # en efecto, un error de tipos y asigna el tipo de la expresión a TypeError. Si la expresión tiene tipos correctos,
  # se asigna el tipo resultante.
  def check_types(clase_error = ErrorDeTipo)
    # Se guarda en la variable tiposHijos todos los tipos de los hijos de la clase que sean del tipo expresión.
    tiposHijos = @hijos.reject {|_, hijo| !(hijo.is_a? Expresion)}.map {|_, hijo| hijo.type}

    # Se almacena en type el tipo resultante de utilizar, en los operadores, los tipos encontrados en los hijos de la clase.
    @type = self.class.tipos_correctos[tiposHijos]
    # Si type da nil es porque la combinación de hijos no se encuentra en el diccionario de tipos correctos y por ende hay un error de tipo.
    if @type.nil? then
      # Se asigna TypeError al tipo.
      @type = Rangex::TypeError
      # Se crea un nuevo error de contexto solamente si alguno de los operandos no era de tipo TypeError antes. Esto es para evitar
      # replicar los errores y agregar errores de contexto de mas.
      unless tiposHijos.include?(Rangex::TypeError) then
        $ErroresContexto << clase_error::new(inicio, final, self.class.name.gsub(/_/,' '), *tiposHijos)
      end
    end
  end

  # Se encarga de detectar si existe overflow en una operación. Toma como parametro el resultado de la operación e indica si existe overflow en la misma.
  def detectar_overflow(resultado)
    # Se levanta una excepcion si existe overflow en el resultado y sino se devuelve el resultado.
    raise ErrorOverflow::new(@inicio, @final) if (resultado > 2**31 - 1 or resultado < -2**31)
    resultado
  end
end

# Se modifica la clase Modulo para agregar nuevos metodos.
class Modulo
  # Se indican los tipos correctos que acepta esta expresión.
  @tipos_correctos = { [Rangex::Int, Rangex::Int] => Rangex::Int }

  # Se encarga de la verificación estática del programa.
  def check(tabla)
    # Llama al check del operando izquierdo y asigna la ubicación de inicio de la expresión.
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    # Llama al check del operando derecho y asigna la ubicación final de la expresión.
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    # Por ultimo se llama a check_types para revisar que los tipos de los operandos sean correctos
    check_types
  end

  # Se encarga de la verificacion dinamica del programa.
  def run(tabla)
    # Se hace la operación de modulo y se llama a detectar overflow.
    detectar_overflow(self.operando_izquierdo.run(tabla) % self.operando_derecho.run(tabla))
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

  def run(tabla, expresion)
    if expresion >= self.rango.run(tabla)[0] and expresion <= self.rango.run(tabla)[1] then
      self.instruccion.run(tabla)
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      detectar_overflow(self.operando_izquierdo.run(tabla) * self.operando_derecho.run(tabla))
    else
      unless self.operando_derecho.run(tabla) < 0 then
        cota_inf = detectar_overflow(self.operando_izquierdo.run(tabla)[0] * self.operando_derecho.run(tabla))
        cota_sup = detectar_overflow(self.operando_izquierdo.run(tabla)[1] * self.operando_derecho.run(tabla))
        [cota_inf, cota_sup]
      else
        cota_inf = detectar_overflow(self.operando_izquierdo.run(tabla)[1] * self.operando_derecho.run(tabla))
        cota_sup = detectar_overflow(self.operando_izquierdo.run(tabla)[0] * self.operando_derecho.run(tabla))
        [cota_inf, cota_sup]
      end
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      detectar_overflow(self.operando_izquierdo.run(tabla) + self.operando_derecho.run(tabla))
    else
      cota_inf = [self.operando_izquierdo.run(tabla)[0], self.operando_derecho.run(tabla)[0]].min
      cota_sup = [self.operando_izquierdo.run(tabla)[1], self.operando_derecho.run(tabla)[1]].max
      unless cota_inf > cota_sup then
        [cota_inf, cota_sup]
      else
        raise RangoInvalido::new(@inicio, @final)
      end
    end
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

  def run(tabla)
    detectar_overflow(self.operando_izquierdo.run(tabla) - self.operando_derecho.run(tabla))
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

  def run(tabla)
    if self.operando_izquierdo.run(tabla) > self.operando_derecho.run(tabla) then
      raise RangoInvalido::new(@inicio, @final)
    else
      [self.operando_izquierdo.run(tabla), self.operando_derecho.run(tabla)]
    end
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

  def run(tabla)
    unless self.operando_derecho.run(tabla).zero? then
      detectar_overflow(self.operando_izquierdo.run(tabla) / self.operando_derecho.run(tabla))
    else
      raise DivisionCero::new(@inicio, @final)
    end
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

  def run(tabla)
    if Rangex::Range == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla)[0] != self.operando_derecho.run(tabla)[0] and self.operando_izquierdo.run(tabla)[1] != self.operando_derecho.run(tabla)[1]
    else
      self.operando_izquierdo.run(tabla) != self.operando_derecho.run(tabla)
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla) < self.operando_derecho.run(tabla)
    else
      self.operando_izquierdo.run(tabla)[1] < self.operando_derecho.run(tabla)[0]
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla) <= self.operando_derecho.run(tabla)
    else
      self.operando_izquierdo.run(tabla)[1] <= self.operando_derecho.run(tabla)[0]
    end
  end
end

class Interseccion
  @tipos_correctos = { [Rangex::Range, Rangex::Range] => Rangex::Range }

  def check(tabla)
    self.operando_izquierdo.check(tabla)
    @inicio = self.operando_izquierdo.inicio
    self.operando_derecho.check(tabla)
    @final = self.operando_derecho.final
    check_types
  end

  def run(tabla)
    rango_izq = self.operando_izquierdo.run(tabla)
    rango_der = self.operando_derecho.run(tabla)
    cota_inferior = [rango_izq[0], rango_der[0]].max
    cota_superior = [rango_izq[1], rango_der[1]].min

    unless cota_inferior > cota_superior then
      [[rango_izq[0], rango_der[0]].max , [rango_izq[1], rango_der[1]].min]
    else
      raise RangoVacio::new(@inicio, @final)
    end
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

  def run(tabla)
    if Rangex::Range == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla)[0] == self.operando_derecho.run(tabla)[0] and self.operando_izquierdo.run(tabla)[1] == self.operando_derecho.run(tabla)[1]
    else
      self.operando_izquierdo.run(tabla) == self.operando_derecho.run(tabla)
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla) > self.operando_derecho.run(tabla)
    else
      self.operando_izquierdo.run(tabla)[0] > self.operando_derecho.run(tabla)[1]
    end
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

  def run(tabla)
    if Rangex::Int == self.operando_izquierdo.type then
      self.operando_izquierdo.run(tabla) >= self.operando_derecho.run(tabla)
    else
      self.operando_izquierdo.run(tabla)[0] >= self.operando_derecho.run(tabla)[1]
    end
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

  def run(tabla)
    entero = self.operando_izquierdo.run(tabla)
    rango = self.operando_derecho.run(tabla)
    (rango[0] <= entero and entero <= rango[1])
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

  def run(tabla)
    (self.operando_izquierdo.run(tabla) and self.operando_derecho.run(tabla))
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

  def run(tabla)
    (self.operando_izquierdo.run(tabla) or self.operando_derecho.run(tabla))
  end
end

class Not
  @tipos_correctos = { [Rangex::Bool] => Rangex::Bool }

  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando.final
    check_types(ErrorDeTipoUnario)
  end

  def run(tabla)
    (not self.operando.run(tabla))
  end
end

class Menos_Unario
  @tipos_correctos = { [Rangex::Int] => Rangex::Int }

  def check(tabla)
    self.operando.check(tabla)
    @final = self.operando.final
    check_types(ErrorDeTipoUnario)
  end

  def run(tabla)
    detectar_overflow(-self.operando.run(tabla))
  end
end

class Entero
  def check(tabla)
    @type = Rangex::Int
  end

  def run(tabla)
    detectar_overflow(self.valor.texto.to_i)
  end
end

class True
  def check(tabla)
    @type = Rangex::Bool
  end

  def run(tabla)
    true
  end
end

class False
  def check(tabla)
    @type = Rangex::Bool
  end

  def run(tabla)
    false
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

  def run(tabla)
    variable = tabla.find(self.nombre.texto)
    if variable[:valor].nil? then
      raise NoInicializada::new(@inicio, @final, self.nombre.texto)
    else
      variable[:valor]
    end
  end
end

class Funcion_Bottom
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end

  def run(tabla)
    self.argumento.run(tabla)[0]
  end
end

class Funcion_Length
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end

  def run(tabla)
    1 + self.argumento.run(tabla)[1] - self.argumento.run(tabla)[0]
  end
end

class Funcion_Top
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end

  def run(tabla)
    self.argumento.run(tabla)[1]
  end
end

class Funcion_Rtoi
  @tipos_correctos = { [Rangex::Range] => Rangex::Int }

  def check(tabla)
    self.argumento.check(tabla)
    check_types(ErrorDeTipoFuncion)
  end

  def run(tabla)
    if self.argumento.run(tabla)[0] == self.argumento.run(tabla)[1] then
      self.argumento.run(tabla)[0]
    else
      raise RangoRtoi::new(@inicio, @final)
    end
  end
end

class Asignacion
  def check(tabla)
    begin
      variable = tabla.find(self.var.texto)

      self.expresion.check(tabla)
      @final = self.expresion.final

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

    unless variable.nil? or [variable[:tipo], Rangex::TypeError].include?(self.expresion.type) then
      $ErroresContexto << ErrorDeTipoAsignacion::new(@inicio, @final, self.expresion.type, self.var.texto, variable[:tipo])
    end
  end

  def run(tabla)
    variable = tabla.find(self.var.texto)
    variable[:valor] = self.expresion.run(tabla)
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

  def run(tabla)
    tabla2 = self.declaraciones.inject(SymTable::new(tabla)) do |acum, declaracion|
      declaracion.variables.inject(acum) do |acum2, variable|
        acum2.insert(variable, declaracion.tipo.to_type)
      end
    end

    self.instrucciones.each do |instruccion|
      instruccion.run(tabla2)
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

  def run(tabla)
    variable = tabla.find(self.variable.texto)
    entrada = STDIN.gets
    entrada = entrada.gsub(/\s*/, '')
    if Rangex::Bool == variable[:tipo] then
      entrada = entrada.match(/(true, false)/)
        if "true" == entrada[0] then
          variable[:valor] = true
        elsif "false" == entrada[0] then
          variable[:valor] = false
        else
          puts "La variable es de tipo bool y no se leyo ni true ni false"
          run(tabla)
        end
    elsif Rangex::Range == variable[:tipo] then
      entrada = entrada.match(/(-?[0-9]+\.\.-?[0-9]+|-?[0-9]+,-?[0-9]+)/)
        unless entrada.nil? then
          unless entrada[0].include?(',') then
            cota_inf = entrada[0].sub(/\.\.-?[0-9]+/, '').to_i
            cota_sup = entrada[0].sub(/-?[0-9]+\.\./, '').to_i
          else
            cota_inf = entrada[0].sub(/,-?[0-9]+/, '').to_i
            cota_sup = entrada[0].sub(/-?[0-9]+,/, '').to_i
          end
          unless cota_inf > cota_sup then
            variable[:valor] = [cota_inf.to_i, cota_sup.to_i]
          else
            puts "Las cotas ingresadas no son validas"
            run(tabla)
          end
        else
          puts "La variable es de tipo range y no se leyo una expresion valida"
          run(tabla)
        end
    else
      entrada = entrada.match(/-?[0-9]+/)
        unless entrada.nil? then
          variable[:valor] = entrada[0].to_i
        else
          puts "La variable es de tipo int y no se leyo una expresion valida"
          run(tabla)
        end
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

  def run(tabla)
    self.elementos.each do |elemento|
      unless elemento.is_a?(TkString) then
        valor = elemento.run(tabla)
        if valor.is_a?(Array) then
          print "#{valor[0]}..#{valor[1]}"
        else
          print valor
        end
        print ' '
      else
        print elemento.texto.gsub(/"/, '')
        print ' '
      end
    end
  end
end

class Writeln
  def check(tabla)
    self.elementos.each do |elemento|
      elemento.check(tabla) unless elemento.is_a?(TkString)
    end
  @final = self.elementos.final
  end

  def run(tabla)
    self.elementos.each do |elemento|
      unless elemento.is_a?(TkString) then
        valor = elemento.run(tabla)
        if valor.is_a?(Array) then
          print "#{valor[0]}..#{valor[1]}"
        else
          print valor
        end
      else
        print elemento.texto.gsub(/"/, '')
      end
    end
    puts ''
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

  def run(tabla)
    if self.condicion.run(tabla) then
      self.verdadero.run(tabla)
    else
      self.falso.run(tabla)
    end
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

  def run(tabla)
     self.verdadero.run(tabla) if self.condicion.run(tabla)
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

  def run(tabla)
    expresion = self.exp.run(tabla)

    self.casos.each do |caso|
      caso.run(tabla, expresion)
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

  def run(tabla)
    tabla2 = SymTable::new(tabla).insert(self.variable, Rangex::Int, false)
    variable = tabla2.find(self.variable.texto)

    for variable[:valor] in self.rango.run(tabla2)[0]..self.rango.run(tabla2)[1] do
      self.instruccion.run(tabla2)
    end
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

  def run(tabla)
    while self.condicion.run(tabla) do
      self.instruccion.run(tabla)
    end
  end
end
