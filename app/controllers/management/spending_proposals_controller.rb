class Management::SpendingProposalsController < Management::BaseController

  before_action :check_verified_user
  before_action :set_spending_proposal, only: [:vote, :show]

  def index
    @spending_proposals = apply_filters_and_search(SpendingProposal).page(params[:page]).for_render
    set_spending_proposal_votes(@spending_proposals)
  end

  def new
    @spending_proposal = SpendingProposal.new
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = managed_user

    if @spending_proposal.save_with_captcha
      redirect_to management_spending_proposal_path(@spending_proposal), notice: t('flash.actions.create.notice', resource_name: t("activerecord.models.spending_proposal", count: 1))
    else
      render :new
    end
  end

  def show
    set_spending_proposal_votes(@spending_proposal)
  end

  def vote
    @spending_proposal.register_vote(current_user, 'yes')
    set_spending_proposal_votes(@spending_proposal)
  end

  private

    def set_spending_proposal
      @spending_proposal = SpendingProposal.find(params[:id])
    end

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :terms_of_service, :captcha, :captcha_key)
    end

    def check_verified_user
      unless current_user.level_two_or_three_verified?
        redirect_to management_document_verifications_path, alert: t("management.spending_proposals.alert.unverified_user")
      end
    end

    def current_user
      managed_user
    end

    # This should not be necessary. Maybe we could create a specific show view for managers.
    def set_spending_proposal_votes(spending_proposals)
      @spending_proposal_votes = current_user ? current_user.spending_proposal_votes(spending_proposals) : {}
    end

    def apply_filters_and_search(target)
      target = params[:unfeasible].present? ? target.unfeasible : target.not_unfeasible
      if params[:geozone].present?
        target = target.by_geozone(params[:geozone])
        set_geozone_name
      end
      target = target.search(params[:search]) if params[:search].present?
      target
    end

end
