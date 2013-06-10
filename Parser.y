class Parser
  token '<=' '<>' '<' '==' '=' '>=' '>>' '>' '-' ',' ';' '/=' '..' '(' ')'
        '*' '%' '+' 'and' 'as' 'begin' 'bool' 'bottom' 'case' 'declare' 'do'
        'else' 'end' 'false' 'for' 'id' 'if' 'in' 'int' 'length' 'not'
        'of' 'or' 'program' 'range' 'read' 'rtoi' 'str' 'then' 'top' 'true'
        'while' 'write' 'writeln' UMINUS

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
    right    'then' 'else'
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
    'num'     'TkNum'
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
       Programa: 'program' Instruccion                                { result = Programa::new(val[1])                         }
               ;
    Instruccion: 'id' '=' Expresion                                   { result = Asignacion::new(val[0], val[2])               }
               | 'begin' Declaraciones Instrucciones 'end'            { result = Bloque::new(val[1], val[2])                   }
               | 'read' 'id'                                          { result = Read::new(val[1])                             }
               | 'write' ElementosSalida                              { result = Write::new(val[1])                            }
               | 'writeln' ElementosSalida                            { result = Writeln::new(val[1])                          }
               | 'if' Expresion 'then' Instruccion 'else' Instruccion { result = Condicional_Else::new(val[1], val[3], val[5]) }
               | 'if' Expresion 'then' Instruccion                    { result = Condicional_If::new(val[1], val[3])           }
               | 'case' Expresion 'of' Casos 'end'                    { result = Case::new(val[0], val[3])                     }
               | 'for' 'id' 'in' Expresion 'do' Instruccion           { result = Iteracion_Det::new(val[1], val[3], val[5])    }
               | 'while' Expresion 'do' Instruccion                   { result = Iteracion_Indet::new(val[1], val[3])          }
               ;
          Casos: Caso                                                 { result = [val[0]]                                      }
               | Casos ';' Caso                                       { result = val[0] + [val[2]]                             }
               ;
           Caso: Expresion '->' Instruccion                           { result = Caso::new(val[0], val[2])                     }
               ;
  Declaraciones: 'declare' LDeclaraciones                             { result = Declaraciones::new(val[1])                    }
               |                                                      { result = Declaraciones::new([])                        }
               ;
 LDeclaraciones: Declaracion                                          { result = [val[0]]                                      }
               | LDeclaraciones ';' Declaracion                       { result = val[0] + [val[2]]                             }
               ;
    Declaracion: Variables 'as' Tipo                                  { result = Declaracion::new(val[0], val[2])              }
               ;
           Tipo: 'int'                                                { result = val[0]                                        }
               | 'bool'                                               { result = val[0]                                        }
               | 'range'                                              { result = val[0]                                        }
               ;
      Variables: Variables ',' 'id'                                   { result = val[0] + [val[2]]                             }
               | 'id'                                                 { result = [val[0]]                                      }
               ;
  Instrucciones: Instruccion                                          { result = [val[0]]                                      }
               | Instrucciones ';' Instruccion                        { result = val[0] + [val[2]]                             }
               ;
ElementosSalida: ElementoSalida                                       { result = [val[0]]                                      }
               | ElementosSalida ',' ElementoSalida                   { result = val[0] + [val[2]]                             }
               ;
 ElementoSalida: 'str'                                                { result = val[0]                                        }
               | Expresion                                            { result = val[0]                                        }
               ;
      Expresion: 'num'                                                { result = Entero::new(val[0])                           }
               | 'true'                                               { result = True::new()                                   }
               | 'false'                                              { result = False::new()                                  }
               | 'id'                                                 { result = Variable::new(val[0])                         }
               | 'bottom' '(' Expresion ')'                           { result = Funcion_Bottom::new(val[2])                   }
               | 'length' '(' Expresion ')'                           { result = Funcion_Length::new(val[2])                   }
               | 'rtoi'   '(' Expresion ')'                           { result = Funcion_Rtoi::new(val[2])                     }
               | 'top'    '(' Expresion ')'                           { result = Funcion_Top::new(val[2])                      }
               | Expresion '%'   Expresion                            { result = Modulo::new(val[0], val[2])                   }
               | Expresion '*'   Expresion                            { result = Multiplicacion::new(val[0], val[2])           }
               | Expresion '+'   Expresion                            { result = Suma::new(val[0], val[2])                     }
               | Expresion '-'   Expresion                            { result = Resta::new(val[0], val[2])                    }
               | Expresion '..'  Expresion                            { result = Construccion::new(val[0], val[2])             }
               | Expresion '/'   Expresion                            { result = Division::new(val[0], val[2])                 }
               | Expresion '/='  Expresion                            { result = Desigual::new(val[0], val[2])                 }
               | Expresion '<'   Expresion                            { result = Menor_Que::new(val[0], val[2])                }
               | Expresion '<='  Expresion                            { result = Menor_Igual_Que::new(val[0], val[2])          }
               | Expresion '<>'  Expresion                            { result = Interseccion::new(val[0], val[2])             }
               | Expresion '=='  Expresion                            { result = Igual::new(val[0], val[2])                    }
               | Expresion '>'   Expresion                            { result = Mayor_Que::new(val[0], val[2])                }
               | Expresion '>='  Expresion                            { result = Mayor_Igual_Que::new(val[0], val[2])          }
               | Expresion '>>'  Expresion                            { result = Pertenece::new(val[0], val[2])                }
               | Expresion 'and' Expresion                            { result = And::new(val[0], val[2])                      }
               | Expresion 'or'  Expresion                            { result = Or::new(val[0], val[2])                       }
               | 'not' Expresion                                      { result = Not::new(val[1])                              }
               | '-'   Expresion =UMINUS                              { result = Menos_Unario::new(val[1])                     }
               | '(' Expresion ')'                                    { result = val[1]                                        }
               ;

---- header ----

require 'Lexer'
require 'AST'

class ErrorSintactico < RuntimeError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error de sintaxis en linea #{@token.linea}, columna #{@token.columna}, token '#{@token.texto}' inesperado."
  end
end

---- inner ----

    def on_error(id, token, stack)
      raise ErrorSintactico::new(token)
    end

    def next_token
      token = @lexer.yylex
      return [false, false] unless token
      return [token.class, token]
    end

    def parse(lexer)
      @yydebug = true # DEBUG
      @lexer  = lexer
      @tokens = []
      begin
        ast = do_parse
      rescue ErrorLexicografico => error
        t = false
        while (!t) do
          begin
            t = lexer.yylex.nil?
          rescue ErrorLexicografico => error
          end
        end
        puts lexer
      end
      return ast
    end
