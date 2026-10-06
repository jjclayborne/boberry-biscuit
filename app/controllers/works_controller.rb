class WorksController < ApplicationController
  include StudioPages

  layout "studio"

  before_action :set_work, only: %i[ update destroy ]

  def index
    redirect_to dashboard_path
  end

  # POST /works -- a work is always uploaded into a project.
  def create
    @work = Work.new(work_params)

    if @work.save
      redirect_to @work.project, notice: "#{@work.name} added to #{@work.project.name}."
    elsif @work.project
      render_project @work.project, open: "work-new"
    else
      render_dashboard open: "work-new"
    end
  end

  # PATCH /works/:id
  def update
    if @work.update(work_params)
      redirect_to @work.project, notice: "#{@work.name} updated.", status: :see_other
    else
      render_project @work.project, open: "work-#{@work.id}-edit"
    end
  end

  # DELETE /works/:id
  def destroy
    project = @work.project
    @work.destroy!
    redirect_to project, notice: "#{@work.name} was removed.", status: :see_other
  end

  private

  def set_work
    @work = Work.find(params.expect(:id))
  end

  def work_params
    params.expect(work: [ :name, :blurb, :medium, :year, :position, :project_id, :image, :image_width, :image_height ])
  end
end
