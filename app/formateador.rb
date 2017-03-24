class Formateador
  # Este módulo se encarga de darle formato a las estructuras que datos que el sistema utiliza

  # Se encarga de dar formato a la estructura de la información completa del alumno
  #
  # * *Argumentos*  :
  #   - +matricula+ -> La matricula del alumno
  #   - +password+ -> El password del alumno
  #   - +info_map+ -> Un mapa que contiene el programa y el campus del alumno
  #   - +informacion+ -> Un mapa con la información personal del alumno
  #   - +horario+ -> Un arreglo con las clases del alumno
  #   - +periodos+ -> Un arreglo con los periodos del alumno
  #   - +faltas+ -> Un arreglo con las faltas del alumno
  #   - +creditos+ -> Un arreglo con los créditos del alumno
  # * *Retorna*     :
  #   - +mapa+ -> Un mapa con toda la informacion del alumno

  def self.alumno(matricula, password, info_map, informacion, horario, periodos, faltas, creditos)
    mapa = {
      usuario: {
        matricula: matricula,
        password: password
      },
      nombre: informacion[:nombre],
      apellido_p: informacion[:apellido_p],
      apellido_m: informacion[:apellido_m],
      sexo: informacion[:sexo],
      email: informacion[:email],
      matricula: matricula,
      programa: info_map[:programa],
      campus: info_map[:campus],
      creditos: creditos,
      periodos: periodos,
      horario: horario,
      faltas: faltas
    }
    mapa
  end

  # El sitio de la salle guarda diferentes textos en diferentes encodings.
  # Todavía no se sabe si es problema directamente de La Salle, o cómo Nokogiri
  # interactua con el sitio. Todo esto para representar correctamente los acentos.
  # * *Argumentos*  :
  #   - +string+ -> La cadena a revisar
  # * *Retorna*     :
  #   - +resultado+ -> Cadena correctamente formateada presentando cualquier caractér especial
  def self.string(string)
    resultado = ""
    if string.encoding.to_s == "UTF-8" then
      # puts "String a convertir: " + string + " con encoding: " + string.encoding.to_s
      resultado = string
      # puts "El resultado es: " + resultado + " con encoding: " + resultado.encoding.to_s
    elsif string.encoding.to_s == "Windows-1252"
      # puts "String a convertir: " + string + " con encoding: " + string.encoding.to_s
      resultado = string.force_encoding("utf-8")
      # puts "El resultado es: " + resultado + " con encoding: " + resultado.encoding.to_s
    else
      puts "El encoding es: " + string.encoding.to_s + " de: " + string
    end
    resultado
  end
  ##############
  # DESARROLLO #
  ##############
  def self.ejemplo
    ejemplo = {
      usuario: {
        matricula: 00060567,
        password: "JPJ60567"
      },
      nombre: "Jesús",
      apellido_p: "Perez",
      apellido_m: "Jimenez",
      matricula: 60567,
      programa: "Carrera",
      campus: "Torres",
      creditos: [{
        tipo: "Solidaridad",
        necesarios: 30,
        actuales: 8
      },
      {
        tipo: "Deportivo",
        necesarios: 30,
        actuales: 9
      }],
      periodos: [
        {
          mes_inicio: 8,
          mes_final: 12,
          year: 2017,
          boletas: [
            {
              tipo: 1,
              materia: "mate",
              profesor: "Enrique Perez Perez",
              parciales: [
                {
                  numero: 1,
                  calificacion: 7.5
                },
                {
                  numero: 2,
                  calificacion: 8.3
                },
                {
                  numero: 3,
                  calificacion: 8.8
                },
                {
                  numero: 4,
                  calificacion: 8.4
                },
                {
                  numero: 5,
                  calificacion: 8.9
                },
              ]
            }
          ]
        }
      ],
      horario: [
        {
          dia: 1,
          hora_inicio: 14,
          hora_final: 16,
          materia: "mate",
          profesor: "Pepe Perez Gonzales"
        }
      ],
      faltas: [
        {
          materia: "mate",
          cantidad: 3,
          periodo: {
            mes_inicio: 8,
            mes_final: 12,
            year: 1996
          }
        }
      ]
    }
    ejemplo
  end
end
