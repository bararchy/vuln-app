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
    ### (posts are probably public, but does the scanner know that...?)
    ### APPSEC Vuln 5: *Maybe* Unscoped find IDOR?
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
    "SELECT * FROM posts WHERE id = #{params[:id]}"
  end

  def get_unsafe_interpolated_where
    "WHERE id = #{params[:id]}"
  end

  ### APPSEC Vuln 7: UnscopedFind Delete IDOR with parent class accessor and hash reassignment
  def meu1468
    ### APPSEC Vuln 6: sanitize_sql_array SQLi false positive (MEU-1468)
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
    if params[:meu] == "1"
      meu1468
    end

    ### APPSEC Vuln 10: SQLi via callee interpolation
    # curl -X PUT 'http://127.0.0.1:3000/posts/%27' -H 'X-Authentication-Token: ...'
    result = Post.find_by_sql(get_unsafe_interpolated_query_string)
    @post = result.first if result.any?

    respond_to do |format|
      if @post && @post.update_attributes(post_params)
        format.json { head :no_content }
        format.xml  { head :no_content }
      else
        format.json { render json: (@post ? @post.errors : { error: "Post not found" }), status: :unprocessable_entity }
        format.xml  { render xml: (@post ? @post.errors : { error: "Post not found" }), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1.json
  # DELETE /posts/1.xml
  def destroy
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
