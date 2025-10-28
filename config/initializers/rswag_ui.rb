Rswag::Ui.configure do |c|
  # List the Swagger endpoints that you want to be documented through the
  # swagger-ui. The first parameter is the path (absolute or relative to the UI
  # host) to the corresponding endpoint and the second is a title that will be
  # displayed in the document selector.
  # NOTE: If you're using rspec-api to expose Swagger files
  # (under openapi_root) as JSON or YAML endpoints, then the list below should
  # correspond to the relative paths for those endpoints.

  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'Vulnerable App API V1'

  # Add Basic Auth in case your API is private
  # c.basic_auth_enabled = true
  # c.basic_auth_credentials 'username', 'password'
  
  # Configure Swagger UI settings to disable CSP and allow API calls
  c.config_object = {
    urls: [
      {
        url: '/api-docs/v1/swagger.yaml',
        name: 'Vulnerable App API V1'
      }
    ],
    supportedSubmitMethods: ['get', 'post', 'put', 'delete', 'patch'],
    persistAuthorization: true,
    displayRequestDuration: true,
    filter: true,
    tryItOutEnabled: true
  }
end


