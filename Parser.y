class Parser
  token '<=' '<>' '<' '==' '=' '>=' '>>' '>' '-' ',' ';' '/=' '..' '(' ')'
        '*' '%' '+' 'and' 'as' 'begin' 'bool' 'bottom' 'case' 'declare' 'do'
        'else' 'end' 'false' 'for' 'id' 'if' 'in' 'int' 'length' 'not' 'num'
        'of' 'or' 'program' 'range' 'read' 'rtoi' 'str' 'then' 'top' 'true'
        'while' 'write' UMINUS

  prechigh
    nonassoc UMINUS
    left     '..'
    left     '*' '/' '%'
    left     '+' '-'
    left     '<>'
    nonassoc '>>'
    left     '==' '/='
    nonassoc '<' '<=' '>=' '>'
    left     'not'
    left     'and'
    left     'or'
  preclow

  convert
    '('       'TkAbreParentesis'
    ')'       'TkCierraParentesis'
    ','       'TkComa'
    '/='      'TkDesigual'
    '/'       'TkDivision'
    '..'      'TkDosPuntos'
    '->'      'TkFlecha'
    'id'      'TkId'
    '=='      'TkIgual'
    '<>'      'TkInterseccion'
    '>='      'TkMayorIgualQue'
    '>'       'TkMayorQue'
    '<='      'TkMenorIgualQue'
    '<'       'TkMenorQue'
    '%'       'TkModulo'
    '*'       'TkMultiplicacion'
    'int'     'TkNum'
    '>>'      'TkPertenece'
    ';'       'TkPuntoYComa'
    '-'       'TkResta'
    'str'     'TkString'
    '+'       'TkSuma'
    '='       'TkAsignacion'
    'and'     'TkAnd'
    'as'      'TkAs'
    'begin'   'TkBegin'
    'bool'    'TkBool'
    'bottom'  'TkBottom'
    'case'    'TkCase'
    'declare' 'TkDeclare'
    'do'      'TkDo'
    'else'    'TkElse'
    'end'     'TkEnd'
    'false'   'TkFalse'
    'for'     'TkFor'
    'if'      'TkIf'
    'in'      'TkIn'
    'int'     'TkInt'
    'length'  'TkLength'
    'not'     'TkNot'
    'of'      'TkOf'
    'or'      'TkOr'
    'program' 'TkProgram'
    'range'   'TkRange'
    'read'    'TkRead'
    'rtoi'    'TkRtoi'
    'then'    'TkThen'
    'top'     'TkTop'
    'true'    'TkTrue'
    'while'   'TkWhile'
    'write'   'TkWrite'
    'writeln' 'TkWriteln'
  end

  start Programa
rule
       Programa: 'program' Instruccion                                 { result = Programa::new(val[1])                           }
               ;
    Instruccion: 'id' '=' Expresion                                    { result = Asignacion::new([val[0], val[2]])               }
               | 'begin' Declaraciones Instrucciones 'end'             { result = Bloque::new([val[1], val[2]])                   }
               | 'read' 'id'                                           { result = Read::new([val[2])                              }
               | 'write' ElementosSalida                               { result = Write::new([val[2])                             }
               | 'if' Expresion 'then' Instruccion 'else' Instruccion  { result = Condicional_Else::new([val[1], val[3], val[5]]) }
               | 'if' Expresion 'then' Instruccion                     { result = Condicional_If::new([val[1], val[3]])           }
               | 'case' Expresion 'of' ElementosSalida                 { result = Case::new([val[1], val[3]])                     }
               | 'for' 'id' 'in' Expresion Instruccion                 { result = Iteracion_Det::new([val[1], val[3], val[4]])    }
               | 'while' Expresion 'do' Instruccion                    { result = Iteracion_Indet::new([val[1], val[3]])          }
               ;
  Declaraciones: 'declare' LDeclaraciones                              { result = Declaracion::new([val[1]])                      }
               ;
 LDeclaraciones: Declaracion                                           { result = [val[0]]                                        }
               | LDeclaraciones ';' Declaracion                        { result = val[0] + [val[2]]                               }
               ;
    Declaracion: Variables 'as' Tipo                                   { result = { :vars => val[0], :tipo => val[2] }            } # NO SE QUE PONER AQUI
               ;
           Tipo: 'num'                                                 { result = :num                                            }
               | 'bool'                                                { result = :bool                                           }
               | 'range'                                               { result = :range                                          }
               ;
      Variables: Variables ',' 'id'                                    { result = val[0] + [val[2]]                               }
               | 'id'                                                  { result = [val[0]]                                        }
               ;
  Instrucciones: Instruccion                                           { result = [val[0]]                                        }
               | Instrucciones ';' Instruccion                         { result = val[0] + [val[2]]                               }
               ;
ElementosSalida: ElementoSalida                                        { result = [val[0]]                                        }
               | ElementosSalida ',' ElementoSalida                    { result = val[0] + [val[2]]                               }
               ;
 ElementoSalida: 'str'                                                 { result = String::new([val[0]])                           }
               | 'id'                                                  { result = Entero::new([val[0]])                           }
               ;
      Expresion: 'int'                                                 { result = Entero::new([val[0]])                           }
               | 'true'                                                { result = True::new([])                                   }
               | 'false'                                               { result = False::new([])                                  }
               | 'id'                                                  { result = Variable::new([val[0]])                         }
               | 'bottom' '(' Expresion ')'                            { result = Funcion_Bottom::new([val[2]])                   }
               | 'length' '(' Expresion ')'                            { result = Funcion_Length::new([val[2]])                   }
               | 'rtoi'   '(' Expresion ')'                            { result = Funcion_Rtoi::new([val[2]])                     }
               | 'top'    '(' Expresion ')'                            { result = Funcion_Top::new([val[2]])                      }
               | Expresion '%'   Expresion                             { result = Modulo::new([val[0], val[2]])                   }
               | Expresion '*'   Expresion                             { result = Multiplicacion::new([val[0], val[2]])           }
               | Expresion '+'   Expresion                             { result = Suma::new([val[0], val[2]])                     }
               | Expresion '-'   Expresion                             { result = Resta::new([val[0], val[2]])                    }
               | Expresion '..'  Expresion                             { result = Construccion::new([val[0], val[2]])             }
               | Expresion '/'   Expresion                             { result = Division::new([val[0], val[2]])                 }
               | Expresion '/='  Expresion                             { result = Desigual::new([val[0], val[2]])                 }
               | Expresion '<'   Expresion                             { result = Menor_Que::new([val[0], val[2]])                }
               | Expresion '<='  Expresion                             { result = Menor_Igual_Que::new([val[0], val[2]])          }
               | Expresion '<>'  Expresion                             { result = Interseccion::new([val[0], val[2]])             }
               | Expresion '=='  Expresion                             { result = Igual::new([val[0], val[2]])                    }
               | Expresion '>'   Expresion                             { result = Mayor_Que::new([val[0], val[2]])                }
               | Expresion '>='  Expresion                             { result = Mayor_Igual_Que::new([val[0], val[2]])          }
               | Expresion '>>'  Expresion                             { result = Pertenece::new([val[0], val[2]])                }
               | Expresion 'and' Expresion                             { result = And::new([val[0], val[2]])                      }
               | Expresion 'or'  Expresion                             { result = Or::new([val[0], val[2]])                       }
               | 'not' Expresion                                       { result = Not::new([val[1]])                              }
               | '-'   Expresion =UMINUS                               { result = Menos_Unario([val[1]])                          }
               ;

---- header ----

require 'Lexer'
require 'AST'

module Yisiel
  class ParseError < RuntimeError; end

  class SyntaxError < ParseError
    attr_reader :token, :context

    def initialize(token, context)
      @token   = token
      @context = context
    end

    def to_s
      last_tokens = []
      3.times do
        t = @context.pop
        break unless t
        last_tokens << t
      end
      ret  = "Error de sintaxis en la línea #{@token.line}, columna #{@token.col} cerca de #{token.code}\n"
      ret += "Contexto: #{last_tokens.reverse.inject("") { |s, t| s + t.code.to_s }}\n" unless last_tokens == []
      return ret
    end
  end

  class LexicalError < ParseError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def to_s
      errors.inject("Se encontraron errores lexicográficos:\n") { |s, error| s + error.to_s + "\n" }
    end
  end
end

---- inner ----

    def next_token
      token = @lexer.yylex
      @tokens << token
      return [false, false] unless token
      return [token.class, token]
    end

    def on_error(id, token, stack)
      raise SyntaxError::new(token, @tokens)
    end

    def parse(lexer)
#     @yydebug = true # DEBUG
      @lexer  = lexer
      @output = ""
      @tokens = []
      begin
        ast = do_parse
      rescue LexerException => e
        errors = [e]
        if not e.kind_of? FatalException
          lexer.skip(" ")
          go = true
          while go
            begin
              go = lexer.yylex
            rescue FatalException => e
              errors << e
              break
            rescue LexerException => e
              errors << e
              lexer.skip(" ")
            end
          end
        end
        raise LexicalError::new(errors)
      end
      puts @output unless @output == "" or $entrega != 2
      return ast
    end

    def r(string)
      @output << string + "\n"
    end

