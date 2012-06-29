post '/list_owners/destroy/:slug' do
  redirect '/' unless list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  if list.list_owners.count > 1
    list.list_owners.where(:owner => @current_username).destroy_all
    flash[:success] = "You have been removed from list: #{list.name}"
  else
    flash[:error] = 'You are last owner of the list, you must delete the list to remove it'
  end
  redirect '/'
end
