class CampaignDraftsController < ApplicationController
  
  should_load_draft = [:show, :edit, :update, :destroy, :submit]
  before_action :load_draft, only: should_load_draft
  before_action :authorize_draft, only: should_load_draft
  
  def index
  end
  
  def show
  end
  
  def edit
  end
  
  def new
    authorize(@draft = CampaignDraft.new)
  end
  
  def create
    authorize(@draft = CampaignDraft.new(draft_attrs_step_1))
    @draft.event_promoter = current_user.event_promoter
    if @draft.save
      flash[:success] = t('.success')
      redirect_to campaign_draft_path(@draft)
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end
  
  def update
    @draft.assign_attributes(draft_attrs_step_1)
    if @draft.save
      redirect_to campaign_draft_path(@draft), notice: t('.success')
    else
      flash.now[:error] = t('.error')
      render :edit
    end
  end
  
  def submit
    @draft.assign_attributes(draft_attrs_step_2)
    @draft.submitted_at = DateTime.now
    if @draft.save
      flash.now[:success] = t('.success')
    else
      flash.now[:error] = t('.error')
      @draft.submitted_at = nil
    end
    render :show
  end
  
  def publish
    
  end
  
  def do_publish
    
  end
  
  def destroy
    verify_authorized # extra call just in case
    if @draft.destroy
      flash[:success] = t('.success')
    else
      flash[:error] = t('.error')
    end
    redirect_to campaigns_path
  end
  
  protected
  
  def load_draft
    @draft = CampaignDraft.find(params[:id])
  end
  
  def draft_attrs_step_1
    authorize(CampaignDraft.new) unless @draft.try(:id) # ugly extra call to .authorize for keeping the tests happy
    params.permit(campaign_draft: CampaignDraft::CREATE_ATTRS_STEP_1)[:campaign_draft]
  end
  
  def draft_attrs_step_2
    v = params.permit(campaign_draft: CampaignDraft::CREATE_ATTRS_STEP_2)[:campaign_draft]
    if v[:time_zone].present?
      process_datetime_params v, CampaignDraft::DATE_ATTRS, v[:time_zone]
    else
      v.except(:"starts_at(4i)", :"starts_at(5i)", :"ends_at(4i)", :"ends_at(5i)")
    end
  end
  
  def authorize_draft
    authorize @draft
  end
  
end
