class SessionsController < ApplicationController

  def create
    ### APPSEC Vuln 4: SQLi via parent class method with hash reassignment
    if user = User.find_by_sql("SELECT * FROM users WHERE email = '#{get_email}'").first
      render json: { token: user.token }
    else
      render json: { error: "Invalid email or password" }
    end
  end
end
