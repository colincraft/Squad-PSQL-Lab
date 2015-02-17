require 'sinatra'
require 'pry'
require 'better_errors'
require 'pg'
require 'sinatra/reloader'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squad_lab')

before do 
  @conn = settings.conn
end

# GET ROUTES
# ROOT DIRECTORY
get '/' do
  redirect '/squads'
end

#SHOW ALL SQUADS
get '/squads' do
  squads = []
  @conn.exec( "SELECT * FROM squads ORDER BY id ASC") do |result|
    result.each do |squad|
      squads << squad
    end
  end
  @squads = squads

  erb :index
end

# CREATE NEW SQUAD FORM PAGE
get '/squads/new' do
  erb :new
end

# SHOW SPECIFIC SQUAD
get '/squads/:squad_id' do
  id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
  @squad = squad[0]
# binding.pry
erb :show
end

# EDIT SPECIFIC SQUAD 
get '/squads/:squad_id/edit' do
  id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
  @squad = squad[0]
  erb :edit
end

# SHOW ALL STUDENTS FOR SPECIFIC SQUAD
get '/squads/:squad_id/students' do
  students = []
  id = params[:squad_id].to_i
  @conn.exec( "SELECT * FROM students WHERE squad_id=$1", [id]) do |result|
    result.each do |student|
      students << student
    end
  end
  @students = students
  erb :show_squad_students
end

# SHOW SPECIFC INFO FOR A STUDENT IN SQUAD
get '/squads/:squad_id/students/:student_id' do
  student_id = params[:student_id].to_i
  @students = @conn.exec("SELECT * FROM students WHERE id=$1", [student_id])
  erb :show_squad_specific_student
end

# CREATE NEW STUDENT FOR SQUAD FORM PAGE
get '/squads/:squad_id/students/new' do
  # @squad_id = params[:squad_id].to_i
  erb :newstudent
end
# EDIT STUDENTS INFO PAGE
get '/squads/:squad_id/students/:student_id/edit' do
  squad_id = params[:squad_id].to_i
  id = params[:student_id].to_i
  student = @conn.exec('SELECT * FROM students WHERE id = $1 AND squad_id = $2', [ id, squad_id ] )
  @student = student[0]
  erb :edit_student_for_specific_squad
end

# POST ROUTES
# CREATE NEW SQUAD
post '/squads' do
  @conn.exec("INSERT INTO squads (name) VALUES ($1)", [params[:name]])
  redirect '/squads'
end
# CREATE NEW STUDENT FOR EXISITING SQUAD
post '/squads/:squad_id/students' do

  # redirect '/squads'
end

# PUT ROUTES
# EDIT SQUAD
put '/squads/:squad_id' do 
  id= params[:squad_id].to_i
  @conn.exec("UPDATE squads SET name = ($1) WHERE id = ($2)", [params[:name], id])

  redirect '/squads'
end
# EDIT STUDENT IN EXISTING SQUAD
put '/squads/:squad_id/students' do
  student_id = params[:student_id].to_i
  @conn.exec('UPDATE students SET name=$1 WHERE id = $2', [ params[:name], student_id ] )
  redirect "/squads"
end

# DELETE ROUTES
# DELETE SQUAD
delete '/squads/:squad_id' do
  id= params[:squad_id].to_i
  @conn.exec("DELETE FROM squads WHERE id = ($1)", [id])
  redirect '/squads'
end
# DELETE STUDENT IN SQUAD
delete '/squads/:squad_id/students/:student_id' do
  id= params[:student_id].to_i
  @conn.exec("DELETE FROM students WHERE id = $1", [id])
  redirect '/squads'
end