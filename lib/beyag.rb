require "beyag/version"
require "active_support"
require "faraday"

module Beyag
  autoload :Client, "beyag/client"
  autoload :AsyncClient, "beyag/async_client"
  autoload :Response, "beyag/response"
end
