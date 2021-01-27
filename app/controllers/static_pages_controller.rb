class StaticPagesController < ApplicationController
	def index
		flickr = Flickr.new
		if params[:user_id]
			begin
				@photos = flickr.photos.search(:user_id => params[:user_id])
				if @photos.none?
					flash.now[:notice] = "This user doesn't have any photos!"
					flash.now[:suggestion] = "Why not try #{random_user}?"
				end
			rescue Flickr::FailedResponse
	  		flash[:alert] = "User not found"
				flash[:suggestion] = "Why not try #{random_user}?"
			end
		elsif params[:tags]
			@photo = flickr.photos.search(tags => params[:tags], tag_mode => 'all', sort: 'relevance')
			if @photos.none?
				flash.now[:notice] = "No photos found with these tags"
				flash.now[:suggestion] = "Why not try #{random_tag}?"
			end
		end
	end

	private

	def random_user
		suggestion = @flickr.interestingness.getList(per_page: 1, page: (rand(100)+1))['photos'].first.owner
		view_context.link_to suggestion, root_path(params: { user_id: suggestion })
	end

	def random_tag
		while true
			suggestion = @flickr.interestingness.getList(per_page: 1, page: (rand(100)+1), extras: 'tags')['photos'].first['tag'].split.first(3).join(', ')
			return view_context.link_to suggestion, root_path(params: { tags: suggestion }) unless suggestion.blank?
		end
	end
end
