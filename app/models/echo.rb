class Echo < ApplicationRecord
  belongs_to :foxtrot,
             # Rails 5+ by default will validate that the target of a `belongs_to` exists
             # i.e. Instances of `Charlie` will not be valid unless they have a connected
             # `Deltum` unless we set this value
             optional: true,

             # Setting inverse_of is generally a good practice
             inverse_of: :echo,

             # It isn't part of creating the relationship but it is good practice to
             # always explicitly choose a value for `dependent` option. `nil` (do
             # nothing) is the default. See
             # https://api.rubyonrails.org/v6.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
             # for details.
             dependent: nil
end
