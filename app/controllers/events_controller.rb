class EventsController < ApplicationController
  
  before_action :load_event, only: [:show, :edit]
  
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
    if @event.save
      flash[:success] = t('.success')
      redirect_to @event
    else
      flash.now[:error] = t('.error')
      render :new
    end
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
    params.
      permit(event: (Event::CREATE_ATTRS + [{resident_advisor_paths_attributes: %i(value)}]))[:event].
      merge(campaign_id: params[:id])
  end
  
end
