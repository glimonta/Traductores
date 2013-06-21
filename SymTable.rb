class SymTable
  def initialize(padre = nil)
    @padre = padre
    @tabla = {}
    @nombres = []
  end

  def insert(nombre, tipo, es_mutable = true)
    raise "BU!" if @tabla.has_key?(nombre)
    @tabla[nombre] = { :tipo => tipo, :es_mutable => es_mutable }
    @nombres << nombre
    self
  end

  def delete(nombre)
    raise "BUBU!" unless @tabla.has_key?(nombre)
    @tabla.delete(nombre)
    @nombres.delete(nombre)
    self
  end

  def update(nombre, tipo, es_mutable)
    raise "BUBUBU!" unless @tabla.has_key?(nombre)
    @tabla[nombre] = { :tipo => tipo, :es_mutable => es_mutable }
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
