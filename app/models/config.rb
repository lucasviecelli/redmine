class Config < ActiveRecord::Base
#  validates :type, :step_old, :step_new, presence: true

  ATTR_ISSUE = ['status_id', 'fixed_version_id']
  # The padron of the project is code in model, I'm think bad ideia.

  def self.changes?(sinc_model)
    if sinc_model.class.table_name == 'issues' && sinc_model.changes.present?

      return unless sinc_model.changes.keys.find{|a| ATTR_ISSUE.include?(a)}.present
      return if sinc_model.status_id.include?(Config.find_by_config_name('not_sinc_issue_situation_id').value.split(','))
      # foi alterado a situacao ou versão
      # prepare_json_versions

      prepare_json_issues(sinc_model.get_value_protocol, sinc_model)

    elsif sinc_model.class.table_name == 'custom_values' # para o protocolo

      return unless sinc_model.changes.keys.find{|a| 'value' == a}.present?
      return if sinc_model.custom_field_id != Config.find_by_config_name('protocol_custom_field_id').value

      # foi alterado o protocolo
      issue = Issue.find(sinc_model.customized_id)
      prepare_json_issues(sinc_model.value.split(';'), issue)

    elsif sinc_model.class.table_name == 'versions'

      if sinc_model.changes.keys.find{|a| 'effective_date' == a}.present?
        change_effective_date_version(sinc_model)
      elsif sinc_model.changes.keys.find{|a| 'status' == a}.present?
        closed_version(sinc_model)
      end

    end
  end

  def self.prepare_json_issues(protocols, issue)
    {
        funcao: 3,
        situacao: issue.status.name,
        protocolos: protocols,
        tarefa: issue.id,
        data_liberacao: issue.fixed_version.effective_date,
        hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols))
    }
  end

  # Alteração de data

  def self.change_effective_date_version(version)
    setting = Setting.find_by_name('protocol_custom_field_id')
    issues_ids = Issue.where(fixed_version_id: version.id).select('id').map(&:id)
    protocols = CustomValue.where(customized_id: issues_ids, custom_field_id: setting.value).select('value').map(&:value).split(';').flatten

    {
      funcao: 2,
      data_liberacao: version.effective_date,
      protocolos: protocols,
      hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols))
    }
  end

  def self.closed_version(version)
    issues = Issue.where(fixed_version_id: version.id)
    protocols = []

    list = issues.collect do |issue|
      protocol = issue.get_value_protocol
      protocols << protocol

      {
        protocolo: protocol,
        data: issue.fixed_version.effective_date,
        situacao: issue.status.name,
        tarefa: issue.id
      }
    end

    {
      funcao: 1,
      protocolos: list,
      hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols))
    }
  end

  def self.ws(hash)
    uri = URI(Setting.find_by_name("url_webservice")[:value])

    https = Net::HTTP.new(uri.host, uri.port)
    resp = https.post(uri.path, hash.to_json, {'Content-Type' => 'application/json'})
  end
end
