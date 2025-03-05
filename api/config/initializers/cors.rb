Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:4200', 'http://127.0.0.1:4200' #staging and production urls
    resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options]
  end
end