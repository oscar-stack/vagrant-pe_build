# Set up the PE build cache dir
class PEBuild::Action::PEBuildDir

  def initialize(app, env)
    @app, @env = app, env
  end

  def call(env)
    @env = env

    if @env[:home_path]
      build_dir = @env[:home_path].join('pe_builds')
      build_dir.mkpath unless build_dir.exist?
      @env[:pe_build_dir] = build_dir
    end

    @app.call(@env)
  end
end
