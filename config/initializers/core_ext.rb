require 'core_ext/try_chain'
require 'core_ext/hash_helper'

Object.class_eval do
  include TryChain
end

Hash.class_eval do
  include HashHelper
end
