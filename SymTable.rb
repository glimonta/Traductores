class RedefinirError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error en línea #{@token.linea}, columna #{@token.columna}: no se puede usar la variable '#{@token.texto}' ya ha sido declarada."
  end
end

class UpdateError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error no se puede actualizar el token '#{@token.texto}'"
  end
end

class DeleteError < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error no se puede eliminar el token '#{@token.texto}'"
  end
end


class SymTable
  def initialize(padre = nil)
    @padre = padre
    @tabla = {}
    @nombres = []
  end

  def insert(token, tipo, es_mutable = true)
    raise RedefinirError::new token if @tabla.has_key?(token.texto)
    @tabla[token.texto] = { :tipo => tipo, :es_mutable => es_mutable, :token => token }
    @nombres << token.texto
    self
  end

  def delete(nombre)
    raise DeleteError::new token unless @tabla.has_key?(nombre)
    @tabla.delete(nombre)
    @nombres.delete(nombre)
    self
  end

  def update(token, tipo, es_mutable)
    raise UpdateError::new token unless @tabla.has_key?(token.texto)
    @tabla[token.texto] = { :tipo => tipo, :es_mutable => es_mutable, :token => token }
    self
  end

  def isMember?(nombre) #Preguntar si podemos usar el '?' :) o cambiar los nombres de los metodos en general
    @tabla.has_key?(nombre)
  end

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
