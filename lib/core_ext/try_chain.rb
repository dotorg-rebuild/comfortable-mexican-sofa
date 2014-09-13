module TryChain
  def try_chain *args
    args.inject(self) do |obj, message|
      obj.try(message)
    end
  end
end
