class ApplicationController < ActionController::Base
  before_action :reassign_params

  # Disable CSRF protection for API requests (this is a vulnerable app for testing)
  skip_before_action :verify_authenticity_token

  #protect_from_forgery
  
  ### APPSEC Vuln 12: Information disclosure - exposing sensitive configuration
  def show_config
    render json: {
      secret_token: VulnerableApp::Application.config.secret_token,
      environment: Rails.env,
      database: Rails.configuration.database_configuration[Rails.env]
    }
  end

  protected


  def reassign_params
     #Reassign to lookup_hash, a common Meraki::Action pattern
    @lookup_hash = params
  end

  def current_user
    ### APPSEC Vuln 8: Cookie tampering ATO
    @current_user ||= User.find(cookies[:user_id]) if cookies[:user_id]
  end

  def get_email
    # Will this hide the SQLi?
    @lookup_hash[:email]
  end

  def get_id
    @lookup_hash[:id]
  end

  def authenticate_user
    if user = User.find_by_token(request.headers["X-Authentication-Token"])
      puts "Authenticated as user #{user.id}"
      cookies[:user_id] = user.id
    else
      render json: { error: "Authentication required" }, status: 400 and return
    end
  end
end
