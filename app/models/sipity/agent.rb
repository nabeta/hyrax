module Sipity
  # A proxy for something that can take an action.
  #
  # * A User can be an agent
  # * A Group can be an agent (though Group is outside the scope of this system)
  class Agent < ActiveRecord::Base
    self.table_name = 'sipity_agents'

    ENTITY_LEVEL_AGENT_RELATIONSHIP = 'entity_level'.freeze
    WORKFLOW_LEVEL_AGENT_RELATIONSHIP = 'workflow_level'.freeze

    belongs_to :proxy_for, polymorphic: true
    has_many :workflow_responsibilities, dependent: :destroy
    has_many :entity_specific_responsibilities, dependent: :destroy

    has_many :comments,
             foreign_key: :agent_id,
             dependent: :destroy,
             class_name: 'Sipity::Comment'

    has_many :actions_that_were_requested_by_me,
             dependent: :destroy,
             foreign_key: 'requested_by_agent_id',
             class_name: "Sipity::EntityActionRegister"
  end
end
