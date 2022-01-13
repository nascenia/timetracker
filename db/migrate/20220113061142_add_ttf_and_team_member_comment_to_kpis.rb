class AddTtfAndTeamMemberCommentToKpis < ActiveRecord::Migration
  def change
    add_column  :kpis, :ttf_comment,          :text
    add_column  :kpis, :team_member_comment,  :text
  end
end
