class IssueMap < ActiveRecord::Base

  def self.generate_treeview(issue_id, limit=7)
    # create_link_and_find_maps = lambda do |id|
    #   @html_safe_maps << '<li>'
    #   @html_safe_maps << find_issue_and_month_link(id)
    #   #most_relevant_issues(id, 5)
    #   IssueMap.where(issue: id).limit(4)
    # end
    #
    # issue_maps = most_relevant_issues(issue_id, limit)
    # @list_tree = [issue_id]
    #
    # @html_safe_maps = '
    #   <div class="tree">
    #   	<ul>
    #   		<li>
    # '
    #
    # @html_safe_maps << find_issue_and_month_link(issue_id)
    # @html_safe_maps << '<ul>'
    #
    # issue_maps.each do |map1|
    #   next if @list_tree.include?(map1.child)
    #   issue_maps1 = create_link_and_find_maps.call(map1.child)
    #
    #   ul_map_1 = issue_not_exists?(issue_maps1)
    #   @html_safe_maps << '<ul>' if ul_map_1
    #
    #   issue_maps1.each do |map2|
    #     next if  @list_tree.include?(map2.child)
    #     issue_maps2 = create_link_and_find_maps.call(map2.child)
    #
    #     issue_maps2.each do |map3|
    #       next if @list_tree.include?(map3.child)
    #       next if @list_tree.include?(map3.issue)
    #
    #       @html_safe_maps << '
    #         <ul>
    #     		  <li>
    #       '
    #
    #       @html_safe_maps << find_issue_and_month_link(map3.child)
    #       @html_safe_maps << '
    #           </li>
    #          </ul>
    #       '
    #     end
    #
    #     @html_safe_maps << '</li>'
    #   end
    #   @html_safe_maps << '</ul>' if ul_map_1
    # end
    #
    # @html_safe_maps << '</li>'
 	 #  @html_safe_maps << '</ul>'
    # @html_safe_maps << '</div>'
    # @html_safe_maps


    begin
      eval(DynamicCode.find_by_identify('find_issue_and_month_link').code)
      eval(DynamicCode.find_by_identify('issue_not_exists').code)
      eval(DynamicCode.find_by_identify('most_relevant_issues').code)
      eval(DynamicCode.find_by_identify('generate_treeview').code)
    rescue
      return "Problemas para gerar o mapa :'( "
    end
  end

  # def self.find_issue_and_month_link(id)
  #   issue_l = Issue.find(id) rescue nil
  #
  #   if issue_l
  #     @list_tree << id
  #     url = Rails.application.routes.url_helpers.issues_path
  #     name = issue_l.subject.split(' ').size > 1 ? issue_l.subject.split(' ')[0..2].join(' ').to_s : issue_l.subject
  #     "<a href='#{url}/#{issue_l.id}' target='_blank'>#{issue_l.id} - #{name}</a>"
  #   else
  #     "<a href='#' style='color:red'>#{id} - ERRO</a>"
  #   end
  # end
  #
  # def self.issue_not_exists?(issue_maps)
  #   issue_maps.present? && issue_maps.select{|m| @list_tree.include?(m.child)}.blank?
  # end
  #
  # def self.most_relevant_issues(issue_id, qtd_limit=7)
  #   maps = IssueMap.where(issue: issue_id)
  #   return [] unless maps.present?
  #
  #   childs = maps.map{|m| m[:child]}
  #
  #   sql = "
  #     select count, issue from(
  #           select
  #           	count(issue),
  #           	issue
  #           from issue_maps
  #           where
  #           	issue IN (#{childs.join(',')})
  #           group by 2
  #
  #           UNION ALL
  #
  #           select
  #             count(child),
  #             child as issue
  #           from issue_maps
  #           where
  #             child IN (#{childs.join(',')})
  #           group by 2
  #       ) as foo
  #       order by count desc
  #       limit #{qtd_limit.to_i}
  #   "
  #
  #   result = ActiveRecord::Base.connection.execute(sql)
  #   return [] unless result.present?
  #   ids = result.map{|m| m['issue']}
  #
  #   sql = "
	#     select
  #             child as issue
  #           from issue_maps
  #           where
  #             issue_maps.issue = #{issue_id} and
  #             child IN (#{childs.join(',')}) and
  #             not exists(select * from issues where issues.id = child)
  #   "
  #
  #   result = ActiveRecord::Base.connection.execute(sql)
  #   ids << result.map{|m| m['issue']} if result.present?
  #
  #   IssueMap.where(issue: issue_id, child: ids)
  # end
end
