#Gabriela Limonta 10-10385
#John Delgado 10-10196

#Modulo que define las clases de los posibles tipos basicos que
#existen en Rangex
module Rangex
  class Type
    def ==(otro)
      otro.class == self.class
    end
  end

#Las tres posibles clases son int, Bool, Range
  class Int   < Type; end
  class Bool  < Type; end
  class Range < Type; end
  class TypeError < Type; end
end
