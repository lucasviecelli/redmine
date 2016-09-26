class Config < ActiveRecord::Base
#  validates :type, :step_old, :step_new, presence: true

  ATTR_ISSUE = ['status_id', 'fixed_version_id']
  # The padron of the project is code in model, I'm think bad ideia.

  def self.changes?(sinc_model)
    begin

      if sinc_model.class.table_name == 'issues' && sinc_model.changes.present?
        return unless sinc_model.changes.keys.find{|a| ATTR_ISSUE.include?(a)}.present?
        return if Config.find_by_config_name('not_sinc_issue_situation_id').value.split(',').include?(sinc_model.status_id)

        hash = prepare_json_issues(sinc_model.get_value_protocol.split(';'), sinc_model)
      elsif sinc_model.class.table_name == 'custom_values' # para o protocolo
        return if sinc_model.custom_field_id != Config.find_by_config_name('protocol_custom_field_id').value.to_i
        return unless sinc_model.changes.keys.find{|a| 'value' == a}.present?

        # foi alterado o protocolo
        issue = Issue.find(sinc_model.customized_id)
        hash = prepare_json_issues(sinc_model.value.split(';'), issue)
      elsif sinc_model.class.table_name == 'versions'
        if sinc_model.changes.keys.find{|a| 'effective_date' == a}.present?
          hash = change_effective_date_version(sinc_model)
        elsif sinc_model.changes.keys.find{|a| 'status' == a}.present?
          hash = closed_version(sinc_model) if sinc_model.status == 'closed'
        end
      end

      ws(hash) if hash.present?
    rescue Exception => e
      WsError.create(inspect_model: sinc_model.inspect.to_s, message_error: e.message)
    end
  end

  def self.prepare_json_issues(protocols, issue)
    {
        funcao: 3,
        situacao: issue.status.name,
        protocolos: protocols,
        tarefa: issue.id,
        data_liberacao: (issue.fixed_version.effective_date rescue nil),
        hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols.join(';')))
    }
  end

  # Alteração de data

  def self.change_effective_date_version(version)
    setting = Setting.find_by_name('protocol_custom_field_id')
    issues_ids = Issue.where(fixed_version_id: version.id).select('id').map(&:id)
    protocols = CustomValue.where(customized_id: issues_ids, custom_field_id: setting.value).select('value').map{|v| v.value.split(';')}.flatten.uniq

    {
      funcao: 2,
      data_liberacao: version.effective_date,
      protocolos: protocols,
      hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols.join(';')))
    }
  end

  def self.closed_version(version)
    issues = Issue.where(fixed_version_id: version.id)
    protocols = []
    list = []

    issues.each do |issue|
      issue.get_value_protocol.split(';').flatten.uniq.each do |prot|
        protocols << prot
        list << {
          protocolo: prot,
          data: (issue.fixed_version.effective_date rescue nil),
          situacao: issue.status.name,
          tarefa: issue.id
        }
      end
    end

    {
      funcao: 1,
      protocolos: list,
      hash: Digest::MD5.hexdigest(Digest::MD5.hexdigest(protocols.join(';')))
    }
  end

  def self.ws(hash)
    uri = URI(Setting.find_by_name("url_webservice")[:value])

    https = Net::HTTP.new(uri.host, uri.port)
    resp = https.post(uri.path, hash.to_json, {'Content-Type' => 'application/json'})
  end
end
