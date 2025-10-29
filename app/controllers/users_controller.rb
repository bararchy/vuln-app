class UsersController < ApplicationController
    before_action :authenticate_user, only: [:show]
  # POST /users
  # POST /users.json
  # POST /users.xml
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  ### APPSEC Vuln 2: Unscoped Find/Read IDOR
  # Application is seeded with user IDs 1 to 3
  def show
    puts "Returning data for user #{params[:id]}"
    @user = User.find_by(id: params[:id])
    
    # Always return JSON regardless of Accept header
    if @user
      render json: @user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  ### APPSEC Vuln 11: Plaintext password storage - runtime exploitable
  # GET /users/:id/credentials
  def credentials
    @user = User.find_by(id: params[:id])
    
    if @user
      # Exposing plaintext password stored in database
      render json: { 
        id: @user.id,
        email: @user.email,
        password: @user.password,  # Plaintext password!
        password_digest: @user.password_digest,
        token: @user.token
      }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  ### APPSEC Vuln 15: CSRF - No CSRF protection on state-changing operation
  # POST /users/:id/transfer_ownership
  def transfer_ownership
    @user = User.find_by(id: params[:id])
    new_owner_email = params[:new_owner_email]
    
    if @user && new_owner_email
      # Simulate transferring ownership/admin rights
      # This is vulnerable to CSRF since skip_before_action :verify_authenticity_token is enabled
      render json: { 
        message: "Ownership transferred",
        previous_owner: @user.email,
        new_owner: new_owner_email,
        warning: "This endpoint is vulnerable to CSRF!"
      }, status: :ok
    else
      render json: { error: "Invalid request" }, status: :bad_request
    end
  end

  ### APPSEC Vuln 3: Mass Assignment
  # curl -X POST 'http://127.0.0.1:3000/users?user%3D%7Bid%3D6%26email%3Dfoo%40bar.com%26password_digest%3D1%26admin%3Dtrue%26created_at%3D2025-08-27T19%3A17%3A42.430Z%26updated_at%3D2025-08-27T19%3A17%3A42.443Z%26password%3D1%26token%3D5f9914789c7d603144b323fc69ae1695%7D'
  private

    def user_params
      params[:user]
    end
end
