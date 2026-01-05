class PostsController < ApplicationController
  before_action :set_post, only: %i[ show update destroy increment_view ]

  # GET /posts
  def index
    @posts = Post.all

    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @post = Post.new(post_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_content
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!
  end

  # POST /posts/:id/increment_view
  def increment_view
    @post.increment!(:view_count)
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    # Note: view_count is intentionally excluded to prevent manipulation
    def post_params
      params.expect(post: [ :title, :slug, :content, :published_at, :edited_at ])
    end
end
