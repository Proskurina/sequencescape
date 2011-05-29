class ContainerAssociation < ActiveRecord::Base
  #We don't define the class, so will get an error if being used directly
  # in fact , the class need to be definend otherwise, eager loading through doesn't work
  belongs_to :container , :class_name => "Asset"
  belongs_to :content , :class_name => "Asset"

  # An object can only be contained once
  validates_uniqueness_of :content_id
  validates_presence_of :container_id
  validates_presence_of :content_id

  module Extension
    def contains(content_name, options = {}, &block)
      class_name = content_name ? content_name.to_s.classify : Asset.name
      has_many :container_associations, :foreign_key => :container_id
      has_many :contents, options.merge(:class_name => class_name, :through => :container_associations)
      has_many(content_name, options.merge(:class_name => class_name, :through => :container_associations, :source => :content)) do
        # Provide bulk importing abilities.  Inside a transaction we can guarantee that the information in the DB is
        # consistent from our perspective.  In other words, we can bulk insert the records and then reload them, limited
        # by their count, to obtain the IDs.
        line = __LINE__ + 1
        class_eval(%Q{
          def import(records)
            ActiveRecord::Base.transaction do
              #{class_name}.import(records)
              links_data = #{class_name}.all(:order => 'id DESC', :limit => records.size).map { |r| [proxy_owner.id, r.id] }
              ContainerAssociation.import([:container_id, :content_id], links_data, :validate => false)
              post_import(links_data)
            end
          end
        }, __FILE__, line)

        # Sometimes we need to do things after importing the contained records.  This is the callback that should be
        # overridden by the block passed.
        def post_import(_)
          # Does nothing by default
        end

        class_eval(&block) if block_given?
      end

      named_scope :"include_#{content_name}", :include => :contents  do
        def to_include
          [:contents]
        end

        def with(subinclude)
          scoped(:include => { :contents => subinclude })
        end
      end
    end

    def contained_by(container_name, &block)
      class_name = container_name.to_s.singularize.capitalize
      has_one :container_association, :foreign_key => :content_id
      has_one :container, :class_name => class_name, :through => :container_association
      has_one(container_name, :class_name => class_name, :through => :container_association, :source => :container, &block)

      #delegate :location, :to => :container

      before_save do |content|
        # We check if the parent has already been saved. if not the saving will not work.
        container = content.container
        raise RuntimeError, "Container should be saved befor saving #{self.inspect}" if container && container.new_record?
      end
    end
  end
end
