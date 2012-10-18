require 'net/http'
require 'uri'
require 'json'

module MxitApi
  class Client
    MXIT_AUTH_BASE_URI = 'https://auth.mxit.com'
    MXIT_AUTH_TOKEN_URI = MXIT_AUTH_BASE_URI + '/token'
    MXIT_AUTH_CODE_URI = MXIT_AUTH_BASE_URI + '/authorize'

    MXIT_API_URI = 'http://api.mxit.com'

    attr_accessor :app_name, :client_id, :client_secret
    attr_accessor :auth_token

    def initialize(app_name, client_id, client_secret)
      @app_name = app_name
      @client_id = client_id
      @client_secret = client_secret
    end

    def request_app_auth(scopes)
      if scopes.empty?
        raise MxitApi::Exception.new("No scopes were provided.")
      end

      response = http_client(MXIT_AUTH_TOKEN_URI) do |http, path|

        request = new_post_request(path, {
          "grant_type" => "client_credentials",
          "scope" => scopes.join(" ")
        })

        http.request(request)
      end

      @auth_token = AuthToken.new(handle_response(response))
    end

    # The user's response to the authorisation code request will be redirected to `redirect_uri`. If
    # the request was successful there will be a `code` request parameter; otherwise `error`.
    #
    # redirect_uri - absolute URI to which the user will be redirected after authorisation
    # state - passed back to `redirect_uri` as a request parameter
    # scopes - list of scopes to which access is required
    def user_code_request_uri(redirect_uri, state, scopes)
      if scopes.empty?
        raise MxitApi::Exception.new("No scopes were provided.")
      end

      # build parameters
      parameters = {
        :response_type => "code",
        :client_id => @client_id,
        :redirect_uri => redirect_uri,
        :state => state,
        :scope => scopes.join(' ')
      }

      path = MXIT_AUTH_CODE_URI + "?#{URI.encode_www_form(parameters)}"
    end

    # NOTE: `user_code_request_uri` must be used before `request_user_auth` because it provides the
    # `code` argument. `redirect_uri` must match the one used in the `user_code_request_uri` call
    def request_user_auth(code, redirect_uri)
      response = http_client(MXIT_AUTH_TOKEN_URI) do |http, path|

        request = new_post_request(path, {
          "grant_type" => "authorization_code",
          "code" => code,
          "redirect_uri" => redirect_uri
        })

        http.request(request)
      end

      @auth_token = AuthToken.new(handle_response(response))
    end

    def revoke_token(auth_token)
      response = http_client(MXIT_AUTH_BASE_URI + "/revoke") do |http, path|

        request = new_post_request(path, {
          "token" => auth_token.access_token
        })

        http.request(request)
      end

      handle_response(response)
    end

    def refresh_token(auth_token)
      if auth_token.refresh_token.nil?
        raise MxitApi::Exception.new("The provided auth token doesn't have a refresh token.")
      end

      response = http_client(MXIT_AUTH_TOKEN_URI) do |http, path|

        request = new_post_request(path, {
          "grant_type" => "refresh_token",
          "refresh_token" => auth_token.refresh_token
        })

        http.request(request)
      end

      handle_response(response)
    end

    ### API methods requiring authorisation.

    # When sending as the app the `message/send` scope is required otherwise `message/user`
    def send_message(from, to, body, contains_markup, options={ spool: true,
      spool_timeout: 60*60*24*7, auth_token: nil })

      auth_token = options[:auth_token] || @auth_token

      if from == @app_name
        check_auth_token(auth_token, ["message/send"])
      else
        check_auth_token(auth_token, ["message/user"])
      end

      response = http_client(MXIT_API_URI + "/message/send/") do |http, path|

        request = Net::HTTP::Post.new(path)
        set_api_headers(request, auth_token.access_token)

        spool = options[:spool].nil? ? true : options[:spool]
        spool_timeout = options[:spool_timeout] || 60*60*24*7

        request.body = {
          "Body" => body,
          "ContainsMarkup" => contains_markup,
          "From" => from,
          "To" => to,
          "Spool" => spool,
          "SpoolTimeOut" => spool_timeout
        }.to_json

        http.request(request)
      end

      handle_response(response)
    end

    # The following filter parameters are available (only one can be specified at a time):
    #   @All - Return all roster entries
    #   @Friends - Return only friends
    #   @Apps - Return only applications
    #   @Invites  - Return all entries that is in an invite state
    #   @Connections  - Return all entries that has been accepted
    #   @Rejected - Return all entries that has been rejected
    #   @Pending - Return all entries that is waiting to be accepted by the other party
    #   @Deleted - Return all entries that was deleted
    #   @Blocked - Return all entries that was blocked
    def get_contact_list(filter, options={ skip: nil, count: nil, auth_token: nil })
      auth_token = options[:auth_token] || @auth_token
      check_auth_token(auth_token, ["graph/read"])

      response = http_client(MXIT_API_URI + "/user/socialgraph/contactlist") do |http, path|

        parameters = { :filter => filter }
        # skip and count are optional
        parameters[:skip] = options[:skip] if options[:skip]
        parameters[:count] = options[:count] if options[:count]

        request = Net::HTTP::Get.new(path + "?#{URI.encode_www_form(parameters)}")
        set_api_headers(request, auth_token.access_token)

        http.request(request)
      end

      handle_response(response)
    end

    def recommend_app(callback_url, from_user_id, to_user_id, message, options={ auth_token: nil })
      auth_token = options[:auth_token] || @auth_token
      check_auth_token(auth_token, ["contact/recommend"])

      response = http_client(MXIT_API_URI + "/user/recommend") do |http, path|

        request = Net::HTTP::Post.new(path)
        set_api_headers(request, auth_token.access_token)

        request.body = {
          "Application" => @app_name,
          "CallbackUrl" => callback_url,
          "FromUserId" => from_user_id,
          "ToUserId" => to_user_id,
          "Message" => message
        }.to_json

        http.request(request)
      end

      handle_response(response)
    end

    # When the Mxit API returns 400::Bad Request due to a non-existent Mxit ID in the batch the rest
    # of the IDs still receive the message.
    def batch_notify_users(mxit_ids, message, contains_markup, options={ spool: true,
      spool_timeout: 60*60*24*7 })

      Rails.logger.info('Requesting MXit API auth...')
      request_app_auth(["message/send"])
      Rails.logger.info('Finished MXit API auth.')

      batch_size = 50
      Rails.logger.info('Starting to notify users in batches of ' + batch_size.to_s + '...')
      i = 0
      while i < mxit_ids.count
        current_batch = mxit_ids[i, batch_size]
        i += current_batch.count 

        to = current_batch.join(',')
        begin
          send_message(@app_name, to, message, contains_markup, options)
        rescue Exception => exception
          Rails.logger.error("The following batch caused an exception during send message:" +
            "\n\t#{to}")
          Rails.logger.error(exception.message)
        end

        Rails.logger.info("Total users notified: " + i.to_s)
      end
      Rails.logger.info('Finished notifying!')
    end

    private

      def http_client(url)
        uri = URI(url)

        use_ssl = uri.scheme == 'https'
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => use_ssl) do |http|
          yield(http, uri.path)
        end
      end

      def new_post_request(path, form_data)
        request = Net::HTTP::Post.new(path)
        request.basic_auth(@client_id, @client_secret)
        request.set_form_data(form_data)
        return request
      end

      def set_request_auth(request, access_token)
        request["Authorization"] = "Bearer " + access_token
      end

      def set_api_headers(request, access_token, format="application/json")
        set_request_auth(request, access_token)
        request["Accept"] = format
        request.content_type = format
      end

      def check_auth_token(auth_token, scopes)
        if auth_token.nil?
          raise MxitApi::Exception.new("No auth token has been set/provided.")
        elsif not auth_token.has_scopes? scopes
          raise MxitApi::Exception.new("The auth token doesn't have the required scope(s): " +
            scopes.join(","))
        end
      end

      def handle_response(response)
        begin
          data = JSON.parse(response.body)
        rescue JSON::ParserError
          body = response.body
          # Unescape unicode characters.
          body = body.gsub(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}

          data = { "error" => "Error", "error_description" => body }
        end

        case response
        when Net::HTTPSuccess then
          data

        else
          error_message = "#{response.code}::#{response.message}"
          error_message += " - #{data["error"]}: #{data["error_description"]}" if not data.empty?
          raise MxitApi::RequestException.new(error_message, response.code), error_message
        end
      end

  end

end
