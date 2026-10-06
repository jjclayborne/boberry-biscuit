class ProjectsController < ApplicationController
  include StudioPages

  layout "studio"

  before_action :set_project, only: %i[ show update destroy ]

  # The dashboard is the list of projects, so /projects just goes there.
  def index
    redirect_to dashboard_path
  end

  # GET /projects/:slug -- the studio view of one section of the gallery and
  # every work hanging in it.
  def show
    load_project(@project)
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "#{@project.name} is ready for works."
    else
      render_dashboard open: "project-new"
    end
  end

  # PATCH /projects/:slug
  def update
    if @project.update(project_params)
      redirect_to @project, notice: "#{@project.name} updated.", status: :see_other
    elsif params[:from] == "dashboard"
      render_dashboard open: "project-#{@project.to_param}-edit"
    else
      render_project @project, open: "project-details"
    end
  end

  # DELETE /projects/:slug
  def destroy
    @project.destroy!
    redirect_to dashboard_path, notice: "#{@project.name} and its works were removed.", status: :see_other
  end

  private

  def set_project
    @project = Project.find_by!(slug: params[:id])
  end

  def project_params
    params.expect(project: [ :name, :description, :commission, :kind, :section, :year, :slug, :position, :published ])
  end
end
