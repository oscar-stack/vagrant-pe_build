# Set up the PE build cache dir
class PEBuild::Action::PEBuildDir

  def initialize(app, env)
    @app, @env = app, env

    @build_dir = @env[:home_path].join('pe_builds')
  end

  def call(env)
    @env = env

    @build_dir.mkpath unless @build_dir.exist?
    @env[:pe_build_dir] = @build_dir

    @app.call(@env)
  end
end
