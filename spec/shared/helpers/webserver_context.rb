require 'webrick'

# This context runs a WEBRick server that is accessible to tests.
# The `webserver_port` and `webserver_path` will need to be specified before
# this context is included:
#
#     let(:webserver_port) { ... }
#     let(:webserver_path) { ... }
#     include 'webserver'
shared_context 'webserver' do
  before(:each) do
    mime_types = {
      'gz'  => 'application/gzip',
      'zip' => 'application/zip',
      'tar' => 'application/x-tar',
    }

    @server = WEBrick::HTTPServer.new(
      AccessLog: [],
      BindAddress: '127.0.0.1',
      Port: webserver_port,
      DocumentRoot: webserver_path,
      MimeTypes: mime_types)
    @thr = Thread.new { @server.start }
  end

  after(:each) do
    @server.shutdown rescue nil
    @thr.join rescue nil
  end
end
