module ApplicationHelper
  # The portfolio rules things off with runs of hyphens; the studio borrows the
  # same ornament.
  def ascii_rule(length = 130)
    "-" * length
  end

  # True when a form on this page came back from a failed save and its modal
  # should reopen. Set by StudioPages in the controllers.
  def modal_open?(id)
    @open_modal == id
  end

  def studio_nav_current(page, current)
    { current: ("page" if page == current) }
  end
end
