class SubmissionPresenter
  ATTRIBUTES = [ :submission_template_id, :study_name, :project_name, :agree_requirements ]

  attr_accessor *ATTRIBUTES

  def initialize(user, submission_attributes = {})
    @user = user

    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", submission_attributes[attribute])
    end

  end

  def build_submission!
    raise "NOT IMPLEMENTED YET"
  end

  def project
    @project ||= Project.find_by_name(@project_name)
  end

  # Creates a new submission and adds an initial order on the submission using
  # the parameters
  def save!
    raise "NOT IMPLEMENTED YET"
  end

  def study
    @study ||= Study.find_by_name(@study_name)
  end

  # Returns an array of the names of all studies
  def studies
    @studies ||= Study.all.map(&:name)
  end

  def templates
    @templates ||= SubmissionTemplate.all
  end

  # Returns an array of all the names of studies associated with the current
  # user.
  def user_projects
    @user_projects ||= @user.sorted_project_names_and_ids.map(&:first)
  end
end

class SubmissionsController < ApplicationController

  def new
    @submission_presenter = SubmissionPresenter.new(current_user)
  end

  def create
    @submission_presenter = SubmissionPresenter.new(current_user, params[:submission])

    @submission_presenter.save!

  end

  # Renders the requirements document based on the SubmissionTemplate.
  # TODO[sd9]: Move this to a separate name spaced controller
  def requirements
    @submission_template = SubmissionTemplate.find(params[:submission][:submission_template_id])

    render :partial => 'submissions/requirements', :layout => false
  end
end

