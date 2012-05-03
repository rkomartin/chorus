class ApplicationController < ActionController::Base
  before_filter :require_login
  before_filter :set_collection_defaults, :only => :index
  after_filter :extend_expiration
  rescue_from 'ActiveRecord::RecordNotFound', :with => :render_not_found
  rescue_from 'ActiveRecord::RecordInvalid', :with => :render_not_valid
  rescue_from 'SecurityTransgression', :with => :render_forbidden

  private

  def render_not_valid(e)
    present_validation_errors ErrorPresenter.new(e.record.errors), :status => :unprocessable_entity
  end

  def render_not_found(e)
    present_errors({:record => :NOT_FOUND}, :status => :not_found)
  end

  def render_forbidden(e = nil)
    head(:forbidden)
  end

  def logged_in?
    !!current_user
  end

  def current_user
    @_current_user ||= User.find_by_id(session[:user_id])
  end

  def check_expiration
    head(:unauthorized) unless session[:expires_at] && session[:expires_at] > Time.now
  end

  def extend_expiration
    session[:expires_at] = Chorus::Application.config.session_timeout.from_now
  end

  def require_login
    head :unauthorized unless logged_in?
    check_expiration
  end

  def require_admin
    render_forbidden unless logged_in? && current_user.admin?
  end

  def require_admin_or_referenced_user
    head :not_found unless logged_in? && (current_user.admin? || current_user == @user)
  end

  def set_collection_defaults
    params.reverse_merge!(Chorus::Application.config.collection_defaults)
    require_white_listed_order
  end

  def require_white_listed_order
    head :bad_request unless (Chorus::Application.config.sorting_order_white_list.include?(params[:order]))
  end

  def present(model_or_collection, options={})
    json = { :response => Presenter.present(model_or_collection, view_context) }

    if model_or_collection.respond_to? :current_page
      json[:pagination] = {
          :page => model_or_collection.current_page,
          :per_page => model_or_collection.per_page,
          :total => model_or_collection.total_entries
      }
    end

    render options.merge({ :json => json })
  end

  def present_errors(errors, options={})
    render options.reverse_merge(:status => :bad_request).merge(:json => { :errors => errors } )
  end

  def present_validation_errors(errors, options={})
    present_errors({ :fields => errors }, options)
  end
end
