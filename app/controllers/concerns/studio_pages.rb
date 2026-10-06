# The studio pages are built around modals, so a form that fails validation has
# to come back on the page it was opened from with its modal still open and the
# errors attached. These helpers reload that page and slot the rejected record
# back in where the view expects to find it.
module StudioPages
  extend ActiveSupport::Concern

  private

  def render_dashboard(open:, status: :unprocessable_content)
    load_dashboard
    @open_modal = open
    render "dashboard/show", status: status
  end

  def render_project(project, open:, status: :unprocessable_content)
    load_project(project)
    @open_modal = open
    render "projects/show", status: status
  end

  def load_dashboard
    @projects = replace_edited(Project.ordered.includes(works: { image_attachment: :blob }).to_a, @project)
    @commissions = @projects.select(&:commission_section?)
    @artwork = @projects.reject(&:commission_section?)
    @new_project = new_record_or(@project) { Project.new(section: "commission") }
    @new_work = new_record_or(@work) { Work.new }
  end

  def load_project(project)
    @project = project
    @works = replace_edited(project.works.includes(image_attachment: :blob).to_a, @work)
    @new_work = new_record_or(@work) { Work.new(project: project) }
  end

  # Swap a saved record for the unsaved copy carrying validation errors.
  def replace_edited(records, edited)
    return records unless edited&.persisted?

    records.map { |record| record.id == edited.id ? edited : record }
  end

  def new_record_or(record)
    record&.new_record? ? record : yield
  end
end
