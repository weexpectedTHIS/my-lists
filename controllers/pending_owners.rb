post '/pending_owners/create/:slug' do
  redirect '/' unless list = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}, :slug => params[:slug]).first
  if params[:owner].to_s.match(/^[a-zA-Z0-9]{1}[a-zA-Z0-9_]{2,18}[a-zA-Z0-9]{1}$/)
    if list.pending_owners.where(:owner => params[:owner]).empty?
      if list.list_owners.where(:owner => params[:owner]).empty?
        list.pending_owners.create!(:requester => @current_username, :owner => params[:owner])
        flash[:success] = "List: #{list.name} ownership request created successfully"
      else
        flash[:error] = 'This person is already an owner'
      end
    else
      flash[:error] = 'There is a pending share request on this list for this person already'
    end
  else
    flash[:error] = 'Must be between 4 and 20 characters using only letters, numbers, and underscores'
  end
  redirect '/'
end

post '/pending_owners/destroy/:slug/:answer' do
  redirect '/' unless pending_owner = PendingOwner.includes(:list).where(:owner => @current_username, :lists => {:slug => params[:slug]}).first
  if params[:answer] == 'accept'
    pending_owner.list.list_owners.create!(:owner => @current_username)
    flash[:success] = "List: #{pending_owner.list.name} now being shared"
  else
    flash[:success] = "List: #{pending_owner.list.name} declined to be shared"
  end
  pending_owner.destroy
  redirect '/'
end
