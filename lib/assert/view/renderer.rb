require 'undies'

module Assert::View

  # this module is mixed in to the Assert::View::Base class
  # it use Undies to define and render view templates
  module Renderer

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    # define rendering template class to use for rendering
    # need to overwrite the '_' and '__' meths to add trailing newlines
    # b/c streaming output doesn't add any whitespace
    class Template < ::Undies::Template

      def _(data="", nl=true);  super(data.to_s + (nl ? "\n" : "")); end
      def __(data="", nl=true); super(data.to_s + (nl ? "\n" : "")); end

    end

    # this method is required by assert and is called by the test runner
    # use Undies to render the template
    # using the view's template file
    # streaming to the view's output io
    # passing in the view itself and any runner_callback as locals
    def render(*args, &runner_callback)
      Template.new(File.expand_path(self.template_file), self.output_io, {
        :view => self,
        :runner => runner_callback
      })
    end

    module ClassMethods

      # make any helper methods available to the template
      def helper(helper_klass)
        Template.send(:include, helper_klass)
      end

    end

  end
end
