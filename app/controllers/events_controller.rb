class EventsController < ApplicationController
  
  with_events = [:index]
  before_action :load_events, only: with_events
  after_action :verify_policy_scoped, only: with_events
  
  def index
  end
  
  def load_events
    authorize Event
    @events = policy_scope Event
  end
  
end
