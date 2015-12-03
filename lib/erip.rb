require "erip/version"
require "active_support"
require "faraday"
require "faraday_middleware"

module Erip
  autoload :Client, "erip/client"
  autoload :Response, "erip/response"
end
