class EventsController < ApplicationController
  
  before_action :initialize_event, only: [:new]
  before_action :load_event, only: [:show, :submit_documents]
  before_action :initialize_uploader, only: [:show]
  
  with_events = [:index]
  before_action :load_events, only: with_events
  after_action :verify_policy_scoped, only: with_events
  
  def index
    @campaigns_with_pending_events = current_event_promoter ? Campaign.without_event.where(event_promoter_id: current_event_promoter.id).all : []
  end
  
  def show
  end
  
  def new
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
  
  def submit_documents
    @event.assign_attributes document_attrs
    redirect_to @event
  end
  
  helper_method :should_upload_documents?
  def should_upload_documents?
    current_event_promoter && !@event.approved_at
  end
  
  protected
  
  def initialize_event
    authorize(@event = Event.new(campaign: Campaign.find(params[:id])))
  end
  
  def load_events
    authorize Event
    @events = policy_scope Event
  end
  
  def load_event
    authorize(@event = Event.find(params[:id]))
  end
  
  def event_attrs
    params.
      permit(event: (Event::CREATE_ATTRS + [{ra_artists_attributes: %i(artist_path)}]))[:event].
      merge(campaign_id: params[:id])
  end
  
  def document_attrs
    params.permit(event: [{event_documents_attributes: %i(filename key)}])[:event]
  end
  
end
