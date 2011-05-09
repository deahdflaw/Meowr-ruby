require 'sinatra'
require 'redis'
require 'erb'
require 'russian'
require '/libs/funcs.rb'
require 'digest/md5'

redis = Redis.new
var logged

get '/' do
   erb :index
end

get '/about' do

end

get '/login' do
  erb :login
end

post '/login' do
  login = params[:login]
  pass =  Digest::MD5.hexdigest(params[:pass])
  printf pass
  if login == redis.get("admin:login") && pass == redis.get("admin:pass")
    logged = true
    redis.set("admin:session", true)
    redis.expire("admin:session", "3600")
    redirect back
  else
    logged = false
    redirect '/'
  end
end

get '/:addr' do
  if redis.get("page:user:#{params[:addr]}:puid") == nil
    404
  else
    erb :page
  end
end

get '/admin/create' do
  if logged
    erb :create
  else
    redirect '/login'
  end
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

error 403 do
  erb :error403
end