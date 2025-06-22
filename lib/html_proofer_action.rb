# frozen_string_literal: true

require_relative 'html_proofer_action/runner'

# Main entrypoint to HTMLProofer Action
module HTMLProoferAction
  def self.run
    HTMLProoferAction::Runner.run
  end
end

HTMLProoferAction.run if $PROGRAM_NAME == __FILE__
