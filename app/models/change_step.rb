class ChangeStep < ActiveRecord::Base
#  validates :type, :step_old, :step_new, presence: true

  # The padron of the project is code in model, I'm think bad ideia.

  def self.has_changes?(object)

    # if object.new_record?
    #
    #   collect_protocols_to_sinc(object, sinc_steps) if sinc_steps.present?
    #   return
    # end

    return unless object.changes.present?
    steps = ChangeStep.where(step_table_name: object.class.table_name, step_attribute: object.changes.keys)

    sinc_steps = steps.inject([]) do |result, st|
      is_find = object.changes.find{|k, v| k == st.step_attribute}
      next unless is_find.present?
      next unless is_find[0] == st.step_attribute && is_find[1][0].to_s.include?(st.step_old.to_s) && is_find[1][1].to_s.include?(st.step_new.to_s)
      result << {attribute: st.step_attribute, step: st}
    end

    p "#" * 100
    p object, sinc_steps
    p "#" * 100

    collect_protocols_to_sinc(object, sinc_steps) if sinc_steps.present?
  end

  def self.collect_protocols_to_sinc(object, list)
    if object.class.table_name == 'issues'

      # Get issues with protocols
      protocol = object.get_value_protocol
      setting = Setting.find_by_name('protocol_custom_field_id')
      # Search all issues which has the same protocol
      ids = CustomValue.where(custom_field_id: setting.value, value: protocol).map(&:customized_id).reject{|u| u == object.id}
      issues = Issue.where(id: ids)

      # Verificar se todas as issues tem o valor do 'field' que teve alteração
      # igual ao valor de step_new.
      # Talvez não precisa retornar o objeto no has_changes

      #binding.pry

      exist = list.find do |att|
        issues.find do |issue|
          p "$" * 100
          p issue[att[:attribute]]
          p att[:step][:step_new]
          p "$" * 100

          issue[att[:attribute]].to_s != att[:step][:step_new].to_s
        end
      end

      version = object.fixed_version_id
      date = version.present? ? Version.find(version).effective_date : nil
      ids = [object.id] unless ids.present?

      ws(date, list[0][:step][:situation], [{protocolo: protocol, ids_tarefas: ids}]) unless exist.present?
    elsif object.class.table_name == 'versions'

      # object.status == 'closed'
      # object.status == 'open'
    end
  end

  # def self.attributes_diff_all_issues?(issues_ids, list)
  #
  # end

  # se o usuário apagar ou alterar o campo protocolo? não faz nada
  # Algumas Melhorias ou defeitos não tem versão.. como vou atualizar a data?

  def self.ws(date, situation, protocols)
      uri = URI(Setting.find_by_name("url_webservice")[:value])
      json = {
        status: situation,
        protocolos: protocols,
        data: date,
        hash: Digest::MD5.hexdigest(protocols.join(''))
      }.to_json

      https = Net::HTTP.new(uri.host, uri.port)
      resp = https.post(uri.path, json, {'Content-Type' => 'application/json'})

      p "@" * 100
      p resp
      p "@" * 100
  end
end
