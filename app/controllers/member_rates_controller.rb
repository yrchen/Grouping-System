# encoding: utf-8
class MemberRatesController < ApplicationController
	layout 'groups'
	
	def rate
    @member_rate = MemberRate.find(params[:id])
    @member_rate.rate(params[:stars], current_user)
    respond_to do |format|
			format.js   {}
    end
  end
end
