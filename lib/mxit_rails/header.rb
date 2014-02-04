module MxitRails
  module Header
    extend ActiveSupport::Concern

    def mxit_params
      @_mxit_params
    end

    included do
      if self.ancestors.include? ApplicationController
        send :before_filter, :get_mxit_info
      end
    end

    def get_mxit_header_field key
      output = request.headers[key]
      # Only allow cookie-based headers in development
      unless Rails.env.production?
        output ||= cookies[key.downcase]
      end
      output
    end

    def get_mxit_info
      @_mxit_params = {}
      @_mxit_params[:mxit_id] = get_mxit_header_field 'X-Mxit-USERID-R'
      @_mxit_params[:mxit_login] = get_mxit_header_field('X-Mxit-Login') || get_mxit_header_field('X-Mxit-ID-R')

      @_mxit_params[:display_name] = get_mxit_header_field 'X-Mxit-Nick'
      @_mxit_params[:nick] = @_mxit_params[:display_name]

      screen_size = get_mxit_header_field 'UA-Pixels'
      unless screen_size.blank?
        screen_size = screen_size.split 'x'
        @_mxit_params[:screen_width] = screen_size[0].to_i
        @_mxit_params[:screen_height] = screen_size[1].to_i
      end
      @_mxit_params[:device_user_agent] = get_mxit_header_field 'X-Device-User-Agent'
      # TODO: Split this into useful subcomponents

      @_mxit_params[:contact] = get_mxit_header_field 'X-Mxit-Contact'
      @_mxit_params[:location] = get_mxit_header_field 'X-Mxit-Location'
      location = @_mxit_params[:location]
      unless location.blank?
        location = location.split ','
        @_mxit_params[:country_code] = location[0] #ISO 3166-1 alpha-2 Country Code
        @_mxit_params[:country_name] = location[1]
        @_mxit_params[:principal_subdivision_code] = location[2]
        @_mxit_params[:principal_subdivision_name] = location[3]
        @_mxit_params[:city_code] = location[4]
        @_mxit_params[:city_name] = location[5]
        @_mxit_params[:network_operator_id] = location[6]
        @_mxit_params[:client_features_bitset] = location[7]
        @_mxit_params[:cell_id] = location[8]
      end
    
      @_mxit_params[:profile] = get_mxit_header_field 'X-Mxit-Profile'
      profile = @_mxit_params[:profile]
      unless profile.blank?
        profile = profile.split ','
        @_mxit_params[:language_code] = profile[0] #ISO_639-1 or ISO_639-2 language code
        @_mxit_params[:registered_country_code] = profile[1] #ISO 3166-1 alpha-2 Country Code
        @_mxit_params[:date_of_birth] = profile[2]
        begin
          # Don't set if it can't parse - ignore exceptions
          @_mxit_params[:date_of_birth] = Date.parse profile[2] #YYYY-MM-dd
        end
        @_mxit_params[:gender] = :unknown
        @_mxit_params[:gender] = :male if profile[3] =~ /male/i
        @_mxit_params[:gender] = :female if profile[3] =~ /female/i
        @_mxit_params[:tariff_plan] = :unknown
        @_mxit_params[:tariff_plan] = :free if profile[4] == '1'
        @_mxit_params[:tariff_plan] = :freestyler if profile[4] == '2'
      end

      user_input = get_mxit_header_field 'X-Mxit-User-Input'
      user_input = URI.unescape(user_input).gsub('+', ' ') unless user_input.blank?
      @_mxit_params[:user_input] = user_input
      # TODO: How closely must it match a link to be ignored?
      # TODO: What happens if there's an input on the page?

      # This is only available on internal services for security reasons
      device_info = get_mxit_header_field('X-Mxit-Device-Info')
      unless device_info.blank?
        tmp = device_info.split(',')
        @_mxit_params[:distribution_code] = tmp.first
        @_mxit_params[:mobile_number] = tmp[1] if tmp.length == 2
      end
    end
  end
end