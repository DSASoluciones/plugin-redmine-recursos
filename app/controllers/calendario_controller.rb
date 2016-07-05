class CalendarioController < ApplicationController
  unloadable

  before_filter :encontrar_proyecto, :authorize#, :only => :index

  def index
    hoy = Time.now
    @usuarios_peticiones_total = User.joins('JOIN issues ON users.id = issues.assigned_to_id').select('users.id, users.login').where('users.status' => [1,2]).group('users.id')

    if params[:fecha_inicio].present? && params[:fecha_fin].present? && params[:usuario].present?
      if params[:fecha_inicio] != "" && params[:fecha_fin] != ""
        @fecha_ini_form = Date.parse params[:fecha_inicio]
        @fecha_fin_form = Date.parse params[:fecha_fin]
      else
        @fecha_ini_form = (hoy.beginning_of_week).to_date
        @fecha_fin_form = (hoy.end_of_week).to_date - 2.day
      end
      @usuario_select = params[:usuario]
      @usuario_select.each do |usr|
        usr = usr.to_i
      end
      usuarios_peticiones = User.joins('JOIN issues ON users.id = issues.assigned_to_id').select('users.id, users.login').where('users.id' => @usuario_select).group('users.id')
    else
        @fecha_ini_form = (hoy.beginning_of_week).to_date
        @fecha_fin_form = (hoy.end_of_week).to_date - 2.day
        usuarios_peticiones = User.joins('JOIN issues ON users.id = issues.assigned_to_id').select('users.id, users.login').group('users.id').limit(1)
    end

    @dias_mostrados = business_days_between(@fecha_ini_form, @fecha_fin_form) + 1

    @arreglo_actividades = []
    @arreglo_fecha_inicio = []
    @arreglo_fecha_fin = []
    @arreglo_duracion_horas = []
    @arreglo_duracion_dias = []
    @arreglo_porcentaje = []
    @arreglo_horas_por_dia = []
    arreglo_auxiliar1 = []
    arreglo_auxiliar2 = []
    arreglo_auxiliar3 = []
    arreglo_auxiliar4 = []
    arreglo_auxiliar5 = []
    arreglo_auxiliar6 = []
    @usuarios = []

    #Usuarios

    usuarios_peticiones.each do |usuario|

      peticion = Issue.select("subject, due_date, start_date, estimated_hours").where(:assigned_to_id => usuario.id , :done_ratio => [0,10,20,30,40,50,60,70,80,90]).where('issues.due_date >= ?', @fecha_ini_form.beginning_of_day).where('issues.start_date <= ?', @fecha_fin_form.end_of_day)

      peticion.each do |actividad|
        arreglo_auxiliar1 << actividad.subject
        arreglo_auxiliar2 << actividad.due_date
        arreglo_auxiliar3 << actividad.start_date
        arreglo_auxiliar4 << actividad.estimated_hours
        arreglo_auxiliar5 << business_days_between(actividad.start_date, actividad.due_date) + 1
        arreglo_auxiliar6 << actividad.estimated_hours / (business_days_between(actividad.start_date, actividad.due_date) + 1)
      end

      @arreglo_actividades << arreglo_auxiliar1
      @arreglo_fecha_fin << arreglo_auxiliar2
      @arreglo_fecha_inicio << arreglo_auxiliar3
      @arreglo_duracion_horas << arreglo_auxiliar4
      @arreglo_duracion_dias << arreglo_auxiliar5
      @arreglo_horas_por_dia << arreglo_auxiliar6
      arreglo_auxiliar1 = []
      arreglo_auxiliar2 = []
      arreglo_auxiliar3 = []
      arreglo_auxiliar4 = []
      arreglo_auxiliar5 = []
      arreglo_auxiliar6 = []

      @usuarios << usuario.login

    end

    @num_usuarios = @usuarios.length - 1

    #Grupos
    grupos_peticiones = Group.joins('JOIN issues ON users.id = issues.assigned_to_id').select('users.id, users.lastname').group('users.id')


    arreglo_actividades_g = []
    arreglo_fecha_inicio_g = []
    arreglo_fecha_fin_g = []
    arreglo_duracion_horas_g = []
    arreglo_duracion_dias_g = []
    arreglo_porcentaje_g = []
    arreglo_horas_por_dia_g = []
    arreglo_grupo_usuario = []
    arreglo_auxiliar7 = []
    grupos = []

    grupos_peticiones.each do |grupo|

      peticion_g = Issue.select("subject, due_date, start_date, estimated_hours").where(:assigned_to_id => grupo.id , :done_ratio => [0,10,20,30,40,50,60,70,80,90]).where('issues.due_date >= ?', @fecha_ini_form.beginning_of_day).where('issues.start_date <= ?', @fecha_fin_form.end_of_day)

      peticion_g.each do |actividad|
        arreglo_auxiliar1 << actividad.subject
        arreglo_auxiliar2 << actividad.due_date
        arreglo_auxiliar3 << actividad.start_date
        arreglo_auxiliar4 << actividad.estimated_hours
        arreglo_auxiliar5 << business_days_between(actividad.start_date, actividad.due_date) + 1
        arreglo_auxiliar6 << actividad.estimated_hours / (business_days_between(actividad.start_date, actividad.due_date) + 1)
      end
      arreglo_actividades_g << arreglo_auxiliar1
      arreglo_fecha_fin_g << arreglo_auxiliar2
      arreglo_fecha_inicio_g << arreglo_auxiliar3
      arreglo_duracion_horas_g << arreglo_auxiliar4
      arreglo_duracion_dias_g << arreglo_auxiliar5
      arreglo_horas_por_dia_g << arreglo_auxiliar6
      arreglo_auxiliar1 = []
      arreglo_auxiliar2 = []
      arreglo_auxiliar3 = []
      arreglo_auxiliar4 = []
      arreglo_auxiliar5 = []
      arreglo_auxiliar6 = []

      grupos << grupo.lastname

      grupo_usuarios = User.joins('JOIN groups_users ON users.id = groups_users.user_id').select('users.login').where('groups_users.group_id' => grupo.id)

      grupo_usuarios.each do |usuario|
        arreglo_auxiliar7 << usuario.login
      end

      arreglo_grupo_usuario << arreglo_auxiliar7
      arreglo_auxiliar7 = []

    end

    num_grupos = grupos.length - 1

    for i in 0..num_grupos
      if (arreglo_actividades_g[i].length - 1) >= 0
        if (arreglo_grupo_usuario[i].length - 1) >= 0
          for j in 0..(arreglo_grupo_usuario[i].length - 1)
            for k in 0..@num_usuarios
              if arreglo_grupo_usuario[i][j] == @usuarios[k]
                for l in 0..(arreglo_actividades_g[i].length - 1)           
                  @arreglo_actividades[k] << arreglo_actividades_g[i][l]
                  @arreglo_fecha_fin[k] << arreglo_fecha_fin_g[i][l]
                  @arreglo_fecha_inicio[k] << arreglo_fecha_inicio_g[i][l]
                  @arreglo_duracion_horas[k] << arreglo_duracion_horas_g[i][l]
                  @arreglo_duracion_dias[k] << arreglo_duracion_dias_g[i][l]
                  @arreglo_horas_por_dia[k] << arreglo_horas_por_dia_g[i][l] / arreglo_grupo_usuario[i].length
                end
              end
            end          
          end
        end
      end
    end

    @verifica_actividades = 0

  end#fin index

  def business_days_between(date1, date2)
    business_days = 0
    date = date2
    while date > date1
     business_days = business_days + 1 unless date.saturday? or date.sunday?
     date = date - 1.day
    end
    return business_days
  end

  def encontrar_proyecto
    @project = Project.find(params[:id])
  end

  helper_method :business_days_between

end