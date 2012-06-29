post '/items/create/:slug' do
  redirect '/' unless list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  list.unfinished_items.create!(:note => params[:note])
  flash[:success] = 'Item created successfully'
  redirect "/lists/show/#{list.slug}"
end

post '/items/update/:id' do
  redirect '/' unless @item = Item.includes(:list => :list_owners).where(:lists => {:list_owners => {:owner => @current_username}}, :id => params[:id]).first
  @item.note = params[:note] if params[:note]
  @item.ordering = params[:ordering] if params[:ordering]
  @item.finished = params[:finished] if params[:finished]
  if @item.save!
    flash[:success] = 'Item updated successfully'
  else
    flash[:error] = @item.errors.full_messages.join(' ')
  end
  redirect "/lists/show/#{@item.list.slug}"
end

post '/items/destroy/:id' do
  redirect '/' unless @item = Item.includes(:list => :list_owners).where(:lists => {:list_owners => {:owner => @current_username}}, :id => params[:id]).first
  @item.destroy
  flash[:success] = 'Item deleted successfully'
  redirect "/lists/show/#{@item.list.slug}"
end
