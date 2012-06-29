get '/login' do
  erb :login
end

post '/login' do
  if params[:username] && params[:username].to_s.match(/^[a-zA-Z0-9]{1}[a-zA-Z0-9_]{2,18}[a-zA-Z0-9]{1}$/)
    response.set_cookie('my_list_username', :value => params[:username], :expires => Date.today.next_year(2).to_time)
    flash[:success] = 'Login successful'
    redirect '/'
  else
    flash[:error] = 'Must be between 4 and 20 characters using only letters, numbers, and underscores'
    flash[:username] = params[:username]
    redirect '/login'
  end
end

get '/logout' do
  flash[:success] = 'Successfully logged out'
  response.delete_cookie('my_list_username')
  redirect '/login'
end
