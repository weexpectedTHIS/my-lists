post '/lists/create' do
  list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :name => params[:name]).first
  list ||= List.create!(:list_owners => [ListOwner.new(:owner => @current_username)], :name => params[:name])
  flash[:success] = "List: #{list.name} created successfully"
  redirect "/lists/show/#{list.slug}"
end

post '/lists/update/:slug' do
  redirect '/' unless list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  list.name = params[:name] if params[:name]
  list.ordering = params[:ordering] if params[:ordering]
  if @list.save!
    flash[:success] = "List: #{list.name} updated successfully"
  else
    flash[:error] = list.errors.full_messages.join(' ')
  end
  redirect '/'
end

post '/lists/destroy/:slug' do
  redirect '/' unless @list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  @list.destroy
  flash[:success] = "List: #{@list.name} deleted successfully"
  redirect '/'
end

get '/lists/show/:slug' do
  redirect '/' unless @list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  @list.list_owners(true)
  erb :list
end
