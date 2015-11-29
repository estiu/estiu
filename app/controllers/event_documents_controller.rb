class EventDocumentsController < ApplicationController
  
  def destroy
    event_document = EventDocument.find params[:event_document_id]
    authorize(event_document)
    begin
      event_document.destroy!
      head 200
    rescue
      head 422
    end
  end
  
end
