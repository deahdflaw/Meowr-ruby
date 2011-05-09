require 'sinatra'
require 'redis'
require 'erb'
require 'russian'

redis = Redis.new

get '/' do
   erb :index
end

get '/about' do

end

get '/:addr' do
  if (redis.get("page:user:#{params[:addr]}:puid") == nil)
    'Nothing!'
  else
    erb :page
  end
end

get '/admin/create' do
  erb :create
end

post '/admin/create' do
  redis.set("page:user:#{redis.get('page:user:nextid')}:title", params[:title])
  redis.set("page:user:#{redis.get('page:user:nextid')}:text", params[:text])
  redis.set("page:user:#{redis.get('page:user:nextid')}:addr", Russian.translit(params[:title]))
  redis.set("page:user:#{Russian.translit(params[:title])}:puid", redis.get('page:user:nextid'))
  redis.incr('page:user:nextid')
  redirect '/'
end

get '/admin/edit/:addr' do
   erb :edit
end

post '/admin/edit' do
  redis.del("page:user:#{redis.get("page:user:#{params[:puid]}:addr")}:puid")
  redis.set("page:user:#{params[:puid]}:title", params[:title])
  redis.set("page:user:#{params[:puid]}:text", params[:text])
  redis.set("page:user:#{params[:puid]}:addr", Russian.translit(params[:title]))
  redis.set("page:user:#{Russian.translit(params[:title])}:puid", params[:puid])
  redirect '/'
end

error 404 do
  erb :error404
end