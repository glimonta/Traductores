#Gabriela Limonta 10-10385
#John Delgado 10-10196

# Un objeto de texto es una generalización de un fragmento textual en una posición
# determinada de un texto. Instancias de esta idea son los errores lexicográficos y los tokens.
class ObjetoDeTexto
  attr_accessor :linea, :columna, :texto
end

# Un error lexicográfico es un objeto que guarda la posición de un error en un contexto
# del programa
class ErrorLexicografico < ObjetoDeTexto
  # Se encarga de inicializar un error lexicografico indicandole
  # en que posicion está y por que texto está conformado
  def initialize(linea, columna, texto)
    @linea   = linea
    @columna = columna
    @texto   = texto
  end

  # Se encarga de pasar el error lexicográfico a string para imprimir
  # en pantalla.
  def to_s
    "Error: caracter inesperado \"#{@texto}\" en línea #{@linea}, columna #{@columna}."
  end
end

# La clase token es un objeto de texto que ademas de tener un contexto
# tiene una expresión regular que permite identificar al token dentro
# del contexto mayor
class Token < ObjetoDeTexto
  # Queremos que el campo regex sera una variable de la clase y no de cada subclase
  # en particular de Token por lo que declaramos regex en la clase singleton de Token
  class << self #Clase singleton
    attr_accessor :regex
  end

  attr_accessor :linea, :columna
end

# Se define un diccionario que contiene las expresiones regulares para cada
# token existente.
tokens = {
  'AbreParentesis'    => /\A\(/                      ,
  'CierraParentesis'  => /\A\)/                      ,
  'Coma'              => /\A,/                       ,
  'Desigual'          => /\A\/=/                     ,
  'Division'          => /\A\/(?!=)/                 ,
  'DosPuntos'         => /\A\.\./                    ,
  'Flecha'            => /\A->/                      ,
  'Id'                => /\A([a-zA-Z_][a-z0-9A-Z_]*)/,
  'Igual'             => /\A==/                      ,
  'Interseccion'      => /\A<>/                      ,
  'MayorIgualQue'     => /\A>=/                      ,
  'MayorQue'          => /\A>(?![=>])/               ,
  'MenorIgualQue'     => /\A<=/                      ,
  'MenorQue'          => /\A<(?!=)/                  ,
  'Modulo'            => /\A%/                       ,
  'Multiplicacion'    => /\A\*/                      ,
  'Num'               => /\A[0-9]+/                  ,
  'Pertenece'         => /\A>>/                      ,
  'PuntoYComa'        => /\A;/                       ,
  'Resta'             => /\A-(?!>)/                  ,
  'String'            => /\A"([^"\\]|\\[n\\"])*"/    ,
  'Suma'              => /\A\+/                      ,
  'Asignacion'        => /\A=/                       ,
}

# Se definen las palabras reservadas.
reserved_words = %w(and as begin bool bottom case declare do else end false for if in int length not of or program range read rtoi then top true while write writeln)

# Guardamos aqui dentro del diccionario de tokens las expresiones para las palabras reservadas.
reserved_words.each do |w|
  tokens[w.capitalize] = /\A#{w}\b/
end

# Para cada token vamos creando las nuevas subclases para cada token.
tokens.each do |name, regex|
  clase = Class::new(Token) do
    #Asignamos la expresion regular
    @regex = regex

    # Se encarga de inicializar el token en el contexto.
    def initialize(linea, columna, texto)
      @linea   = linea
      @columna = columna
      @texto   = texto
    end
  end

  # Le damos nombre a la nueva sub clase creada
  Object::const_set "Tk#{name}", clase
end

# Creamos un arreglo de tokens cuyos elementos del arreglo son las
# subclases para cada token.
$tokens = []
ObjectSpace.each_object(Class) do |o|
  $tokens << o if o.ancestors.include? Token and o != TkId and o != Token
end

class Token
  def text
    ''
  end

  # Se encarga de pasar el token a string para que imprima por pantalla.
  def to_s
    "#{self.class.name} #{text}(Línea #{@linea}, Columna #{@columna})"
  end

  def to_string(profundidad)
    @texto
  end
end

class TkString
  def text
    @texto + ' '
  end
end

class TkId
  def text
    @texto.inspect + ' '
  end
end

class TkNum
  def text
    @texto.inspect + ' '
  end
end

class Array
  def to_string(profundidad)
    inject('') do |acum, objeto|
      acum + '  '*profundidad + '- ' objeto.to_string(profundidad.succ) + "\n" 
    end
  end
end
