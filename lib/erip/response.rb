require "ostruct"

module Erip
  class Response
    attr_reader :response, :data

    def initialize(response)
      @response = response
      @data = begin
                JSON.parse(response.body)
              rescue JSON::ParserError
                {}
              end
    end

    def successful?
      (200..299).include?(status)
    end

    def error?
      errors.present?
    end

    def errors
      data["errors"]
    end

    def status
      response.status.to_i
    end
  end
end
