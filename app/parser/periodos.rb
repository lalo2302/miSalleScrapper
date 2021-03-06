require 'nokogiri'

module Parser
  module Periodos
    module_function
    #   *Módulo*
    # Este módulo se encargade obtener la información básica del alumno y sus calificaciones
    # Url de la página: http://207.249.157.32/cgi-bin/r.cgi/Consulta/w0400301.r?sistema=X&matricula=XXXXX

    # Este método se encarga de parsear la información del alumno y los periodos
    # * *Argumentos*  :
    #   - +page+ -> Pagina que contiene toda la información a obtener
    # * *Retorna*     :
    #   - +periodos_arr+ -> Un arreglo con mapas, siendo los periodos obtenidos
    #   - +info_mapa+ -> Un mapa conteniendo la información básica del alumno. Consultar self.get_informacion
    def self.parsear(page)
      tablas = page.xpath("//table")
      parrafos = page.xpath("//p")[1..-6]

      info = tablas.shift
      info_mapa = self.get_informacion(info)

      periodos_arr = self.periodos(tablas, parrafos)
      return periodos_arr, info_mapa
    end

    # Este método obtiene la información básica del alumno que se encuentra en la página de periodos
    # Información básica:
    #   - Programa
    #   - Campus
    # * *Argumentos*  :
    #   - +tabla+ -> La tabla que contiene la información
    # * *Retorna*     :
    #   - +mapa+ -> El mapa con la información
    def self.get_informacion(tabla)
      rows = tabla.xpath("tr")
      programa_array = rows[1].xpath("td")[0].content.split
      programa = programa_array[1..-1].join(" ")

      campus_array = rows[1].xpath("td")[1].content.split
      campus = campus_array[1..-1].join(" ")
      mapa = {
        programa: programa.capitalize,
        campus: campus.capitalize
      }
      mapa
    end

    # Este método se encarga de obtener los periodos de un alumno utilizando recursión.
    # Esto incluye periodos que incluyen extraordinarios, o periodos 
    # exclusivamente dedicados a un extraordinario
    # * *Argumentos*  :
    #   - +tablas+ -> Un arreglo que en cada posición contiene una tabla, esta siendo 1 bloque de calificaciones
    #   - +parrafos+ -> Un arreglo que contiene el texto que acompaña cada bloque de calificaciones.
    #                   Una tabla como mínimo viene acompañada de un parrafo, que describe su tipo.
    #                   Si el parrafo contiene la palabra `Periodo` significa que ese periodo se cierra,
    #                   y el siguiente es otro periodo completamente nuevo.
    #                   Si no, significa que existieron calificaciones extraordinarias dentro de ese periodo.
    #   - +acumulador+ -> Este arreglo contendrá los extraordinarios, o calificaciones que se encuentran en el
    #                     mismo periodo, pero pertenecían a otra tabla. POR DEFAULT: Un arreglo vació
    #   - +pila+ -> Esta función al ser llamada recursivamente, necesita estar recibiendo los periodos
    #               que ya han sido formateados. POR DEFAULT: Un arreglo vacío.
    # * *Retorna*     :
    #   Este método retornará en caso de que no exista otro periodo en el argumento +tablas+.
    #   - +pila+ -> Un arreglo con mapas, siendo el conjunto de periodos obtenidos
    def self.periodos(tablas, parrafos, acumulador = [], pila = [])

      # Clausula de retorno para recursión
      if !tablas.empty? then 
        boletas = self.boletas(tablas.pop, parrafos.pop, acumulador) 
      else 
        return pila
      end

      if parrafos.last != nil and parrafos.last.content.include?('Periodo') then 
        periodo = parrafos.pop.content
        periodo = periodo.slice(9..-1)
        periodo_mapa = get_periodo_mapa(periodo, boletas)
        pila << periodo_mapa

        periodos(tablas, parrafos, acumulador, pila)
      else
        acumulador << boletas
        periodos(tablas, parrafos, acumulador, pila)
      end
    end

    # Este método se encarga de obtener las boletas de un periodo
    # * *Argumentos*  :
    #   - +tabla+ -> Un elemento <table> de Nokogiri, siendo el periodo a analizar
    #   - +parrafo+ -> El tipo de periodo que se está analizando. Puede ser Ordinario o Extraordinario
    #   - +acumulador+ -> En caso de que el periodo haya tenido extraordinarios, estos se presentarán aquí
    # * *Retorna*     :
    #   - +boletas+ -> Un arreglo con mapas, siendo todas las boletas obtenidas del periodo, incluyendo el +acumulador+
    def self.boletas(tabla, parrafo,  acumulador)
      tipo = ""
      if parrafo != nil then
        tipo = parrafo.content
      end

      boletas = []

      rows = tabla.xpath("tr") 
      boletas_rows = rows[2..-4]
      boletas_rows.each_with_index do |b, i|
        if i.even? then
          celdas = b.xpath("td")
          nom_materia = celdas[1].content.strip
          profesor = celdas[-1].content.strip
          parcial1 = celdas[4].content.strip
          parcial2 = celdas[6].content.strip
          parcial3 = celdas[8].content.strip
          parcial4 = celdas[10].content.strip
          faltas = celdas[11].content.strip
          final = celdas[12].content.strip

          info = {tipo: tipo, nom_materia: nom_materia, profesor: profesor, parcial1: parcial1.to_f, 
                  parcial2: parcial2.to_f, parcial3: parcial3.to_f, parcial4: parcial4.to_f, faltas: faltas.to_i,
                  final: final.to_f}
          mapa = get_mapa(info)

          boletas << mapa 
        end
      end
      boletas << acumulador.last.pop unless acumulador.empty?
      return boletas
    end

    def self.get_periodo_mapa(periodo, boletas)
      mapa = { 
        nombre: periodo,
        boletas: boletas
      }
      mapa
    end

    def self.get_mapa(info)
      mapa = {
        tipo: info[:tipo],
        materia: {nombre: info[:nom_materia].capitalize},
        profesor: {nombre: info[:profesor]},
        faltas: info[:faltas],
        parciales: [
          {
            numero: 1,
            calificacion: info[:parcial1]
          },
          {
            numero: 2,
            calificacion: info[:parcial2]
          },
          {
            numero: 3,
            calificacion: info[:parcial3]
          },
          {
            numero: 4,
            calificacion: info[:parcial4]
          },
          {
            # Calificacion Final
            numero: 5,
            calificacion: info[:final]
          }
        ]
      }
      mapa
    end

    def self.get_mes_num(mes)
      case mes
      when "AGO"
        return 8
      when "DIC"
        return 12
      when "FEB"
        return 2
      when "JUN"
        return 6
      when "ENE"
        return 1
      when "MAR"
        return 3
      when "ABR"
        return 4
      when "MAY"
        return 5
      when "JUL"
        return 7
      when "SEP"
        return 9
      when "OCT"
        return 10
      when "NOV"
        return 11
      else
        return 0
      end
    end
  end
end
