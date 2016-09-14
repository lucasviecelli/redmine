


select
  custom_values.value as valor,
  issues.*
from issues
left join custom_values on custom_values.custom_field_id = 20 and custom_values.customized_id = issues.id
where
  issues.id = 6894;



CustomValue.find_by_custom_field_id


Setting.create(name: "protocol_custom_field_id", value: '1')



create table change_steps(
  type
  step_old:
  step_new:
)

'tipo':'liberacao/alteracao/producao/cancelamento'

{
  'tipo':'liberacao',
  'lista_protocolos':['protocolo1', 'protoco2'],
  'data_liberacao': '2016-09-13',
  'nro_tarefa': '3443'
  'hash': 'MD5oiuadua'
}
