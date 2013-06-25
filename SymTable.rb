#Gabriela Limonta 10-10385
#John Delgado 10-10196

#Se definen los posibles errores que se pueden reportar desde la tabla de simbolos, con sus respectivos constructores y sus procedimiento
#to_s requerido para imprimir el error

#Error que permite ver al usuario que se trato de redefinir un simbolo en la tabla de simbolos cuando esto no es posible
class RedefinirError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error en línea #{@token.linea}, columna #{@token.columna}: no se puede usar la variable '#{@token.texto}' ya ha sido declarada."
  end
end

#Error que permite notificar al usuario sobre que no se pudo actualizar un simbolo en la tabla de simbolos
class UpdateError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error no se puede actualizar el token '#{@token.texto}'"
  end
end

#Este error permite al usuario saber que no se pudo eliminar el simbolo de la tabla de simbolos
class DeleteError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error no se puede eliminar el token '#{@token.texto}'"
  end
end


#Se define la tabla de simbolos que se utiliza para el proyecto Rangex

class SymTable
  #construcor de la tabla de simbolos
  def initialize(padre = nil)
    @padre = padre
    @tabla = {}
    @nombres = []
  end

  #metodo que permite insertar un simbolo a la tabla de simbolos, no se pueden redefinir simbolos al momento de
  #hacer una insercion por esto se chequea esta caracteristica primero
  def insert(token, tipo, es_mutable = true)
    raise RedefinirError::new token if @tabla.has_key?(token.texto)
    @tabla[token.texto] = { :tipo => tipo, :es_mutable => es_mutable, :token => token }
    @nombres << token.texto
    self
  end

  #metodo que permite eliminar un simbolo de la tabla de simbolos, si este simbolo no se encuentra entonces se levanta una
  #excepcion
  def delete(nombre)
    raise DeleteError::new token unless @tabla.has_key?(nombre)
    @tabla.delete(nombre)
    @nombres.delete(nombre)
    self
  end


  #metodo que permite actualizar un simbolo ya existente en la tabla de simbolos, si el simbolo no esta en la tabla
  #se procede a levantar una excepcion
  def update(token, tipo, es_mutable)
    raise UpdateError::new token unless @tabla.has_key?(token.texto)
    @tabla[token.texto] = { :tipo => tipo, :es_mutable => es_mutable, :token => token }
    self
  end

  #Este metodo permite saber si en la tabla de simbolos el simbolo es miembro de ella con el nombre que se le pasa
  def isMember?(nombre)
    @tabla.has_key?(nombre)
  end

  #Metodo permite saber si el simbolo esta presente en la tabla pasandole al mismo el nombre
  def find(nombre)
    if @tabla.has_key?(nombre) then
      @tabla[nombre]
    elsif @padre.nil? then
      nil
    else
      @padre.find(nombre)
    end
  end
end
