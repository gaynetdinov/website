module PartialsHelper

  include Nanoc::Helpers::Rendering

  def partial(name)
    render("/partials/#{name}.*")
  end

end
