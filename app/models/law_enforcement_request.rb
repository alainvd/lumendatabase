# frozen_string_literal: true

class LawEnforcementRequest < Notice
  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                %w[recipient sender principal]).freeze

  define_elasticsearch_mapping

  VALID_REQUEST_TYPES = [
    'Agency',
    'Civil Subpoena',
    'Email',
    'Records Preservation',
    'Subpoena',
    'Warrant'
  ].freeze

  validates_inclusion_of :request_type,
                         in: VALID_REQUEST_TYPES,
                         allow_blank: true

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end
end
