module Beyag
  class AsyncClient < Client
    def result(params)
      get("/result/#{params[:request_id]}")
    end

    private

    def full_path(path)
      [gateway_url, async_path(path)].join
    end

    def async_path(path)
      "/async#{path}"
    end
  end
end
