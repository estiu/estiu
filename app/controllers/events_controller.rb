class EventsController < ApplicationController
  
  before_action :load_event, only: [:show]
  
  with_events = [:index]
  before_action :load_events, only: with_events
  after_action :verify_policy_scoped, only: with_events
  
  def index
  end
  
  def show
  end
  
  def new
    authorize(@event = Event.new(campaign: Campaign.find(params[:id])))
  end
  
  def create
    authorize(@event = Event.new(event_attrs))
  end
  
  protected
  
  def load_events
    authorize Event
    @events = policy_scope Event
  end
  
  def load_event
    authorize(@event = Event.find(params[:id]))
  end
  
  def event_attrs
    
  end
  
end
