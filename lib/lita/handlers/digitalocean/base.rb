require "digital_ocean"
require "lita-keyword-arguments"
require "hashie"

module Lita
  module Handlers
    class Digitalocean < Handler
      class Base < Handler
        namespace "digitalocean"

        private

        def self.do_route(regexp, route_name, help, kwargs = nil)
          options = {
            command: true,
            help: help,
            restrict_to: :digitalocean_admins
          }

          options[:kwargs] = kwargs if kwargs

          route(regexp, route_name, options)
        end

        def api_key
          config.api_key
        end

        def client
          @client ||= ::DigitalOcean::API.new(client_id: client_id, api_key: api_key)
        end

        def client_id
          config.client_id
        end

        def do_call(response)
          unless api_key && client_id
            response.reply(t("credentials_missing"))
            return
          end

          do_response = yield client

          if do_response[:status] != "OK"
            response.reply(t("error", message: do_response[:message]))
            return
          end

          do_response
        end

        def format_array(array)
          %([#{array.join(",")}])
        end
      end
    end
  end
end
