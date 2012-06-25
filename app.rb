require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'rack-flash'

set :database, 'sqlite:///development.db'

class List < ActiveRecord::Base
  has_many :items, :order => 'items.ordering ASC', :dependent => :destroy
  has_many :unfinished_items, :class_name => 'Item', :foreign_key => 'list_id', :order => 'items.ordering ASC', :dependent => :destroy, :conditions => {:finished => false}
  has_many :finished_items, :class_name => 'Item', :foreign_key => 'list_id', :order => 'items.ordering ASC', :dependent => :destroy, :conditions => {:finished => true}

  validates :owner, :presence => true
  validates :name, :format => /^[a-zA-Z0-9_]{1}[a-zA-Z0-9_\s]{2,48}[a-zA-Z0-9_]{1}$/
  validates :slug, :uniqueness => {:scope => :owner}
  validates :ordering, :uniqueness => {:scope => :owner}
  before_validation :insert_into_ordering
  before_validation :create_slug
  after_destroy :reassign_ordering

  def insert_into_ordering
    self.ordering ||= 0
    if self.changes.include?(:ordering)
      lists = List.where(:owner => self.owner).order('ordering ASC') - [self]
      lists.insert(self.ordering, self).each_with_index do |list, index|
        List.where(:id => list.id).update_all(:ordering => index) unless list == self
      end
    end
  end

  def create_slug
    if self.slug.nil? || self.changed.include?('name')
      self.slug = if (s = self.name.gsub(/[^a-zA-Z0-9_]/, '_')) && List.where(:slug => s).count == 0
        s
      else
        s + '_' + (1..4).map{'_abcdefghijklmnopqrstuvwxyz'[(rand * 26).round]}.join
      end
    end
  end

  def reassign_ordering
    lists = List.where(:owner => self.owner).order('ordering ASC')
    lists.each_with_index{|list, index| List.where(:id => list.id).update_all(:ordering => index)}
  end
end

class Item < ActiveRecord::Base
  belongs_to :list

  after_validation :assign_default_ordering
  after_save :insert_into_ordering
  after_save :finish_or_unfinish
  after_destroy :reassign_ordering

  def assign_default_ordering
    self.ordering ||= 0
  end

  def insert_into_ordering
    reassign_ordering if self.changes.include?(:ordering)
  end

  def finish_or_unfinish
    if self.changes.include?(:finished)
      self.ordering = 0
      reassign_ordering 
    end
  end

  def reassign_ordering
    [{:finished => false}, {:finished => true}].each do |conds|
      items = self.list.items.where(conds).where('items.id != ?', self.id).to_a
      items = items.insert(self.ordering, self) if conds[:finished] == self.finished? && !self.destroyed?
      items.each_with_index do |item, index|
        Item.where(:id => item.id).update_all(:ordering => index)
      end
    end
  end
end

enable :sessions
use Rack::Flash

before do
  unless ['/login', '/logout'].any?{|p| p == request.env['REQUEST_URI'] }
    @current_username = request.cookies['my_list_username']
    if @current_username.nil?
      response.delete_cookie('my_list_username')
      redirect '/login'
    end
  end
end

get '/login' do
  erb :login
end

post '/login' do
  if params[:username] && params[:username].to_s.match(/^[a-zA-Z0-9]{4,20}$/)
    response.set_cookie('my_list_username', :value => params[:username], :expires => Date.today.next_year(2).to_time)
    flash[:success] = 'Login successful'
    redirect '/'
  else
    flash[:error] = 'Username can only be numbers and letters and must be between 4 and 20 characters inclusive'
    flash[:username] = params[:username]
    redirect '/login'
  end
end

get '/logout' do
  flash[:success] = 'Successfully logged out'
  response.delete_cookie('my_list_username')
  redirect '/login'
end

get '/' do
  @lists = List.where(:owner => @current_username).order('ordering ASC')
  @icon = 'home'
  erb :home
end

post '/lists/create' do
  list = List.where(:owner => @current_username, :name => params[:name]).first
  list ||= List.create!(:owner => @current_username, :name => params[:name])
  flash[:success] = 'List created successfully'
  redirect "/lists/show/#{list.slug}"
end

post '/lists/update/:slug' do
  redirect '/' unless @list = List.where(:owner => @current_username, :slug => params[:slug]).first
  @list.name = params[:name] if params[:name]
  @list.ordering = params[:ordering] if params[:ordering]
  if @list.save!
    flash[:success] = 'List updated successfully'
  else
    flash[:error] = @list.errors.full_messages.join(' ')
  end
  redirect '/'
end

post '/lists/destroy/:slug' do
  redirect '/' unless @list = List.where(:owner => @current_username, :slug => params[:slug]).first
  @list.destroy
  flash[:success] = "List: #{@list.name} deleted successfully"
  redirect '/'
end

get '/lists/show/:slug' do
  redirect '/' unless @list = List.where(:owner => @current_username, :slug => params[:slug]).first
  erb :list
end

post '/items/create/:slug' do
  redirect '/' unless list = List.where(:owner => @current_username, :slug => params[:slug]).first
  list.unfinished_items.create!(:note => params[:note])
  flash[:success] = 'Item created successfully'
  redirect "/lists/show/#{list.slug}"
end

post '/items/update/:id' do
  redirect '/' unless @item = Item.includes(:list).where(:lists => {:owner => @current_username}, :id => params[:id]).first
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
  redirect '/' unless @item = Item.includes(:list).where(:lists => {:owner => @current_username}, :id => params[:id]).first
  @item.destroy
  flash[:success] = 'Item deleted successfully'
  redirect "/lists/show/#{@item.list.slug}"
end









