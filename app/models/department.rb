class Department < ActiveRecord::Base
  attr_accessible :name, :page_ids, :annoucement_ids, :news_report_ids, :document_ids
  has_many :pages
  has_many :news_reports
  has_many :documents
  has_many :announcings
  has_many :announcements, :through => :announcings
  has_many :teachers
  cattr_accessor :current_department

  DEPARTMENTS = %w[Management BA Acc Fin IB IM MBA EMBA]

end
