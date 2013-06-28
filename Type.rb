module Rangex
  class Type
    def ==(otro)
      otro.class == self.class
    end
  end

  class Int       < Type; end
  class Bool      < Type; end
  class Range     < Type; end
  class TypeError < Type; end
end
