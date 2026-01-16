require 'js'

# Patch require_relative to load from remote
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative

  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
    #puts "require_relative #{path}"
  end
end

JS.global[:philosophy] = {}

require_relative '../lib/philosophy'
require_relative '../lib/philosophy/shims/svg'
require_relative './src/main'

main
nil
