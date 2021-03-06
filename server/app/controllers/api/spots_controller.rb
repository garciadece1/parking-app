class Api::SpotsController < ApplicationController
  include ActionController
  respond_to :xml, :json
  REALM = ""
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_admin_user, only: [:create, :update, :destroy]

  def index
    respond_with(Spot.within(params[:lot_id], params[:lat1], params[:long1], params[:lat2], params[:long2]))
  end

  def show
    spot = Spot.find(params[:id])
    respond_with(spot)
  end

  def create
    valid_params = spot_params
    spot = Spot.new(valid_params.merge(:status => Spot::STATUS[valid_params["status"]]))
    if spot.save
      render(:json => spot)
    else
      render(:json => {:error => spot.errors})
    end
  end

  def update
    valid_params = spot_params
    spot = Spot.find(params[:id])
    if spot.update(valid_params.merge(:status => Spot::STATUS[valid_params["status"]]))
      render(:json => spot)
    else
      render(:json => {:error => spot.errors})
    end
  end

  def destroy
    spot = Spot.find(params[:id])
    if spot.destroy
      render(:json => {:deleted => true})
    else
      render(:json => {:error => spot.errors})
    end
  end

  private
    def spot_params
      params.permit(:lot_id, :latitude, :longitude, :status, :number)
    end

    def authenticate_admin_user
      authenticate_or_request_with_http_digest(REALM) do |email|
        if (user = User.find_by_email(email)) && user.is_admin_user?
          @authenticated_user = user
          user.password
        end
      end
    end
end
