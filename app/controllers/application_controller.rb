class ApplicationController < ActionController::API
  private

  def render_success(data, status: :ok)
    render json: {
      success: true,
      data: data
    }, status: status
  end

  def render_error(message, status:)
    render json: {
      success: false,
      error: {
        message: message
      }
    }, status: status
  end
end
