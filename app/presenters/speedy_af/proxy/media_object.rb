# Copyright 2011-2023, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
# 
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

class SpeedyAF::Proxy::MediaObject < SpeedyAF::Base
  # Override to handle section_id specially
  def initialize(solr_document, instance_defaults = {})
    instance_defaults ||= {}
    @model = SpeedyAF::Base.model_for(solr_document)
    @attrs = self.class.defaults.merge(instance_defaults)
    solr_document.each_pair do |k, v|
     attr_name, value = parse_solr_field(k, v)
      @attrs[attr_name.to_sym] = value
    end
#byebug
    # Handle this case here until a better fix can be found for multiple solr fields which don't have a model property
    @attrs[:section_id] = solr_document["section_id_ssim"]
    # TODO Need to convert hidden_bsi into discover_groups?
  end

  def to_model
    self
  end

  def persisted?
    id.present?
  end

  def model_name
    ActiveModel::Name.new(MediaObject)
  end

  def to_param
    id
  end

  # @return [SupplementalFile]
  def supplemental_files(tag: '*')
    return [] if supplemental_files_json.blank?
    files = JSON.parse(supplemental_files_json).collect { |file_gid| GlobalID::Locator.locate(file_gid) }
    case tag
    when '*'
      files
    when nil
      files.select { |file| file.tags.empty? }
    else
      files.select { |file| Array(tag).all? { |t| file.tags.include?(t) } }
    end
  end

  def master_file_ids
    if real?
      real_object.indexed_master_file_ids
    elsif section_id.nil? # No master files or not indexed yet
      ActiveFedora::Base.logger.warn("Reifying MediaObject because master_files not indexed")
      real_object.indexed_master_file_ids
    else
      section_id
    end
  end
  alias_method :indexed_master_file_ids, :master_file_ids
  alias_method :ordered_master_file_ids, :master_file_ids

  def master_files
    # NOTE: Defaults are set on returned SpeedyAF::Base objects if field isn't present in the solr doc.
    # This is important otherwise speedy_af will reify from fedora when trying to access this field.
    # When adding a new property to the master file model that will be used in the interface,
    # add it to the default below to avoid reifying for master files lacking a value for the property.
    SpeedyAF::Proxy::MasterFile.where("isPartOf_ssim:#{id}",
                                      order: -> { master_file_ids },
                                      load_reflections: true)
  end
  alias_method :indexed_master_files, :master_files
  alias_method :ordered_master_files, :master_files

  def collection
    SpeedyAF::Proxy::Admin::Collection.find(collection_id)
  end

  def lending_period
    attrs[:lending_period].presence || collection&.default_lending_period
  end

  # Copied from Hydra-Access-Controls
  def visibility
    if read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    elsif read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    else
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
  end

  def represented_visibility
    [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED,
     Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  end

  def leases(scope=:all)
    governing_policies.select { |gp| gp.is_a?(SpeedyAF::Proxy::Lease) and (scope == :all or gp.lease_type == scope) }
  end

  def governing_policies
    @governing_policies ||= Array(attrs[:isGovernedBy]).collect { |id| SpeedyAF::Base.find(id) }
  end
end
