require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'rack-flash'

set :database, 'sqlite:///development.db'

class List < ActiveRecord::Base
  has_many :items, :order => 'items.ordering ASC', :dependent => :destroy
  has_many :unfinished_items, :class_name => 'Item', :foreign_key => 'list_id', :order => 'items.ordering ASC', :dependent => :destroy, :conditions => {:finished => false}
  has_many :finished_items, :class_name => 'Item', :foreign_key => 'list_id', :order => 'items.ordering ASC', :dependent => :destroy, :conditions => {:finished => true}
  has_many :list_owners, :dependent => :destroy
  has_many :pending_owners, :dependent => :destroy

  validates :name, :format => /^[a-zA-Z0-9_]{1}[a-zA-Z0-9_\s]{2,48}[a-zA-Z0-9_]{1}$/
  validates :slug, :uniqueness => true
  before_validation :create_slug

  def create_slug
    if self.slug.nil? || self.changed.include?('name')
      self.slug = if (s = self.name.gsub(/[^a-zA-Z0-9_]/, '_')) && List.where(:slug => s).count == 0
        s
      else
        s + '_' + (1..4).map{'_abcdefghijklmnopqrstuvwxyz'[(rand * 26).round]}.join
      end
    end
  end
end

class ListOwner < ActiveRecord::Base
  belongs_to :list

  validates :owner, :presence => true
end

class PendingOwner < ActiveRecord::Base
  belongs_to :list

  validates :owner, :uniqueness => {:scope => :list_id}
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

get '/' do
  @lists = List.includes(:list_owners).where(:list_owners => {:owner => @current_username}).order('name ASC')
  @pending_owners = PendingOwner.where(:owner => @current_username).order('id ASC')
  @icon = 'home'
  erb :home
end

require 'controllers/items'
require 'controllers/logins'
require 'controllers/list_owners'
require 'controllers/lists'
require 'controllers/pending_owners'
