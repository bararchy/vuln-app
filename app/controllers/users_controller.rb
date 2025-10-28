class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show]

  # POST /users
  # POST /users.json
  # POST /users.xml
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.json { render json: @user, status: :created, location: @user }
        format.xml  { render xml: @user, status: :created, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  ### APPSEC Vuln 2: Unscoped Find/Read IDOR
  def show
    begin
      puts "Returning data for user #{params[:id]}"
      @user = User.find_by(id: params[:id])
      respond_to do |format|
        if @user
          format.json { render json: @user, status: :ok }
        else
          format.json { render json: { error: "User not found" }, status: :not_found }
        end
      end
    rescue => e
      logger.error "Error fetching user: #{e.message}"
      # Changed error message to be more generic to prevent full path disclosure
      render json: { error: "An error occurred while processing your request." }, status: :internal_server_error
    end
  end

  ### APPSEC Vuln 3: Mass Assignment
  # curl -X POST 'http://127.0.0.1:3000/users?user%3D%7Bid%3D6%26email%3Dfoo%40bar.com%26password_digest%3D1%26admin%3Dtrue%26created_at%3D2025-08-27T19%3A17%3A42.430Z%26updated_at%3D2025-08-27T19%3A17%3A42.443Z%26password%3D1%26token%3D5f9914789c7d603144b323fc69ae1695%7D'
  private

    def user_params
      params.require(:user).permit(:id, :email, :password, :admin, :created_at, :updated_at, :token)
    end
end