class PostsController < ApplicationController
  before_action :authenticate_user

  # GET /posts.json
  # GET /posts.xml
  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
      format.xml  { render xml: @posts }
    end
  end

  # GET /posts/1.json
  # GET /posts/1.xml
  def show
    ### APPSEC Vuln 5: *Maybe* Unscoped find IDOR?
    ### (posts are probably public, but does the scanner know that...?)
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json { render json: @post }
      format.xml  { render xml: @posts }
    end
  end

  # POST /posts.json
  # POST /posts.xml
  def create
    # curl -X POST 'http://127.0.0.1:3000/posts?post%5Btitle%5D%3Dtest' -H 'X-Authentication-Token: ...'
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.json { render json: @post, status: :created, location: @post }
        format.xml  { render xml: @post, status: :created, location: @post }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.xml  { render xml: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_unsafe_interpolated_query_string
    "SELECT * FROM users WHERE id = #{params[:id]}"
  end

  def get_unsafe_interpolated_where
    "WHERE id = #{params[:id]}"
  end

  def meu1468
    ### APPSEC Vuln 6: UnscopedFind Write IDOR, func indirect SQLi
    # curl -X PUT 'http://127.0.0.1:3000/posts/%27?meu=1' -H 'X-Authentication-Token: ...'
    sql = <<-SQL
      SELECT *
      FROM USERS
      #{get_unsafe_interpolated_where}
    SQL

    sanitized_sql = ActiveRecord::Base.send(
      :sanitize_sql_array, [
        sql,
        []
      ]
    )
    ActiveRecord::Base.connection.execute(sanitized_sql)
  end

  # PATCH/PUT /posts/1.json
  # PATCH/PUT /posts/1.xml
  def update
    if params[:meu].eq 1
      meu1468
    end

    ### APPSEC Vuln 10: UnscopedFind Write IDOR, func indirect SQLi
    # curl -X PUT 'http://127.0.0.1:3000/posts/%27' -H 'X-Authentication-Token: ...'
    @post = Post.find_by_sql(get_unsafe_interpolated_query_string).first

    respond_to do |format|
      if @post.update_attributes(post_params)
        format.json { head :no_content }
        format.xml  { head :no_content }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.xml  { render xml: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1.json
  # DELETE /posts/1.xml
  def destroy
    ### APPSEC Vuln 7: UnscopedFind Delete IDOR with parent class accessor and hash reassignment
    @post = Post.find(get_id)
    @post.destroy

    respond_to do |format|
      format.json { head :no_content }
      format.xml  { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def post_params
      params.require(:post).permit(:content, :title)
    end
end
