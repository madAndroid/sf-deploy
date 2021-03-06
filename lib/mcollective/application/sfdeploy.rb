class MCollective::Application::Sfdeploy < MCollective::Application

    description "Deploy code from a local git mirror"

    usage <<-END_OF_USAGE
mco sfdeploy --application <APPLICATION> <ACTION>

the ACTION can be one of:

    update_git_clone
    show_tags 
    show_branches 
    deploy_tag 
    deploy_branch 
    run_post_deploy 
    current_metadata

    END_OF_USAGE

    option :application,
        :description    => "Application to work with",
        :arguments      => ["-a", "--application APPLICATION"],
        :type           => String,
        :required       => true

    option :branch,
        :description    => "Branch to deploy",
        :arguments      => ["-b", "--branch BRANCH"],
        :type           => String

    option :tag,
        :description    => "Tag to deploy",
        :arguments      => ["-t", "--tag TAG"],
        :type           => String

    option :groups,
        :description    => "Groups of post_deploy tasks to run",
        :arguments      => ["-g", "--groups GROUPS"],
        :type           => String


    def post_option_parser( configuration )

        valid_actions = %w(update_git_clone show_tags show_branches deploy_tag deploy_branch run_post_deploy current_metadata)

        if ARGV.size < 1
            raise "Please specify an action"
        end

        action = ARGV.shift

        unless valid_actions.index(action)
            raise "Action must be one of #{valid_actions.join(', ')}"
        end

        configuration[:action] = action

    end

    def validate_configuration( configuration )
        
        if configuration[:action] == 'deploy_branch' and !configuration.include?(:branch)
            raise "deploy_branch action requires branch argument"
        end

        if configuration[:action] == 'deploy_tag' and !configuration.include?(:tag)
            raise "deploy_tag action requires tag argument"
        end

        if configuration[:action] == 'run_post_deploy' and !configuration.include?(:groups)
            raise "run_post_deploy action requires groups argument"
        end

    end

    def main

        action = configuration[:action]

        mc = rpcclient("sfdeploy")

        printrpc mc.send(
            action, 
            :application => configuration[:application],
            :branch      => configuration[:branch],
            :tag         => configuration[:tag],
            :groups      => configuration[:groups],
            :options     => options
        )

        printrpcstats
   end

end
