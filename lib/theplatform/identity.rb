module ThePlatform

  # Class to RESTfully interface with thePlatform's Identity API
  #    ThePlatform::Identity#
  class Identity
    include HTTParty
    ssl_version :SSLv3
    extend ThePlatform::Configuration

    class << self

      # Set the different available params to configure
      def keys
        @keys ||= [:schema, :form, :username, :password, :_duration, :_idleTimeout]
      end

      # Return ALL THE TOKEN!
      #
      # This returns the entire response body from the Token request.
      #
      # ThePlatform::Identity.signin_response(username:'USERNAME', password:'PASSWORD', schema:'1.0', form:'(json|xml)')
      #
      # _duration: and _idleTimeout: are optional.  Resorts to thePlatform defaults if not defined
      def signin_response(options={})
        base_uri IDENTITY
        get("/signIn", query: extras.merge(options)).fetch('signInResponse') { "Could not authenticate user." }
      end

      # Return only the Token as a String
      def token(options={})
        token = signin_response(options)
        token.fetch('token') { "Could not authenticate user." }
      end

      # Invalidate a given Token
      #
      # ThePlatform::Identity.invalidate!(token, schema:'1.0', form:'(json|xml)')
      def invalidate!(tokens, options = {})
        base_uri IDENTITY
        get("/signOut?_token=#{tokens}", query: extras.merge(options))
      end

      # Return the number of tokens in an account.
      #
      # ThePlatform::Identity.count(username:'USERNAME', password:'PASSWORD',schema:'1.0', form:'(json|xml)')
      def count(options = {})
        base_uri IDENTITY
        get("/getTokenCount", query: extras.merge(options))
      end

    end

    private

    def self.extras
      ThePlatform::Identity.parameters
    end

  end

end
