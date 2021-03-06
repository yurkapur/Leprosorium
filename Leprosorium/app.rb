#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end


before do
	init_db
end

configure do
		init_db
		@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
		   (
		    	id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, 
		    	created_date DATETIME, 
		    	content TEXT
		    )'

		@db.execute 'CREATE TABLE IF NOT EXISTS Comments
		   (
		    	id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, 
		    	created_date DATETIME, 
		    	content TEXT,
		    	post_id INTEGER
		    )'
end

get '/' do
	#choosing list of posts from database
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  if content.length <= 0 
  	@error='Type something in text field'
  	return erb :new
  end
  # save data in database

    @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	redirect to('/')
end

#output info about post
get '/details/:post_id' do

	# get variable from URL

	post_id = params[:post_id]
	# get list of posts
	@results = @db.execute 'select * from Posts where id = ?', [post_id]
	#choosing this post in variable 'row'
	@row = @results[0] 

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]


	# returns details.erb
	erb :details
end


post '/details/:post_id' do
	post_id = params[:post_id]

	content = params[:content]

	@db.execute 'insert into Comments 
	(
		content, 
		created_date, 
		post_id
	) 
		values 
	(
		?,
		datetime(),
		?
	)', [content, post_id]

	redirect to('/details/' + post_id)
end




