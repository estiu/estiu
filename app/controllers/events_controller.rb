class EventsController < ApplicationController
  
  before_action :initialize_event, only: [:new]
  before_action :load_event, only: [:show, :submit_documents, :submit]
  before_action :initialize_uploader, only: [:show]
  
  with_events = [:index]
  before_action :load_events, only: with_events
  after_action :verify_policy_scoped, only: with_events
  
  def index
    @campaigns_with_pending_events = current_event_promoter ? Campaign.without_event.where(event_promoter_id: current_event_promoter.id).all : []
  end
  
  def show
    if @event.submitted_at && !@event.approved_at
      flash.now[:success] = t('events.submit.success')
    end
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
  
  def submit
    @event.submitted_at = DateTime.now
    if @event.save
      # no flash needed.
    else
      flash[:error] = t('.error')
    end
    redirect_to @event
  end
  
  def submit_documents
    document = EventDocument.new(event_document_attrs)
    if document.save
      render json: {id: document.id}, status: 200
    else
      head 422
    end
  end
  
  helper_method :should_upload_documents?
  def should_upload_documents?
    current_event_promoter && !@event.submitted_at
  end
  
  helper_method :display_event_documents?
  def display_event_documents?
    (current_event_promoter == @event.campaign.event_promoter) && !@event.approved_at
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
  
  def event_document_attrs
    params.permit(event_document: %i(filename key visible_name))[:event_document].merge(event: @event)
  end
  
end
